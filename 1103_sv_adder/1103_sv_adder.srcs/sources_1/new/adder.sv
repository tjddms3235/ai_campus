`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/03 10:35:33
// Design Name: 
// Module Name: adder
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


module adder (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic       mode,  //0:add, 1:sub
    output logic [9:0] s,
    output logic       c
);

    assign {c, s} = (mode) ? a - b : a + b;

    // always_comb begin
    //     {c,s} = a+b;
    // end

endmodule
