`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/10 10:32:17
// Design Name: 
// Module Name: sv_sram
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

module ram_ip_sv (
    input              clk,
    input  logic [5:0] addr,
    input  logic [7:0] wdata,
    input  logic       we,
    output logic [7:0] rdata
);

    logic [7:0] ram[0:63];
    always @(posedge clk) begin
        if (we) begin
            ram[addr] <= wdata;
        end
    end
    assign rdata = ram[addr];

endmodule