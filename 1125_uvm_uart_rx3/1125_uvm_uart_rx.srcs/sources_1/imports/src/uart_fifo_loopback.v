`timescale 1ns / 1ps
module uart_top (
    input       clk,
    input       rst,
    input       rx,
    input       tx_start,
    input [7:0] tx_data,
    input       rx_done,
    input [7:0] rx_data,  //from PC
    output      tx,    //to PC
    output      tx_busy
);
    wire w_b_tick;
    wire w_rx_done;

    uart_rx U_UART_RX (
        .clk    (clk),
        .rst    (rst),
        .b_tick (w_b_tick),
        .rx     (rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    //uart tx
    uart_tx U_UART_TX (
        .clk     (clk),
        .rst     (rst),
        .tx_start(tx_start),
        .tx_data (tx_data),
        .b_tick  (w_b_tick),
        .tx      (tx),
        .tx_busy (tx_busy)

    );

    baud_tick_gen U_BAUD_TICK_GEN (
        .clk   (clk),
        .rst   (rst),
        .b_tick(w_b_tick)
    );
endmodule


module baud_tick_gen (
    input      clk,
    input      rst,
    output reg b_tick
);
    // parameter F_COUNT = 100_000_000 / 9600;
    parameter F_COUNT = 100_000_000 / (9600 * 16);
    reg [$clog2(F_COUNT) -1:0] counter_reg;
    //100Mhz -> 9600hz
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            b_tick      <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == F_COUNT - 1) begin
                counter_reg <= 0;
                b_tick      <= 1'b1;
            end else begin
                b_tick <= 1'b0;
            end
        end
    end
endmodule