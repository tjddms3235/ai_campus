`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/30 12:38:49
// Design Name: 
// Module Name: us_tick_gen
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


module tick_gen_us (
    input clk,
    input rst,
    output reg us_tick
);

    parameter FREQ = 100_000_000 / 1_000_000;
    reg [$clog2(FREQ)-1:0] counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            us_tick     <= 0;
        end else begin
            counter_reg <= counter_reg + 1;

            if (counter_reg == (FREQ - 1)) begin
                counter_reg <= 0;
                us_tick <= 1'b1;
            end else begin
                us_tick <= 1'b0;
            end
        end
    end
endmodule