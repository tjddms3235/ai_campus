`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 16:11:09
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


module top_sr04(
    input clk,
    input rst,
    input sr04_start,
    input echo,
    output trig
    );

    wire w_us_tick;
sr04_controll_unit dut_sr04_controll_uni(
    .clk(clk),
    .rst(rst),
    .sr04_start(sr04_start),
    .us_tick(w_us_tick),
    .echo(echo),
    .trig(trig),
    .distance()
    );



us_tick_gen dut_us_tick_genz(
    .clk(clk),
    .rst(rst),
    //.enable,
    //.clear(clear),
    .us_tick(w_us_tick)
);

endmodule

