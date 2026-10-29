`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/14 14:06:32
// Design Name: 
// Module Name: tb2_stopwatch
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



module tb_control_10000 ();
    //10clk *1mhz
    parameter BT_PUSH_TIME = 10*100;
    parameter MSEC = 100_000*10;

    reg sw_display_mode;

    reg clk, rst, btnR, btnL, btnU;


    wire [3:0] fnd_com;
    wire [7:0] fnd_font;

    stop_watch tb_stopwatch (
        .clk(clk),
        .rst(rst),
        .btnR(btnR),
        .btnL(btnL),
        .btnU(btnU),
        .sw_display_mode(sw_display_mode),
        .fnd_com(fnd_com),
        .fnd_font(fnd_font)
    );



    always #5 clk = ~clk;

    initial begin
        clk  = 0;
        rst  = 1;
        btnR = 0;
        btnL = 0;
        btnU = 0;
        sw_display_mode = 1'b0;
        #10;
        rst  = 0;

        //senario 0 : runstop btn1 push/pop
        btnR = 1;
        repeat (BT_PUSH_TIME) @(posedge clk);
        btnR = 0;
        //run  1sec
        repeat (100) begin
            #(MSEC*10);
        end
        
        #(MSEC);

        //to change of fnd display mode : sec_msec -> hour_min
        sw_display_mode = 1'b1;

        //run 100msec
        repeat (10) begin
            #(MSEC*10);
        end 

         #(MSEC);

        //to change of fnd display mode : hour_min -> sec_msec
        sw_display_mode = 1'b0;
        #(MSEC*10);


        //rusn to stop state
        btnR = 1;
        repeat (BT_PUSH_TIME) @(posedge clk);
        btnR = 0;
        
        
        //stop_state


        $stop;

    end
endmodule
