`timescale 1ns / 1ps

module tb_fnd();

    //==================================================
    // Input / Output
    //==================================================
    reg  [7:0] a;
    reg  [7:0] b;
    reg  [1:0] de_sel;

    wire [3:0] fnd_com;
    wire [7:0] fnd_font;


    //==================================================
    // DUT
    //==================================================
    adder_fnd dut_adder_fnd(
        .a(a),
        .b(b),
        .ds_sel(de_sel),
        .fnd_com(fnd_com),
        .fnd_font(fnd_font)
    );


    //==================================================
    // 반복문 변수
    //==================================================
   
   
   
   
   
   
    integer i, j;
    initial begin
        for(i = 0; i < 256; i = i + 1) begin
            for(j = 0; j < 256; j = j + 1) begin
                a = i;
                b = j;
                de_sel = 2'b00;
                #10;
                de_sel = 2'b01;
                #10;
                de_sel = 2'b10;
                #10;
                de_sel = 2'b11;
                #10;
            end
        end
        $stop;
    end

endmodule