`timescale 1ns / 1ps


module uart(
    input  logic        clk,
    input  logic        rst,
    input  logic        start,
    input  logic [7:0]  tx_data,
    output logic        tx,
    output logic        tx_busy
    );

    logic b_tick;
    sv_uart_tx U_SV_UART_TX(.*);

    baud_tick_gen U_baud_tick_gen(.*);
endmodule


module baud_tick_gen(
    input  logic clk,
    input  logic rst,
    output logic b_tick
);
    parameter DIV_COUNT= 100_000_000/9600*16;
    logic [$clog2(DIV_COUNT)-1 :0] counter;

    

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            counter <= 0;
            b_tick <= 1'b0;
        end
        else begin
            counter <= counter+1; 
            if(counter == DIV_COUNT -1) begin
                counter <= 0;
                b_tick <= 1'b1;
            end
            else begin
                b_tick <=1'b0;
            end
        end
    end
endmodule