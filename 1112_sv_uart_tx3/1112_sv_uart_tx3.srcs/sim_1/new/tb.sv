`timescale 1ns / 1ps

interface uart_interface(input clk);
    logic        clk;
    logic        rst;
    logic        start;
    logic [7:0]  tx_data;
    logic        tx;
    logic        tx_busy;
endinterface

module tb();


    uart dut_uart(
    .clk(clk),
    .rst(rst),
    .start(),
    .tx_data(),
    .tx(),
    .tx_busy()
    );


endmodule
