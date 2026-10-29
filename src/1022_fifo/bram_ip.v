`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/21 16:13:24
// Design Name: 
// Module Name: bram_ip
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


module bram_ip(
    input clk,
    input we,
    input [7:0] addr,
    input [7:0] wdata,
    //output reg [7:0] rdata //sl ouput
    output [7:0] rdata //cl output
    );

    reg [7:0] ram [0:255];  

    
    always @(posedge clk) begin
        if(we) ram[addr] <= wdata;
        //sl output
       // else rdata <=ram[addr];  
    end

    //cl output
   assign rdata = ram[addr];
endmodule
