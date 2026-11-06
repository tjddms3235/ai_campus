`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/06 09:50:25
// Design Name: 
// Module Name: counter_256
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


module counter_256(
    input logic clk,
    input logic rst,
    output logic [7:0] counter
    );

    always_ff @(posedge clk , posedge rst) begin
        if(rst)begin
            counter <= 0;
        end else begin
            counter <= counter+1;
        end
    end
endmodule
