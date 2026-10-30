// `timescale 1ns / 1ps
// module top_dht11 (
//     input        clk,
//     input        rst,
//     input        btnR,
//     output [3:0] fnd_com,
//     output [7:0] fnd_font,
//     inout        dht11_io
// );

//     dht11_controller U_DHT11_CNTL (
//         .clk(clk),
//         .rst(rst),
//         .dht11_start(btnR),  // start trigger
//         .us_tick(us_tick),
//         .valid(),  // check sum ok 
//         .humidity(),  // 
//         .temperature(),
//         .dht11_io(dht11_io)  // single wire, for half duplexing 
//     );
// tick_gen_us dut_tick (
//     .clk(clk),
//     .rst(clk),
//     .us_tick(us_tick)
// );

// endmodule

// module dht11_controller (
//     input         clk,
//     input         rst,
//     input         dht11_start,  // start trigger
//     input         us_tick,
//     output reg       valid,        // check sum ok 
//     output [15:0] humidity,     // 
//     output [15:0] temperature,
//     inout         dht11_io      // single wire, for half duplexing 
// );

//     localparam IDLE = 0, START = 1, WAIT = 2, SYNC_L = 3, SYNC_H = 4, DATA_SYNC =5, BIT_TNRANS=5, STOP = 6;
//     reg [3:0] c_state, n_state;
//     reg [5:0] bit_cnt_reg, bit_cnt_next;
//     reg [39:0] data_reg, data_next;
   
//     // 0: in, 1 : out(fpga)
//     reg dht11_io_control_reg, dht11_io_control_next;
   
//    //0: low, 1; 
//     reg dht11_io_reg, dht11_io_next;
    
//     reg [$clog2(19_000)-1:0] tick_cnt_reg, tick_cnt_next;

//     //failing edge dectetive
//     reg dht_sync, dht_prev;
//     wire dht_fall = !dht_sync && dht_prev;

//     // output control by 3 state buffer 
//     assign dht11_io = (dht11_io_control_reg) ? dht11_io_reg : 1'bz;
//     assign valid = (data_reg[39:32] +data_reg[31:24]+data_reg[23:16]+data_reg[15:8] = data_reg[7:0] )

//     always @(posedge clk, posedge rst) begin
//         if (rst) begin
//             c_state              <= IDLE;
//             dht11_io_control_reg <= 1'b1;
//             dht11_io_reg         <= 1'b1;
//             tick_cnt_reg         <= 0;
//             bit_cnt_reg           <=0;
//             data_reg              <= 0; 
//             dht_prev <= 1'b1; //sync 2 f/f : rst
//             dht_sync <= 1'b1; //sync 2 f/f : rst
//         end else begin
//             c_state              <= n_state;
//             dht11_io_control_reg <= dht11_io_control_next;
//             dht11_io_reg         <= dht11_io_next;
//             tick_cnt_reg         <= tick_cnt_next;
//             bit_cnt_reg             <= bit_cnt_next;
//             data_reg                <= data_next;
//             dht_prev <= dht11_io; //sync 2 f/f : solve cdc
//             dht_sync <= dht_prev; //sync 2 f/f : solve cdc
//         end
//     end

//     // next, output
//     always @(*) begin
//         n_state               = c_state;
//         dht11_io_control_next = dht11_io_control_reg;
//         dht11_io_next         = dht11_io_reg;
//         tick_cnt_next         = tick_cnt_reg;
//         bit_cnt_next           = bit_cnt_reg;
//         data_next               =   data_reg;
//         case (c_state)
//             IDLE: begin
//                 dht11_io_next = 1'b1;
//                 dht11_io_control_next = 1'b1;
//                 if (dht11_start) begin
//                     tick_cnt_next = 0;
//                     n_state       = START;
//                 end
//             end
//             START: begin //stay : low 19ms 
//                 dht11_io_next = 1'b0;
//                 dht11_io_control_next = 1'b1;
//                 if (us_tick) begin
//                     if (tick_cnt_reg == 19_000 - 1) begin
//                         tick_cnt_next = 0;
//                         n_state = WAIT;
//                     end else begin
//                         tick_cnt_next = tick_cnt_reg + 1;
//                     end
//                 end
//             end
//             WAIT: begin //stay : high 30us 
//                 dht11_io_next = 1'b1;
//                 if (us_tick) begin
//                     if (tick_cnt_reg == 30 - 1) begin
//                         tick_cnt_next = 0;
//                         // change output to high impedence
//                         dht11_io_control_next = 1'b0;
//                         n_state =  SYNC_L;  // example
//                     end else begin
//                         tick_cnt_next = tick_cnt_reg + 1;
//                     end
//                 end
//             end
//             SYNC_L :  begin 
//                 dht11_io_control_next = 1'b0;
//                 if(us_tick) begin
//                     if ((dht11_io == 1) & (tick_cnt_reg >= 50) ) begin
//                         tick_cnt_next = 0;
//                         n_state =  SYNC_H;
//                     end else tick_cnt_next = tick_cnt_reg + 1;
//                 end
//             end
//             SYNC_H :  begin 
//                 dht11_io_control_next = 1'b0;
//                 if(us_tick) begin
//                     if (dht11_io == 0  ) begin
//                         tick_cnt_next = 0;
//                         n_state = DATA_SYNC;
//                     end 
//                     else begin
                    
