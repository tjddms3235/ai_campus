`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/20 22:56:46
// Design Name: 
// Module Name: tb_uart1
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



// module tb_uart1 ();
//     parameter BAUD_BIT_PEROID = 100_000_000 / 9600 * 10;
   
//     reg clk, rst, rx;
//     reg [7:0] result_data, expected_data;
//     wire tx;

//     uart_loopback daut_uart (
//         .clk (clk),
//         .rst (rst),
//         .rx  (rx),
//         .tx  (tx)
//     );
//     always #5 clk = ~clk;
    
//     task sender_uart(input [7:0] send_data);
//         integer i;
//         begin
//             rx =0;
//             #(BAUD_BIT_PEROID);
//             for (i = 0; i < 8; i = i + 1) begin
//                 rx = send_data[i];
//                 #(BAUD_BIT_PEROID);
//             end 
//             rx=1;  //stop bit
//             #(BAUD_BIT_PEROID);
//         end
//     endtask

    
//     task receive_uart(output [7:0] rx_data );
//     integer i;

//         begin
//             wait (~tx);
//             #(BAUD_BIT_PEROID / 2);
//             //check start bit 0 
//             if (tx != 0) $display("error start bit ");

//             for (i = 0; i < 8; i = i + 1) begin
//                 #(BAUD_BIT_PEROID);
//                 rx_data[i] = tx;
//             end
//             #(BAUD_BIT_PEROID);
//             if (!tx) $display("error stop bit");
//         end
//     endtask






//     initial begin
//         clk  = 0;
//         rst  = 1;
//         rx = 1;
//         expected_data = 8'h30;
    
//         #10 rst = 0;

//         sender_uart(expected_data);
//         receive_uart(result_data);

//         #100;

//         //compare result data and expected data
//         if (result_data == expected_data ) $display("pass!!!");
//         else $display("fail");

//         $stop;

//     end
// endmodule




module tb_uart1 ();
    parameter BAUD_BIT_PEROID = 100_000_000 / 9600 * 10;
   
    reg clk, rst, rx;
    reg [7:0] result_data, expected_data;
    wire tx;

    uart_loopback daut_uart (
        .clk (clk),
        .rst (rst),
        .rx  (rx),
        .tx  (tx)
    );
    always #5 clk = ~clk;
    
    task sender_uart(input [7:0] send_data);
        integer i;
        begin
            rx =0;
            #(BAUD_BIT_PEROID);
            for (i = 0; i < 8; i = i + 1) begin
                rx = send_data[i];
                #(BAUD_BIT_PEROID);
            end 
            rx=1;  //stop bit
            #(BAUD_BIT_PEROID);
        end
    endtask

    
    task receive_uart(output [7:0] rx_data );
    integer i;

        begin
            wait (~tx);
            #(BAUD_BIT_PEROID / 2);
            //check start bit 0 
            if (tx != 0) $display("error start bit ");

            for (i = 0; i < 8; i = i + 1) begin
                #(BAUD_BIT_PEROID);
                rx_data[i] = tx;
            end
            #(BAUD_BIT_PEROID);
            if (!tx) $display("error stop bit");
        end
    endtask

    task score_board(input [7:0] resrult, expected);
        begin
        
            //compare result data and expected data
            if (result_data == expected_data ) $display("pass!!!");
            else $display("fail");
        
        end
    endtask




    initial begin
        clk  = 0;
        rst  = 1;
        rx = 1;
        expected_data = 8'h30;
    
        #10 rst = 0;
        expected_data = $random() % 256;

        sender_uart(expected_data);
        receive_uart(result_data);
        score_board(result_data, expected_data);
       
        #100;
        $stop;

    end
endmodule
