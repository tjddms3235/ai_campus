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

    reg [3:0] a;
    reg [3:0] b;
    wire led;
    wire [3:0] w_fnd_com;
    wire [7:0] w_fnd_font;
    
    adder4_fnd dut_fnd(
        .a(a),
        .b(b),
        .fnd_com(w_fnd_com),
        .fnd_font(w_fnd_font),
        .led(led)
    );



    integer i, j;
    initial begin

        a = 0;
        b = 0;
        #10
        for( i = 0; i<16; i = i +1) begin
           
                b = i;
                #10;
            
        end
        $finish;
    end    
endmodule
