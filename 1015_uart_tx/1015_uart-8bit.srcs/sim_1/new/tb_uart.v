`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/15 14:38:19
// Design Name: 
// Module Name: tb_uart
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


module tb_uart();
    parameter BAUD_BIT_PEROID =100_000_000/9600*10;
    reg clk, rst,btnR;
    wire tx, led;

uart daut_uart(
    .clk(clk),
    .rst(rst),
    .btnR(btnR),
    .led(led),   //tx_busy
    .tx(tx)
);
    always #5 clk = ~clk;
    initial begin
        clk =0;
        rst = 1;
        btnR = 0;
        #10 rst =0;
        
        //push boutton tx_start
        btnR = 1;
        #(10*100*10);
        btnR = 0;

        //tx-
        #(BAUD_BIT_PEROID*10) // 1frame*10

        #100;
        $stop;

    end
endmodule
