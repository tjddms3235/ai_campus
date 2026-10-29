`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/14 09:38:47
// Design Name: 
// Module Name: stop_watch
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


module stop_watch (
    input clk,
    input rst,
    input btnR,
    input btnL,
    input btnU,
    input sw_display_mode,
    output [3:0] fnd_com,
    output [7:0] fnd_font
);
    wire w_btn_run_stop, w_btn_clear, w_btn_mode;
    wire w_run_stop, w_clear, w_mode;

    parameter MSEC_BIT_WIDTH = 7;
    parameter SEC_BIT_WIDTH  = 6;
    parameter MIN_BIT_WIDTH  = 6;
    parameter HOUR_BIT_WIDTH = 5;

    wire [MSEC_BIT_WIDTH-1:0] w_msec;
    wire [SEC_BIT_WIDTH-1:0] w_sec; 
    wire [MIN_BIT_WIDTH-1:0] w_min;
    wire [HOUR_BIT_WIDTH-1:0] w_hour;

    button_debounce dut_btn_mode (
        .clk  (clk),
        .reset(rst),
        .i_btn(btnU),
        .o_btn(w_btn_mode)
    );

    button_debounce dut_btn_clear (
        .clk  (clk),
        .reset(rst),
        .i_btn(btnL),
        .o_btn(w_btn_clear)
    );


    button_debounce dut_btn_runstop (
        .clk  (clk),
        .reset(rst),
        .i_btn(btnR),
        .o_btn(w_btn_run_stop)
    );


    controll_unit dut_controll_unit (
        .clk(clk),
        .reset(rst),
        .btn_run_stop(w_btn_run_stop),
        .btn_clear(w_btn_clear),
        .btn_mode(w_btn_mode),
        .clear(w_clear),
        .run_stop(w_run_stop),
        .mode(w_mode)
    );



    stopwatch_datapass dut_stopwatch (
        .clk(clk),
        .rst(rst),
        .run_stop(w_run_stop),
        .clear(w_clear),
        .mode(w_mode),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour)
    );


    fnd_controller dut_fnd_controller (
    .clk(clk), 
    .rst(rst),
    .sw_display_mode(sw_display_mode),
    .msec(w_msec),
    .sec(w_sec),
    .min(w_min),
    .hour(w_hour),
    .fnd_com(fnd_com),
    .fnd_font(fnd_font)
    );
endmodule




module stopwatch_datapass #(
    parameter MSEC_BIT_WIDTH = 7,
    parameter SEC_BIT_WIDTH  = 6,
    parameter MIN_BIT_WIDTH  = 6,
    parameter HOUR_BIT_WIDTH = 5
) (
    input clk,
    input rst,
    input run_stop,
    input clear,
    input mode,
    output [MSEC_BIT_WIDTH-1:0] msec,
    output [SEC_BIT_WIDTH-1:0]    sec,
    output [MIN_BIT_WIDTH-1:0]  min,
    output [HOUR_BIT_WIDTH-1:0] hour
);


    wire w_tick_10ms, w_tick_sec, w_tick_min, w_tick_hour;

    //hour
    tick_counter #(
        .TIMES(24),
        .BIT_WIDTH(HOUR_BIT_WIDTH)
    ) dut_hour_counter (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_hour),
        .clear(clear),
        .mode(mode),
        .time_count(hour),
        .o_tick()
    );


    //min
    tick_counter #(
        .TIMES(60),
        .BIT_WIDTH(MIN_BIT_WIDTH)
    ) dut_min_counter (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_min),
        .clear(clear),
        .mode(mode),
        .time_count(min),
        .o_tick(w_tick_hour)
    );

    //sec
    tick_counter #(
        .TIMES(60),
        .BIT_WIDTH(SEC_BIT_WIDTH)
    ) dut_sec_counter (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_sec),
        .clear(clear),
        .mode(mode),
        .time_count(sec),
        .o_tick(w_tick_min)
    );

    //msec
    tick_counter #(
        .TIMES(100),
        .BIT_WIDTH(MSEC_BIT_WIDTH)
    ) dut_msec_counter (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_10ms),
        .clear(clear),
        .mode(mode),
        .time_count(msec),
        .o_tick(w_tick_sec)
    );

    tick_gen_100hz dut_tick_gen (
        .clk(clk),
        .rst(rst),
        .run_stop(run_stop),
        .clear(clear),
        .o_tick(w_tick_10ms)  //100hz tick
    );
endmodule




module tick_counter #(
    parameter TIMES = 100,
    BIT_WIDTH = 7
) (
    input clk,
    input rst,
    input i_tick,
    input clear,
    input mode,
    output [BIT_WIDTH-1:0] time_count,
    output reg o_tick
);

    reg [$clog2(TIMES)-1:0] counter_reg;
    assign time_count = counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst | clear) begin
            counter_reg <= 0;
            o_tick      <= 1'b0;
        end else begin
            if (mode) begin
                //down
                if (i_tick) begin
                    counter_reg <= counter_reg - 1;
                    if (counter_reg == 0) begin
                        counter_reg <= TIMES - 1;
                        o_tick      <= 1'b1;
                    end
                end else o_tick <= 1'b0;
            end else begin
                //up
                if (i_tick) begin
                    counter_reg <= counter_reg + 1;
                    if (counter_reg == (TIMES - 1)) begin
                        counter_reg <= 0;
                        o_tick      <= 1'b1;
                    end
                end else o_tick <= 1'b0;
            end
        end
    end

endmodule



module tick_gen_100hz (
    input clk,
    input rst,
    input run_stop,
    input clear,
    output reg o_tick  //100hz tick
);
    parameter F_COUNT = 100_000_000 / 100;
    reg [$clog2(F_COUNT)-1 : 0] counter_reg;

    //reg tick;
    //assign o_tick = tick;

    always @(posedge clk, posedge rst) begin
        if (rst | clear) begin
            counter_reg <= 0;
            o_tick    <= 1'b0;
        end else begin
            if (run_stop) begin
                counter_reg <= counter_reg + 1;
                if (counter_reg == (F_COUNT - 1)) begin
                    counter_reg <= 0;
                    o_tick <= 1'b1;
                end else begin
                    o_tick <= 1'b0;
                end
            end else begin
                //previous o_tick was 1'b1 && run_stop 1 -> 0 
                //run_stop 1에서 0으로 바뀌는 상황에서 계속 o_tick이 1로 남을 수 있음
                o_tick <= 1'b0;
            end
        end
    end



endmodule
