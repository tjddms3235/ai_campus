`timescale 1ns / 1ps

// ComPortMaster에서 ASCII "3"을 보내면 아래 DHT11 테스트 값을 한 번 전송합니다.
// 출력: H=046.00 %RH T=025.50 C (줄바꿈 없음)
module UART_FIFO_ASCII (
    input        clk,
    input        rst,
    input        rx,
    output       tx,
    output [3:0] fnd_com,
    output [7:0] fnd_font
);
    wire [7:0] w_rx_pop_data;
    wire w_rx_available;
    wire w_rx_pop;

    wire uart_R, uart_L, uart_U, uart_D;
    wire stopwatch, watch, sr04_start, dht11_start;

    wire [7:0] w_sender_data;
    wire w_sender_push;
    wire w_fifo_tx_full;
    wire w_sender_ready;
    wire w_sender_busy;

    // 소수 바이트는 백분율 자리: 50 -> 0.50도입니다.
    // 체크섬: 46 + 0 + 25 + 50 = 121
    wire [39:0] w_dht11_test_data;
    assign w_dht11_test_data = {8'd46, 8'd0, 8'd25, 8'd50, 8'd121};

    // 이번 UART 출력 시험에서는 FND를 사용하지 않습니다. active-low 출력 끄기.
    assign fnd_com  = 4'b1111;
    assign fnd_font = 8'hFF;

    uart_fifo_loopback U_UART_FIFO_LOOPBACK (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .fifo_rx_pop(w_rx_pop),
        .fifo_tx_push(w_sender_push),
        .fifo_tx_push_data(w_sender_data),
        .fifo_tx_full(w_fifo_tx_full),
        .tx(tx),
        .rx_pop_data(w_rx_pop_data),
        // 기존 모듈의 rx_empty는 이름과 달리 '데이터 있음'일 때 1입니다.
        .rx_empty(w_rx_available)
    );

    ascii_decoder U_ASCII_DECODER (
        .clk(clk),
        .rst(rst),
        // sender가 받을 수 있을 때만 RX FIFO에서 명령을 꺼냅니다.
        .enable(w_rx_available && w_sender_ready),
        .ascii(w_rx_pop_data),
        .pop(w_rx_pop),
        .uart_R(uart_R),
        .uart_L(uart_L),
        .uart_U(uart_U),
        .uart_D(uart_D),
        .stopwatch(stopwatch),
        .watch(watch),
        .sr04_start(sr04_start),
        .dht11_start(dht11_start)
    );

    ascii_sender #(.DHT11_WITH_CHECKSUM(1)) U_ASCII_SENDER (
        .clk(clk),
        .rst(rst),
        .done(dht11_start),
        .vaild(1'b1),
        .data_type(2'b11),
        .input_data(w_dht11_test_data),
        .fifo_full(w_fifo_tx_full),
        .fifo_data(w_sender_data),
        .push(w_sender_push),
        .ready(w_sender_ready),
        .sender_busy(w_sender_busy)
    );
endmodule
