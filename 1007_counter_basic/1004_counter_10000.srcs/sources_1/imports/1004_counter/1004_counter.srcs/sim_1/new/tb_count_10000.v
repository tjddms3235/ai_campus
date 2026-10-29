`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/07 14:12:16
// Design Name: 
// Module Name: tb_count_10000
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


module tb_count_10000();
    reg clk,reset;
    
    wire [13:0] counter;


counter_datapass DUT_counter_datapass(
    .clk(clk),
    .reset(reset),
    .counter(counter)
);

    always #5 clk=~clk;
    
    initial begin
        
        clk =0;
        reset = 1;
        #10;
        reset = 0;

        repeat(3)
            #(10_000_000*10);
        $stop;
    end


endmodule