`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/06 15:05:20
// Design Name: 
// Module Name: tb
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


module tb();
    reg clk, reset;
    wire o_clk_800hz;
    clk_div_800hz DUT_clk_div(
    .clk(clk),
    .reset(reset),
    .o_clk_800hz(o_clk_800hz)
);

    always #5 clk = ~clk;


    initial begin
        clk = 0;
        reset = 1;
        #10;
        reset =0;
        //250000clk * 10nsec(1clock cycle time)
        #(250_000*10);
        #100;
        $stop;
    end
endmodule
