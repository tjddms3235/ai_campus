`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/30 16:15:20
// Design Name: 
// Module Name: ascii_sender
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// module ascii_sender(
//     input           clk,
//     input           rst,
//     input           done,
//     input           vaild // 2 sensor vaild, 0: error 
//     input   [1:0]   data_type, //control unit select  : stopwatch, watch, sr04, dht11 
//     input   [39:0]  input_data,
    
//     input           fifo_full,
//     output  [7:0]   fifo_data,
//     output          push,

//     output          ready,
//     output          sender_busy
    
//     );



//     reg [7:0] data_reg, data_next;
//     always @(posedge clk, posedge rst) begin
//         if (rst) begin
//             data_reg <= 0;
//         end else begin
//             data_reg <= data_next;
//         end
//     end

//     always @(*) begin

//         data_next = data_reg;
//         if (enable == 1) begin
//             data_next = ascii;
//         end else begin
//             case (data_reg)
//                 8'h30: bin = 4'h0;
//                 8'h31: bin = 4'h1;
//                 8'h32: bin = 4'h2;
//                 8'h33: bin = 4'h3;
//                 8'h34: bin = 4'h4;
//                 8'h35: bin = 4'h5;
//                 8'h36: bin = 4'h6;
//                 8'h37: bin = 4'h7;
//                 8'h38: bin = 4'h8;
//                 8'h39: bin = 4'h9;
//                 8'h41: bin = 4'ha;
//                 8'h42: bin = 4'hb;
//                 8'h43: bin = 4'hc;
//                 8'h44: bin = 4'hd;
//                 8'h45: bin = 4'he;
//                 8'h46: bin = 4'hf;
//             endcase
//         end

//     end





// endmodule



`timescale 1ns / 1ps