//                     end
//                 end
//             end
//             DATA_SYNC : begin
//                 dht11_io_control_next = 1'b0;
                    
//                         if (dht11_io == 1  ) begin
//                         tick_cnt_next = 0;
//                         n_state =  BIT_TNRANS;
//                         end

    

//             end
//             BIT_TNRANS  : begin
//                     dht11_io_control_next = 1'b0;
//                     if(us_tick)begin
//                         if (!dht11_io)begin
//                             if(bit_cnt_reg == 39) begin
//                                 bit_cnt_next = 0;
//                                 tick_cnt_next = 0;
//                                 n_state = STOP;
//                             end else begin /// 여기서 sync
//                             if (dht_fall) begin
//                                 bit_cnt_next = bit_cnt_reg +1;
//                                 tick_cnt_next = 0;
//                                 n_state = DATA_SYNC;
//                             end
//                             else begin
//                                 if (tick_cnt_reg >= 40) begin
//                                     sensor_bit = 1;
//                                     result = {result[38:0], sensor_bit};
//                                 end
//                                 else begin
//                                     sensor_bit = 0;
//                                     result = {result[38:0], sensor_bit};
//                                 end
//                             end
//                         end
//                     end
//                     end
//             end

//             STOP: begin
//                 if (us_tick) begin
//                     if (tick_cnt_reg == 60 - 1) begin
//                         tick_cnt_next = 0;
//                         // change output to high impedence
//                         dht11_io_control_next = 1'b1;
//                         n_state = IDLE;
//                     end else begin
//                         tick_cnt_next = tick_cnt_reg + 1;
//                     end
//                 end
//             end
//         endcase
//     end
// endmodule



