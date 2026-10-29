`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/29 09:09:24
// Design Name: 
// Module Name: tb_sr04
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


module tb_sr04 ();

    reg clk, rst, sr04_start, echo;
    wire trig;

    top_sr04 dut (
        .clk       (clk),
        .rst       (rst),
        .sr04_start(sr04_start),
        .echo      (echo),
        .trig      (trig)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        sr04_start = 0;
        echo = 0;

        #10;
        rst = 0;
        #10;
        // sr04 start btn
        @(negedge clk);
        sr04_start = 1;
        @(negedge clk);

        // monitor, sr04 trigger 

        // start state
        @(posedge trig);
        @(negedge trig);

        #(2000);  // wait state

        echo = 1;  // distance state
        #(600 * 1_000);  // 10cm, 600*1usec

        echo = 0;
        // stop state
        #(10_000_000);
        #(2000);
        $finish;
    end


endmodule
