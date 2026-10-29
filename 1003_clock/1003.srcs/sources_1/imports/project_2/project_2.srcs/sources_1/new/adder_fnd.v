`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/04 11:09:58
// Design Name: 
// Module Name: adder_fnd
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


module adder_fnd(
    input [7:0] a,
    input [7:0] b,
    input [1:0] ds_sel,
    output [3:0] fnd_com,
    output [7:0] fnd_font,
    input clk, 
    input reset
    );

    wire [7:0] w_s;
    wire w_c;

    adder_8bit DUT_adder_8bit(
        .a(a),
        .b(b),
        .cin(1'b0),
        .s(w_s),
        .c(w_c)
    );

    fnd_controller DUT_fnd_controllzzer(
       
        .fnd_data({w_c, w_s}),
        .fnd_com(fnd_com),
        .fnd_font(fnd_font),
        .clk(clk),
        .reset(reset)
    );
endmodule
