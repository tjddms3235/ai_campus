`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/01 11:39:24
// Design Name: 
// Module Name: tb_simul
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


module tb_simul();

reg [7:0] a;
reg [7:0] b;

wire [7:0] s;
wire c;
    adder_8bit dut(
        .a(a),
        .b(b),
        .s(s),
        .c(c)
    );
    

    integer i, j;
    initial begin
        
        for( i = 0; i<256; i = i +1) begin
            for(j = 0; j<256; j = j +1) begin
                a = i;
                b = j;
                #10;
            end
        end
        $finish;
    end    
endmodule
