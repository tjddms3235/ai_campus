`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/09 09:22:02
// Design Name: 
// Module Name: sv_counter2
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


module counter_256_op(
    input logic clk,
    input logic rst,
    input logic mode,
    input logic run_stop,
    input logic clear,
    output logic [7:0] counter
    );

    always_ff @(posedge clk , posedge rst) begin
        if(rst | clear)begin
            counter <= 0;
        end else begin
            if(run_stop)begin
                if ( mode) begin
                    counter <= counter-1;
                end else begin
                    counter <= counter+1;
                end
            end
        end
    end
endmodule