`timescale 1ns / 1ps

module top_dht11 (
    input        clk,
    input        rst,
    input        btnR,
    //input  [15:0] humidity,
    //output [3:0] fnd_com,
    //output [7:0] fnd_font,
    inout        dht11_io
);
    wire valid;
    //wire [15:0] humidity,temperature
    wire w_dht11_start;
    dht11_controller U_DHT11_CNTL (
        .clk(clk),
        .rst(rst),
        .dht11_start(w_dht11_start),  // start trigger
        .us_tick(us_tick),
        .valid(valid),  // check sum ok 
        .humidity(humidity),  // 
        .temperature(temperature),
        .dht11_io(dht11_io)  // single wire, for half duplexing 
    );
tick_gen_us dut_tick (
    .clk(clk),
    .rst(clk),
    .us_tick(us_tick)
);

// fnd_controller dut_fnd_controller(

//     .fnd_data(humidity),
//     .fnd_com(fnd_com),
//     .fnd_font(fnd_font),
//     .clk(clk), 
//     .reset(rst)
// );

button_debounce dut_button_debounce (
    .clk(clk),
    .reset(rst),
    .i_btn(btnR),
    .o_btn(w_dht11_start)
);
endmodule

module dht11_controller  (
    input         clk,
    input         rst,
    input         dht11_start,
    input         us_tick,
    output reg    valid,
    output [15:0] humidity,
    output [15:0] temperature,
    inout         dht11_io
);




    localparam IDLE       = 0,
               START      = 1,
               WAIT       = 2,
               SYNC_L     = 3,
               SYNC_H     = 4,
               DATA_SYNC  = 5,
               BIT_TRANS  = 6,
               STOP       = 7;

    localparam START_TIME   = 19_000;
    localparam WAIT_TIME    = 30;
    localparam BIT_ONE_TIME = 40;
    localparam TIMEOUT      = 120;

    reg [3:0]  c_state, n_state;
    reg [5:0]  bit_cnt_reg, bit_cnt_next;
    reg [39:0] data_reg, data_next;

    // 0: input (Hi-Z), 1: output (FPGA)
    reg dht11_io_control_reg, dht11_io_control_next;

    // FPGA drives Low only
    reg dht11_io_reg, dht11_io_next;

    reg [$clog2(19_000)-1:0] tick_cnt_reg, tick_cnt_next;

    // DHT11 input synchronizer and falling edge detector
    reg dht_meta, dht_sync, dht_prev;

    wire dht_fall = !dht_sync && dht_prev;

    // Start button synchronizer and edge detector
    reg start_meta, start_sync, start_prev;

    wire start_rise = start_sync && !start_prev;

    // SYNC_L: response Low detection flag
    reg sync_low_seen_reg, sync_low_seen_next;

    // Checksum
    reg valid_next;
    wire [7:0] check_sum;

    assign check_sum =
        data_reg[39:32] +
        data_reg[31:24] +
        data_reg[23:16] +
        data_reg[15:8];

    assign humidity    = data_reg[39:24];
    assign temperature = data_reg[23:8];

    // Tri-state buffer
    // The line is pulled High by an external pull-up resistor.
    assign dht11_io =
        (dht11_io_control_reg) ? dht11_io_reg : 1'bz;


    // State Logic
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state              <= IDLE;

            dht11_io_control_reg <= 1'b0;
            dht11_io_reg         <= 1'b0;

            tick_cnt_reg         <= 0;
            bit_cnt_reg          <= 0;
            data_reg             <= 0;

            valid                <= 1'b0;
            sync_low_seen_reg    <= 1'b0;

            // DHT11 synchronizer
            dht_meta             <= 1'b1;
            dht_sync             <= 1'b1;
            dht_prev             <= 1'b1;

            // Start synchronizer
            start_meta           <= 1'b0;
            start_sync           <= 1'b0;
            start_prev           <= 1'b0;

        end
        else begin
            c_state              <= n_state;

            dht11_io_control_reg <= dht11_io_control_next;
            dht11_io_reg         <= dht11_io_next;

            tick_cnt_reg         <= tick_cnt_next;
            bit_cnt_reg          <= bit_cnt_next;
            data_reg             <= data_next;

            valid                <= valid_next;
            sync_low_seen_reg    <= sync_low_seen_next;

            // 2FF synchronization + edge history
            dht_meta             <= dht11_io;
            dht_sync             <= dht_meta;
            dht_prev             <= dht_sync;

            start_meta           <= dht11_start;
            start_sync           <= start_meta;
            start_prev           <= start_sync;
        end
    end


    // Next State & Output Logic
    always @(*) begin

        n_state               = c_state;

        dht11_io_control_next = dht11_io_control_reg;
        dht11_io_next         = dht11_io_reg;

        tick_cnt_next         = tick_cnt_reg;
        bit_cnt_next          = bit_cnt_reg;
        data_next             = data_reg;

        valid_next            = valid;
        sync_low_seen_next    = sync_low_seen_reg;


        case (c_state)

            // ------------------------------------------
            // IDLE
            // ------------------------------------------
            IDLE: begin

                dht11_io_next         = 1'b0;
                dht11_io_control_next = 1'b0;

                tick_cnt_next      = 0;
                bit_cnt_next       = 0;
                sync_low_seen_next = 1'b0;

                if (start_rise) begin
                    data_next             = 0;
                    valid_next            = 1'b0;

                    dht11_io_next         = 1'b0;
                    dht11_io_control_next = 1'b1;

                    n_state = START;
                end
            end


            // ------------------------------------------
            // START: FPGA Low 19ms
            // ------------------------------------------
            START: begin

                dht11_io_next         = 1'b0;
                dht11_io_control_next = 1'b1;

                if (us_tick) begin

                    if (tick_cnt_reg == START_TIME - 1) begin

                        tick_cnt_next = 0;

                        // Release bus
                        dht11_io_control_next = 1'b0;

                        n_state = WAIT;
                    end
                    else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end


            // ------------------------------------------
            // WAIT: 30us after releasing bus
            // ------------------------------------------
            WAIT: begin

                dht11_io_control_next = 1'b0;

                if (us_tick) begin

                    if (tick_cnt_reg == WAIT_TIME - 1) begin

                        tick_cnt_next      = 0;
                        sync_low_seen_next = 1'b0;

                        n_state = SYNC_L;
                    end
                    else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end


            // ------------------------------------------
            // SYNC_L: Sensor response Low
            // ------------------------------------------
            SYNC_L: begin

                dht11_io_control_next = 1'b0;

                // Wait for response Low
                if (!sync_low_seen_reg) begin

                    if (!dht_sync) begin

                        sync_low_seen_next = 1'b1;
                        tick_cnt_next      = 0;
                    end
                    else if (us_tick) begin

                        if (tick_cnt_reg >= TIMEOUT - 1) begin
                            tick_cnt_next = 0;
                            n_state = IDLE;
                        end
                        else begin
                            tick_cnt_next = tick_cnt_reg + 1;
                        end
                    end
                end

                // Response Low detected
                else begin

                    if (dht_sync) begin

                        // Check minimum observed Low duration
                        if (tick_cnt_reg >= 40) begin

                            tick_cnt_next = 0;
                            n_state = SYNC_H;
                        end
                        else begin
                            tick_cnt_next = 0;
                            n_state = IDLE;
                        end
                    end
                    else if (us_tick) begin

                        if (tick_cnt_reg >= TIMEOUT - 1) begin
                            tick_cnt_next = 0;
                            n_state = IDLE;
                        end
                        else begin
                            tick_cnt_next = tick_cnt_reg + 1;
                        end
                    end
                end
            end


            // ------------------------------------------
            // SYNC_H: Sensor response High (~80us)
            // ------------------------------------------
            SYNC_H: begin

                dht11_io_control_next = 1'b0;

                // High -> Low
                if (dht_fall) begin

                    tick_cnt_next = 0;
                    n_state = DATA_SYNC;
                end
                else if (us_tick) begin

                    if (tick_cnt_reg >= TIMEOUT - 1) begin
                        tick_cnt_next = 0;
                        n_state = IDLE;
                    end
                    else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end


            // ------------------------------------------
            // DATA_SYNC: Wait for data High
            // ------------------------------------------
            DATA_SYNC: begin

                dht11_io_control_next = 1'b0;

                // Low -> High
                if (dht_sync) begin

                    tick_cnt_next = 0;
                    n_state = BIT_TRANS;
                end
                else if (us_tick) begin

                    if (tick_cnt_reg >= TIMEOUT - 1) begin
                        tick_cnt_next = 0;
                        n_state = IDLE;
                    end
                    else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end


            // ------------------------------------------
            // BIT_TRANS: Receive 40 bits
            // ------------------------------------------
            BIT_TRANS: begin

                dht11_io_control_next = 1'b0;

                // Falling edge = end of data High
                if (dht_fall) begin

                    // Reject abnormal short High pulse
                    if (tick_cnt_reg < 15) begin

                        tick_cnt_next = 0;
                        n_state = IDLE;
                    end
                    else begin

                        // High >= 40us -> 1
                        if (tick_cnt_reg >= BIT_ONE_TIME) begin

                            data_next = {data_reg[38:0], 1'b1};
                        end

                        // High < 40us -> 0
                        else begin

                            data_next = {data_reg[38:0], 1'b0};
                        end

                        tick_cnt_next = 0;

                        // 40 bits received
                        if (bit_cnt_reg == 39) begin

                            bit_cnt_next = 0;
                            n_state = STOP;
                        end

                        // Receive next bit
                        else begin

                            bit_cnt_next = bit_cnt_reg + 1;
                            n_state = DATA_SYNC;
                        end
                    end
                end

                // Measure High duration
                else if (us_tick) begin

                    if (tick_cnt_reg >= TIMEOUT - 1) begin
                        tick_cnt_next = 0;
                        n_state = IDLE;
                    end
                    else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end


            // ------------------------------------------
            // STOP: Sensor final Low (~50us)
            // ------------------------------------------
            STOP: begin

                dht11_io_control_next = 1'b0;

                // Sensor releases bus -> High
                if (dht_sync) begin

                    tick_cnt_next = 0;

                    // Checksum verification
                    if (check_sum == data_reg[7:0]) begin
                        valid_next = 1'b1;
                    end
                    else begin
                        valid_next = 1'b0;
                    end

                    n_state = IDLE;
                end
                else if (us_tick) begin

                    if (tick_cnt_reg >= TIMEOUT - 1) begin

                        tick_cnt_next = 0;
                        valid_next = 1'b0;

                        n_state = IDLE;
                    end
                    else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end


            default: begin
                n_state = IDLE;
            end

        endcase
    end

endmodule
