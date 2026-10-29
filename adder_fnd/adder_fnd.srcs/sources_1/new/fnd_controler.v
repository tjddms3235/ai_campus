`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/02 15:36:57
// Design Name: 
// Module Name: fnd_controler
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


module fnd_controler(
    input  [1:0] ds_sel,
    input  [8:0] ds_data,
    output [3:0] fnd_com,
    output [7:0] fnd_font
    );

    
    assign fnd_com = 4'b1110;
    
    bcd U_bcd(
        .bin(w_bin),
        .fnd_font(fnd_font)
    );

endmodule
module bcd(
    input [3:0] bin,
    output reg [7:0] fnd_font
);

    always @(bin) begin
        case (bin)
            4'b0000 : fnd_font = 8'hc0;
            4'b0001 : fnd_font = 8'hf9;
            4'b0010 : fnd_font = 8'ha4;
            4'b0011 : fnd_font = 8'hb0;
            4'b0100 : fnd_font = 8'h99;
            4'b0101 : fnd_font = 8'h92;
            4'b0110 : fnd_font = 8'h82;
            4'b0111 : fnd_font = 8'hf8;
            4'b1000 : fnd_font = 8'h80;
            4'b1001 : fnd_font = 8'h90;
            4'b1010 : fnd_font = 8'h88;
            4'b1011 : fnd_font = 8'h83;
            4'b1100 : fnd_font = 8'h86;
            4'b1101 : fnd_font = 8'h8e;
            default : fnd_font = 8'hff;    

        endcase
    
    end

endmodule 