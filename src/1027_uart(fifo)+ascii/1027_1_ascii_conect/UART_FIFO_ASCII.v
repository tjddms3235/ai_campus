`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/27 12:58:20
// Design Name: 
// Module Name: UART_FIFO_ASCII
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


module UART_FIFO_ASCII(
    input   clk,
    input   rst,
    input   rx,
    output  tx,
    output [3:0] fnd_com,
    output [7:0] fnd_font
    );

    wire [7:0] w_rx_pop_data;
    wire [3:0] w_bin;
    wire w_rx_empty;

uart_fifo_loopback U_UART_FIFO_LOOPBACK(
    .clk(clk),
    .rst(rst),
    .rx(rx),   //from PC
    .tx(tx),
    .rx_pop_data(w_rx_pop_data),
    .rx_empty(w_rx_empty)     //to PC
);

ascii_decoder U_ASCII_DECODER(
    .clk(clk),
    .rst(rst),
    .enable(w_rx_empty),
    .ascii(w_rx_pop_data),
    .bin(w_bin)
);
fnd_controller U_FND_CONTROLLER(
    .clk(clk),
    .reset(rst),
    .fnd_data(w_bin),  // 9bit {c,s}
    .fnd_com(fnd_com),
    .fnd_font(fnd_font)
);



endmodule



