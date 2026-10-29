`timescale 1ns / 1ps

module tb_adder_fnd;

    //========================================================
    // Testbench Signal
    //========================================================
    reg  [7:0] a;
    reg  [7:0] b;
    reg  [1:0] ds_sel;

    wire [3:0] fnd_com;
    wire [7:0] fnd_font;


    //========================================================
    // DUT : TOP Module
    //========================================================
    adder_fnd DUT (
        .a(a),
        .b(b),
        .ds_sel(ds_sel),
        .fnd_com(fnd_com),
        .fnd_font(fnd_font)
    );


    //========================================================
    // Test
    //========================================================
    initial begin

        // 초기값
        a      = 8'd0;
        b      = 8'd0;
        ds_sel = 2'b00;

        #10;


        //====================================================
        // TEST 1 : 8 + 0 = 8
        //====================================================
        a = 8'd8;
        b = 8'd0;
        #10;

        $display("----------------------------------------");
        $display("TEST 1 : 8 + 0");
        $display("a       = %d", a);
        $display("b       = %d", b);
        $display("w_s     = %d", DUT.w_s);
        $display("w_c     = %b", DUT.w_c);
        $display("TOTAL   = %d", {DUT.w_c, DUT.w_s});


        //====================================================
        // TEST 2 : 8 + 8 = 16
        //====================================================
        a = 8'd8;
        b = 8'd8;
        #10;

        $display("----------------------------------------");
        $display("TEST 2 : 8 + 8");
        $display("a       = %d", a);
        $display("b       = %d", b);
        $display("w_s     = %d", DUT.w_s);
        $display("w_c     = %b", DUT.w_c);
        $display("TOTAL   = %d", {DUT.w_c, DUT.w_s});


        //====================================================
        // TEST 3 : 15 + 1 = 16
        // Carry 확인
        //====================================================
        a = 8'd15;
        b = 8'd1;
        #10;

        $display("----------------------------------------");
        $display("TEST 3 : 15 + 1");
        $display("w_s     = %d", DUT.w_s);
        $display("w_c     = %b", DUT.w_c);
        $display("TOTAL   = %d", {DUT.w_c, DUT.w_s});


        //====================================================
        // TEST 4 : 247 + 247 = 494
        //====================================================
        a = 8'd247;
        b = 8'd247;
        #10;

        $display("----------------------------------------");
        $display("TEST 4 : 247 + 247");
        $display("w_s     = %d", DUT.w_s);
        $display("w_c     = %b", DUT.w_c);
        $display("TOTAL   = %d", {DUT.w_c, DUT.w_s});


        //====================================================
        // TEST 5 : 최대값
        // 255 + 255 = 510
        //====================================================
        a = 8'd255;
        b = 8'd255;
        #10;

        $display("");
        $display("========================================");
        $display("MAXIMUM VALUE TEST");
        $display("========================================");

        $display("a       = %d", a);
        $display("b       = %d", b);

        $display("w_s     = %d", DUT.w_s);
        $display("w_s(bin)= %b", DUT.w_s);

        $display("w_c     = %b", DUT.w_c);

        $display("----------------------------------------");
        $display("TOTAL   = %d", {DUT.w_c, DUT.w_s});
        $display("----------------------------------------");


        // 자동 판정
        if ({DUT.w_c, DUT.w_s} == 9'd510)
            $display("RESULT : PASS -> 255 + 255 = 510");
        else
            $display("RESULT : FAIL -> result = %d",
                     {DUT.w_c, DUT.w_s});


        //====================================================
        // FND 출력 확인
        // ds_sel을 하나씩 변경
        //====================================================

        $display("");
        $display("========================================");
        $display("FND TEST : 510");
        $display("========================================");


        // 1의 자리
        ds_sel = 2'b00;
        #10;

        $display(
            "ds_sel=00 | fnd_com=%b | fnd_font=%h",
            fnd_com,
            fnd_font
        );


        // 10의 자리
        ds_sel = 2'b01;
        #10;

        $display(
            "ds_sel=01 | fnd_com=%b | fnd_font=%h",
            fnd_com,
            fnd_font
        );


        // 100의 자리
        ds_sel = 2'b10;
        #10;

        $display(
            "ds_sel=10 | fnd_com=%b | fnd_font=%h",
            fnd_com,
            fnd_font
        );


        // 1000의 자리
        ds_sel = 2'b11;
        #10;

        $display(
            "ds_sel=11 | fnd_com=%b | fnd_font=%h",
            fnd_com,
            fnd_font
        );


        $display("========================================");
        $display("Simulation Finish");
        $display("========================================");

        $finish;

    end

endmodule