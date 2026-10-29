`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/01 10:22:10
// Design Name: 
// Module Name: adder
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
module adder_8bit(
    input [7:0] a,
    input [7:0] b,
    input cin,
    output [7:0] s,
    output c
    );
wire w_c1;
    full_adder_4bit dut_1( 
        .a(a[3:0]),
        .b(b[3:0]),
        .s(s[3:0]),
        .cin(cin),
        .c(w_c1)
    );

    full_adder_4bit dut_2(
        .a(a[7:4]),
        .b(b[7:4]),
        .s(s[7:4]),
        .cin(w_c1),
        .c(c)
    );

endmodule















module full_adder_4bit(
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [3:0] s,
    output c
    );
    
    wire w_c1, w_c2, w_c3;

   full_adder DUT_1(
    .a(a[0]),
    .b(b[0]),
    .cin(1'b0),
    .s(s[0]),
    .c(w_c1)
    );
    
   full_adder DUT_2(
    .a(a[1]),
    .b(b[1]),
    .cin(w_c1),
    .s(s[1]),
    .c(w_c2)
    );
    
   full_adder DUT_3(
    .a(a[2]),
    .b(b[2]),
    .cin(w_c2),
    .s(s[2]),
    .c(w_c3)
    );
    
   full_adder DUT_4(
    .a(a[3]),
    .b(b[3]),
    .cin(w_c3),
    .s(s[3]),
    .c(c)
    );
    



    
endmodule







module full_adder(
    input a, b, cin,
    output s, c
);
    wire s1, c1, c2;

    half_adder U_haf1(
    .a(a),
    .b(b),
    .s(s1),
    .c(c1)
    );

    half_adder U_haf2(
    .a(s1),
    .b(cin),
    .s(s),
    .c(c2)
    );
    
    assign c = c1 |  c2;
    
endmodule

module half_adder(
    input a, b,
    output s,c
    );

    assign s = a^b;
    assign c = a & b;

endmodule
