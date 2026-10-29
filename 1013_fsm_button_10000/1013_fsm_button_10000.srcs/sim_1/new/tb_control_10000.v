`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/13 14:34:13
// Design Name: 
// Module Name: tb_control_10000
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


module tb_control_10000();
 reg clk, reset, btnR, btnL,btnU;
 parameter BT_PUSH_TIME = 1000;
 wire [3:0] fnd_com;
 wire [7:0] fnd_font;

 counter_10000 dut_10000(
    .clk(clk),
    .reset(reset),
    .btnR(btnR), //run_stop
    .btnL(btnL), //clear
    .btnU(btnU), //mode
    .fnd_com(fnd_com),
    .fnd_font(fnd_font)
    );


always #5 clk = ~ clk;

initial begin
    clk = 0;
    reset = 1;
    btnR = 0;
    btnL = 0;
    btnU = 0;

    #10;
    reset = 0;

    //senario 0 : runstop btn1 push/pop
    btnR = 1; 
    repeat (BT_PUSH_TIME) @(posedge clk);
    btnR = 0;
    //run state
    repeat (3) begin
        #(10_000_000*10);
    end

    //rusn to stop state
    btnR = 1; 
    repeat (BT_PUSH_TIME) @(posedge clk);
    btnR = 0;
    
    $stop;

end
endmodule