// done && ready인 상승 에지에서 새 요청을 저장합니다.
// busy 중 발생한 요청은 저장하지 않으므로 컨트롤 유닛에서 보관해야 합니다.
// 요청이 수락되면 done을 내려야 합니다. 계속 HIGH이면 다음 IDLE에서 재전송됩니다.
module ascii_sender #(
    parameter DHT11_WITH_CHECKSUM = 1
) (
    input         clk,
    input         rst,
    input         done,
    input         vaild,       // 센서 데이터: 1=정상, 0=오류 (요청한 철자 유지)
    input  [1:0]  data_type,
    input  [39:0] input_data,
    input         fifo_full,
    output reg [7:0] fifo_data,
    output        push,
    output        ready,
    output        sender_busy
);
    localparam [1:0] TYPE_STOPWATCH = 2'b00,
                     TYPE_WATCH     = 2'b01,
                     TYPE_SR04      = 2'b10,
                     TYPE_DHT11     = 2'b11;

    // 상태: 대기 -> 준비 -> 변환 시작 -> 변환 대기 -> FIFO 전송
    localparam [2:0] IDLE          = 3'd0,
                     PREPARE       = 3'd1,
                     CONVERT_START = 3'd2,
                     CONVERT_WAIT  = 3'd3,
                     SEND          = 3'd4;

    reg [2:0] state;
    reg [39:0] data_reg;
    reg [1:0] type_reg;
    reg error_reg;
    reg [4:0] char_index;  // 현재 전송할 문자의 위치
    reg [4:0] last_index;  // 마지막 문자의 위치
    reg [1:0] field_index; // 현재 변환 중인 필드 번호 (0~3)

    // 변환한 숫자 보관: 시간은 시/분/초/msec, DHT는 습도 정수/소수/온도 정수/소수
    // SR04는 ascii_0만 사용합니다. 각 레지스터는 ASCII 숫자 8자리를 저장합니다.
    reg [63:0] ascii_0, ascii_1, ascii_2, ascii_3;
    reg [23:0] convert_binary;
    wire [63:0] convert_ascii;
    wire convert_done;

    // 저장한 데이터를 필드별로 나누기
    // 시간: {hour[4:0], min[5:0], sec[5:0], msec[6:0]}
    // msec은 첨부 코드 기준 10ms 단위의 0~99 카운터입니다.
    wire [4:0] hour   = data_reg[23:19];
    wire [5:0] minute = data_reg[18:13];
    wire [5:0] second = data_reg[12:7];
    wire [6:0] msec   = data_reg[6:0];
    wire [23:0] distance = data_reg[23:0];  // cm 단위 이진수

    // 40비트: {습도 정수, 습도 소수, 온도 정수, 온도 소수, 체크섬}
    // 32비트: {8'd0, 습도 정수, 습도 소수, 온도 정수, 온도 소수}
    // 소수 바이트는 0~99의 백분율 자리 값입니다. 예: 정수 25, 소수 5 -> 25.05
    // 체크섬은 센서/컨트롤 유닛에서 검사하고 결과를 vaild로 전달합니다.
    wire [31:0] dht_payload = DHT11_WITH_CHECKSUM ? data_reg[39:8]
                                                                : data_reg[31:0];
    wire [7:0] humid_int = dht_payload[31:24];
    wire [7:0] humid_dec = dht_payload[23:16];
    wire [7:0] temp_int  = dht_payload[15:8];
    wire [7:0] temp_dec  = dht_payload[7:0];

    assign ready       = !rst && (state == IDLE);
    assign sender_busy = !rst && (state != IDLE);
    assign push        = !rst && (state == SEND) && !fifo_full;

    // 기존 쉬프트 변환기에 넣을 이진수 하나를 선택합니다.
    always @(*) begin
        convert_binary = 24'd0;
        case (type_reg)
            TYPE_STOPWATCH, TYPE_WATCH: begin
                case (field_index)
                    2'd0: convert_binary = {19'd0, hour};
                    2'd1: convert_binary = {18'd0, minute};
                    2'd2: convert_binary = {18'd0, second};
                    2'd3: convert_binary = {17'd0, msec};
                endcase
            end
            TYPE_SR04: convert_binary = distance;
            TYPE_DHT11: begin
                case (field_index)
                    2'd0: convert_binary = {16'd0, humid_int};
                    2'd1: convert_binary = {16'd0, humid_dec};
                    2'd2: convert_binary = {16'd0, temp_int};
                    2'd3: convert_binary = {16'd0, temp_dec};
                endcase
            end
        endcase
    end

    // bin24_to_ascii8.v의 기존 shift/add-3 방식은 그대로 사용합니다.
    bin24_to_ascii8 U_BINARY_TO_ASCII (
        .clk(clk),
        .rst(rst),
        .start(state == CONVERT_START),
        .binary_data(convert_binary),
        .ascii_data(convert_ascii),
        .busy(),
        .done(convert_done)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            data_reg    <= 40'd0;
            type_reg    <= TYPE_STOPWATCH;
            error_reg   <= 1'b0;
            char_index  <= 5'd0;
            last_index  <= 5'd0;
            field_index <= 2'd0;
            ascii_0 <= "00000000";
            ascii_1 <= "00000000";
            ascii_2 <= "00000000";
            ascii_3 <= "00000000";
        end else begin
            case (state)
                IDLE: begin
                    // 데이터가 전송 도중 바뀌지 않도록 요청 시점의 값을 저장합니다.
                    if (done) begin
                        data_reg <= input_data;
                        type_reg <= data_type;
                        // 센서의 vaild만 확인합니다. 숫자 범위는 검사하지 않습니다.
                        error_reg <= ((data_type == TYPE_SR04) ||
                                      (data_type == TYPE_DHT11)) && !vaild;
                        char_index  <= 5'd0;
                        field_index <= 2'd0;
                        state <= PREPARE;
                    end
                end

                PREPARE: begin
                    if (error_reg) begin
                        last_index <= 5'd3;   // xxxx: 4문자
                        state <= SEND;
                    end else begin
                        case (type_reg)
                            TYPE_STOPWATCH, TYPE_WATCH:
                                last_index <= 5'd10;  // 11문자
                            TYPE_SR04:
                                last_index <= 5'd10;  // 11문자
                            TYPE_DHT11:
                                last_index <= 5'd22;  // 23문자
                        endcase
                        state <= CONVERT_START;
                    end
                end

                CONVERT_START: begin
                    // 이 상태에서 변환기의 start가 1클럭 동안 1이 됩니다.
                    state <= CONVERT_WAIT;
                end

                CONVERT_WAIT: begin
                    if (convert_done) begin
                        // 완료된 필드의 ASCII 숫자를 저장합니다.
                        case (field_index)
                            2'd0: ascii_0 <= convert_ascii;
                            2'd1: ascii_1 <= convert_ascii;
                            2'd2: ascii_2 <= convert_ascii;
                            2'd3: ascii_3 <= convert_ascii;
                        endcase

                        if ((type_reg == TYPE_SR04) || (field_index == 2'd3)) begin
                            state <= SEND;
                        end else begin
                            field_index <= field_index + 1'b1;
                            state <= CONVERT_START;
                        end
                    end
                end

                SEND: begin
                    // full이면 push=0: 현재 문자와 위치를 그대로 유지합니다.
                    // push=1인 상승 에지에서 FIFO에 기록하고 다음 위치로 이동합니다.
                    if (push) begin
                        if (char_index == last_index)
                            state <= IDLE;
                        else
                            char_index <= char_index + 1'b1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

    // 현재 문자 위치에 따라 숫자 또는 기호를 선택하는 조합회로
    always @(*) begin
        fifo_data = 8'h00;
        if (state == SEND) begin
            if (error_reg) begin
                case (char_index)
                    0, 1, 2, 3: fifo_data = "x";
                    default: fifo_data = 8'h00;
                endcase
            end else begin
                case (type_reg)
                    TYPE_STOPWATCH, TYPE_WATCH: begin
                        case (char_index)
                            0: fifo_data = ascii_0[15:8];
                            1: fifo_data = ascii_0[7:0];
                            2, 5, 8: fifo_data = ":";
                            3: fifo_data = ascii_1[15:8];
                            4: fifo_data = ascii_1[7:0];
                            6: fifo_data = ascii_2[15:8];
                            7: fifo_data = ascii_2[7:0];
                            9: fifo_data = ascii_3[15:8];
                            10: fifo_data = ascii_3[7:0];
                            default: fifo_data = 8'h00;
                        endcase
                    end
                    TYPE_SR04: begin
                        case (char_index)
                            0: fifo_data = ascii_0[63:56];
                            1: fifo_data = ascii_0[55:48];
                            2: fifo_data = ascii_0[47:40];
                            3: fifo_data = ascii_0[39:32];
                            4: fifo_data = ascii_0[31:24];
                            5: fifo_data = ascii_0[23:16];
                            6: fifo_data = ascii_0[15:8];
                            7: fifo_data = ascii_0[7:0];
                            8: fifo_data = " ";
                            9: fifo_data = "c";
                            10: fifo_data = "m";
                            default: fifo_data = 8'h00;
                        endcase
                    end
                    TYPE_DHT11: begin
                        case (char_index)
                            0: fifo_data = "H";
                            1, 14: fifo_data = "=";
                            2: fifo_data = ascii_0[23:16];
                            3: fifo_data = ascii_0[15:8];
                            4: fifo_data = ascii_0[7:0];
                            5, 18: fifo_data = ".";
                            6: fifo_data = ascii_1[15:8];
                            7: fifo_data = ascii_1[7:0];
                            8, 12, 21: fifo_data = " ";
                            9: fifo_data = "%";
                            10: fifo_data = "R";
                            11: fifo_data = "H";
                            13: fifo_data = "T";
                            15: fifo_data = ascii_2[23:16];
                            16: fifo_data = ascii_2[15:8];
                            17: fifo_data = ascii_2[7:0];
                            19: fifo_data = ascii_3[15:8];
                            20: fifo_data = ascii_3[7:0];
                            22: fifo_data = "C";
                            default: fifo_data = 8'h00;
                        endcase
                    end
                endcase
            end
        end
    end
endmodule
