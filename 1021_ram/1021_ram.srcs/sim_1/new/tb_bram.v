`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/21 16:23:51
// Design Name: 
// Module Name: tb_bram
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


module tb_bram ();
    reg clk, we;
    reg [7:0] addr, wdata;
    wire [7:0] rdata;

    bram_ip dut_bram (
        .clk(clk),
        .we(we),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 0;
        we = 0;
        addr = 0;
        wdata = 0;

        //write to ram
       @(negedge clk);
        #1; 
        we = 1;
        addr = 10;
        wdata = 8'h0a;

        @(negedge clk);
        #1;
        addr  = 11;
        wdata = 8'h0b;

        @(negedge  clk);
        #1;
        addr  = 31;
        wdata = 8'h0c;
        #1;
        @(negedge  clk);
        addr  = 32;
        wdata = 8'h0d;
       
        @(negedge clk);
        //read
        we = 0;
        @(negedge clk);
        
        addr = 10;
        @(negedge clk);
        addr = 11;
        @(negedge clk);
        addr = 31;
        @(negedge clk);
        addr = 32;
        @(negedge clk);
        $stop;





    end


endmodule
