`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/01 15:12:00
// Design Name: 
// Module Name: adder_8bit
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


module adder_8bit(
    input [7:0] a,
    input [7:0] b,
    input cin,
    output [7:0] s,
    output c
    );
wire w_c1;
    full_adder_4bit dut_1( 
        .a(a[3:0]),
        .b(b[3:0]),
        .s(s[3:0]),
        .cin(cin),
        .c(w_c1)
    );

    full_adder_4bit dut_2(
        .a(a[7:4]),
        .b(b[7:4]),
        .s(s[7:4]),
        .cin(w_c1),
        .c(c)
    );

endmodule
