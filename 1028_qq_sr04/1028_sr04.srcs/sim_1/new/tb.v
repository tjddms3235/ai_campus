`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 16:28:34
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
    reg clk, rst, sr04_start, echo;
    wire trig;

 top_sr04 dut_top(
    .clk(clk),
    .rst(rst),
    .sr04_start(sr04_start),
    .echo(echo),
    .trig(trig)
    );

    always #5 clk =~clk;

    initial begin
        clk =0;
        rst =1;
        sr04_start =0;
        echo =0;

        #10;
        rst =0;
        #10;
        //sr04_start btn
        @(negedge clk);
        sr04_start = 1;
        @(negedge clk);

        //monittor, sr04 trigger
        @(posedge trig);
        @(posedge trig);

        #(2000);
        echo =1;
        #(600*10); //10cm, 600*1usec

        echo =0;

        #(10_000_000);
        #(2000);
        $finish;


    end
endmodule
