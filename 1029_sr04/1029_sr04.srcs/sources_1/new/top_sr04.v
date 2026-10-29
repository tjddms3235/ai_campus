`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/29 09:05:39
// Design Name: 
// Module Name: top_sr04
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

module top_sr04 (
    input        clk,
    input        rst,
    input        btnR,
    input        echo,
    output [3:0] fnd_com,
    output [7:0] fnd_font,
    output       trig
);

    wire w_us_tick;
    wire w_sr_04_start;
    wire [8:0] w_distance;

    button_debounce U_BTN_DB (
        .clk  (clk),
        .reset(rst),
        .i_btn(btnR),
        .o_btn(w_sr_04_start)
    );
    sr04_controller U_SR04_CNTL (
        .clk(clk),
        .rst(rst),
        .sr04_start(w_sr_04_start),
        .echo(echo),
        .us_tick(w_us_tick),
        .trig(trig),
        .distance(w_distance)
    );

    tick_gen_us U_TICK_GEN_US (
        .clk(clk),
        .rst(rst),
        .us_tick(w_us_tick)
    );

    fnd_controller U_FND_CNTL (

        .clk(clk),
        .reset(rst),
        .fnd_data({5'b00000, w_distance}),
        .fnd_com(fnd_com),
        .fnd_font(fnd_font)
    );

endmodule
