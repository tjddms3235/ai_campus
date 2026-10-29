`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/21 09:22:00
// Design Name: 
// Module Name: tb
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



 module tb();
     parameter BT_PUSH_TIME = 1500;    // 15us
     parameter MSEC = 1_000_000;       // 1ms
     reg clk, rst;
     reg btnR, btnL, btnU, btnD;
     reg [1:0] sw;
     wire [3:0] fnd_com;
     wire [7:0] fnd_font;
     // DUT
     watch dut_top (
         .clk(clk),
         .rst(rst),
         .btnL(btnL),
         .btnR(btnR),
         .btnU(btnU),
         .btnD(btnD),
         .sw(sw),
         .fnd_com(fnd_com),
         .fnd_font(fnd_font)
     );
     // 100MHz Clock
     always #5 clk = ~clk;
     // Button R
     task push_R;
     begin
         btnR = 1;
         repeat (BT_PUSH_TIME) @(posedge clk);
         btnR = 0;
         repeat (BT_PUSH_TIME) @(posedge clk);
     end
     endtask
     // Button L
     task push_L;
     begin
         btnL = 1;
         repeat (BT_PUSH_TIME) @(posedge clk);
         btnL = 0;
         repeat (BT_PUSH_TIME) @(posedge clk);
     end
     endtask
     // Button U
     task push_U;
     begin
         btnU = 1;
         repeat (BT_PUSH_TIME) @(posedge clk);
         btnU = 0;
         repeat (BT_PUSH_TIME) @(posedge clk);
     end
     endtask
     initial begin
         // Initialize
         clk  = 0;
         rst  = 1;
         btnR = 0;
         btnL = 0;
         btnU = 0;
         btnD = 0;
         sw = 2'b00;  // Stopwatch Mode
         repeat (10) @(negedge clk);
         rst = 0;
         #(MSEC);

         // 1. RUN
         push_R();
         // Run : 800ms
          push_U();
          #200
          push_L();
          #200
         #(MSEC * 1000);
         // 2. STOP
         push_R();
         // Stop : 300ms
         #(MSEC * 100);
         //3. MODE
         push_U();
         #(MSEC * 100);
         // 2. RUN
         push_R();
         // Down Count : 3sec
         #(MSEC * 1100);
         // 3. STOP
         push_R();
         #(MSEC * 100);
         // 5. CLEAR
         push_L();
         // Wait : 300ms
         #(MSEC * 100);
       $stop;
     end
 endmodule

//-------------------------
// watch tset
//
// `timescale 1ns / 1ps
//
// module tb;
//
//     // 1. 입력 신호
//     reg clk = 0;
//     reg rst = 0;
//     reg btnL = 0;
//     reg btnR = 0;
//     reg btnU = 0;
//     reg btnD = 0;
//     reg [1:0] sw = 2'b10;
//
//     wire [3:0] fnd_com;
//     wire [7:0] fnd_font;
//
//     
//     watch dut (
//         .clk(clk),
//         .rst(rst),
//         .btnL(btnL),
//         .btnR(btnR),
//         .btnU(btnU),
//         .btnD(btnD),
//         .sw(sw),
//         .fnd_com(fnd_com),
//         .fnd_font(fnd_font)
//     );
//
//   
//     always #5 clk = ~clk;
//
//   
//     defparam dut.U_BTN_L.F_COUNT = 100;
//     defparam dut.U_BTN_R.F_COUNT = 100;
//     defparam dut.U_BTN_U.F_COUNT = 100;
//     defparam dut.U_BTN_D.F_COUNT = 100;
//
//     //  파형에서 보기 편하도록 내부 신호에 이름 붙이기
//     wire [1:0] current_digit = dut.w_current_digit;
//     wire [4:0] hour   = dut.w_w_hour;
//     wire [5:0] minute = dut.w_w_min;
//     wire [5:0] second = dut.w_w_sec;
//     wire pulse_L = dut.w_btnL;
//     wire pulse_R = dut.w_btnR;
//     wire pulse_U = dut.w_btnU;
//     wire pulse_D = dut.w_btnD;
//
//     initial begin

