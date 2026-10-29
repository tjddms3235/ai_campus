`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/12 14:42:15
// Design Name: 
// Module Name: data_controll
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


// module controll_unit (
//     input            clk,
//     input            reset,
//     input      [2:0] sw,
//     output reg       run_stop,
//     output reg       clear,
//     output           mode
// );

//     parameter STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10, MODE = 2'b11;
//     reg [1:0] c_state, n_state;

//     assign mode = sw[2];

//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             c_state <= STOP;
//         end else begin
//             c_state <= n_state;
//         end
//     end

//     always @(*) begin
//         n_state = c_state;
//         run_stop = 1'b0;
//         clear = 1'b0;
//         case (c_state)
//             STOP: begin
//                 run_stop = 1'b0;
//                 clear = 1'b0;
//                 if (sw[0] == 1'b1) begin
//                     n_state = RUN;
//                 end else if (sw[1] == 1'b1) begin
//                     n_state = CLEAR;
//                 end
//             end
//             RUN: begin
//                 run_stop = 1'b1;
//                 if (sw[0] == 1'b0) begin
//                     n_state = STOP;
//                 end
//             end
//             CLEAR: begin
//                 clear = 1'b1;
//                 if (sw[1] == 1'b0) begin
//                     n_state = STOP;
//                 end
//             end
//         endcase
//     end
// endmodule
module controll_unit (
    input btuR,
    input btuL,
    input clk,
    input reset,
    input btn_run_stop,
    input btn_clear,
    input btn_mode,
    output reg clear,
    output reg run_stop,
    output mode
);
    parameter STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10, MODE = 2'b11;
    reg [1:0] n_state, c_state;
    reg mode_reg, mode_next;  // mode_reg: currunt mode, mode_next: next mode
    // assign mode = sw;
    assign mode = mode_reg;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state  <= STOP;
            mode_reg <= 1'b0;
        end else begin
            c_state  <= n_state;
            mode_reg <= mode_next;
        end
    end

    always @(*) begin
        n_state = c_state;
        run_stop = 1'b0;
        clear = 1'b0;
        mode_next = mode_reg;  // 초기값 전상태 유지
        case (c_state)
            STOP: begin
                run_stop = 1'b0;
                clear = 1'b0;
                if (btn_run_stop == 1'b1) begin
                    n_state = RUN;
                end else if (btn_clear == 1'b1) begin
                    n_state = CLEAR;
                end else if (btn_mode == 1'b1) begin
                    n_state = MODE;
                end
            end
            RUN: begin
                run_stop = 1'b1;
                if (btn_run_stop == 1'b1) begin
                    n_state = STOP;
                end
            end
            CLEAR: begin
                clear   = 1'b1;
                n_state = STOP;
            end
            MODE: begin
                mode_next = ~mode_reg;
                n_state   = STOP;
            end
            // default: begin
            //     clear = 0;
            //     run_stop = 0;
            // end
        endcase
    end
endmodule