//         // sw[0]=0: watch, sw[1]=1: 시/분
//         #1;
//         rst = 1;
//         #100;
//         rst = 0;
//         #10000;
//
//
//
//         // 분 일의 자리 감소: 00 -> 59
//         btnD = 1; #30000; btnD = 0; #30000;
///
//         // L 1회: 분 십의 자리 선택 (current_digit = 01)
//         btnL = 1; #30000; btnL = 0; #30000;
//
//         // 분 십의 자리 감소: 59 -> 49
//         btnD = 1; #30000; btnD = 0; #30000;
//
//         // R 1회: 분 일의 자리 선택 (current_digit = 00)
//         btnR = 1; #30000; btnR = 0; #30000;
//
//         // 분 일의 자리 2회 증가: 49 -> 50 -> 51
//         btnU = 1; #30000; btnU = 0; #30000;
//         btnU = 1; #30000; btnU = 0; #30000;
//
//         // L 3회: 분 십 -> 시 일 -> 시 십 (01 -> 10 -> 11)
//         btnL = 1; #30000; btnL = 0; #30000;
//         btnL = 1; #30000; btnL = 0; #30000;
//         btnL = 1; #30000; btnL = 0; #30000;
//
//         // 시 십의 자리 2회 증가: 12 -> 22 -> 02
//         btnU = 1; #30000; btnU = 0; #30000;
//         btnU = 1; #30000; btnU = 0; #30000;
//
//         // 초 표시/조정 모드로 변경
//         // current_digit=11이 유지되므로 바로 초 십의 자리가 선택됨
//         sw = 2'b00;
//         #10000;
//
//         // 초 십의 자리 증가: 00 -> 10
//         btnU = 1; #30000; btnU = 0; #30000;
//       
//         btnD = 1; #30000; btnD = 0; #30000;
//         btnD = 1; #30000; btnD = 0; #30000;
//
//
//
//         #10000;
//         $finish;
//     end
//
// endmodule

//-------------------
// msec 95   s up_ count 9 
//total 09:95 -> 10:00 
// 
// `timescale 1ns / 1ps
//
// module tb();
//
//     parameter BT_PUSH_TIME = 1500;    // 15us
//     parameter MSEC = 1_000_000;       // 1ms
//
//     reg clk, rst;
//     reg btnR, btnL, btnU, btnD;
//     reg [1:0] sw;
//
//     wire [3:0] fnd_com;
//     wire [7:0] fnd_font;
//
//     // DUT
//     watch dut_top (
//         .clk(clk),
//         .rst(rst),
//         .btnL(btnL),
//         .btnR(btnR),
//         .btnU(btnU),
//         .btnD(btnD),
//         .sw(sw),
//         .fnd_com(fnd_com),
//         .fnd_font(fnd_font)
//     );
//
//     // 100MHz Clock
//     always #5 clk = ~clk;
//
//     // Button R
//     task push_R;
//     begin
//         btnR = 1;
//         repeat (BT_PUSH_TIME) @(posedge clk);
//         btnR = 0;
//         repeat (BT_PUSH_TIME) @(posedge clk);
//     end
//     endtask
//
//     // Button L
//     task push_L;
//     begin
//         btnL = 1;
//         repeat (BT_PUSH_TIME) @(posedge clk);
//         btnL = 0;
//         repeat (BT_PUSH_TIME) @(posedge clk);
//     end
//     endtask
//
//     // Button U
//     task push_U;
//     begin
//         btnU = 1;
//         repeat (BT_PUSH_TIME) @(posedge clk);
//         btnU = 0;
//         repeat (BT_PUSH_TIME) @(posedge clk);
//     end
//     endtask
//
//     initial begin
//
//         
//         clk  = 0;
//         rst  = 1;
//
//         btnR = 0;
//         btnL = 0;
//         btnU = 0;
//         btnD = 0;
//
//         sw = 2'b00; 
//
//         repeat (10) @(negedge clk);
//         rst = 0;
//
//         #(MSEC);
//
//         repeat (2) begin
//             btnL = 1; #30000; // HIGH 30 us
//             btnL = 0; #30000; // LOW  30 us
//         end
//       
//         #(MSEC * 950);
//
//         repeat (9) begin
//             btnU = 1; #30000;
//             btnU = 0; #30000;
//         end
//
//         #(MSEC * 100);
//         #1000;
//         $finish;
//     end
// endmodule

