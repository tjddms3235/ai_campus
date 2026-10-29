`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/21 11:24:38
// Design Name: 
// Module Name: ascii_decoder
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



`timescale 1ns / 1ps

module uart_ascii_decoderv2 (
    input        clk,
    input        rst,
    input        rx,
    output       tx,
    output [3:0] fnd_com,
    output [7:0] fnd_font
);
    wire w_rx_done;
    wire [7:0] w_rx_data;
    wire [3:0] w_bin;

    uart_loopback U_UART_LOOPBACK (
        .clk(clk),
        .rst(rst),
        .rx(rx),  // from PC
        .tx(tx),  // to PC
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)

    );
    ascii_decoder U_ASCII_DECODER (
        .clk   (clk),
        .rst   (rst),
        .enable(w_rx_done),
        .ascii (w_rx_data),
        .bin   (w_bin)
    );

    fnd_controller U_FND_CONTROLLER (
        .clk     (clk),
        .reset   (rst),
        .fnd_data(w_bin),
        .fnd_com (fnd_com),
        .fnd_font(fnd_font)
    );

endmodule

module ascii_decoder (
    input            clk,
    input            rst,
    input            enable,
    input      [7:0] ascii,
    output reg [3:0] bin


);
    reg [7:0] data_reg, data_next;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            data_reg <= 0;
        end else begin
            data_reg <= data_next;
        end
    end

    always @(*) begin
        bin = 4'h0;
        data_next = data_reg;
        if (enable == 1) begin
            data_next = ascii;
        end else begin
            case (data_reg)
                8'h30: bin = 4'h0;
                8'h31: bin = 4'h1;
                8'h32: bin = 4'h2;
                8'h33: bin = 4'h3;
                8'h34: bin = 4'h4;
                8'h35: bin = 4'h5;
                8'h36: bin = 4'h6;
                8'h37: bin = 4'h7;
                8'h38: bin = 4'h8;
                8'h39: bin = 4'h9;
                8'h41: bin = 4'ha;
                8'h42: bin = 4'hb;
                8'h43: bin = 4'hc;
                8'h44: bin = 4'hd;
                8'h45: bin = 4'he;
                8'h46: bin = 4'hf;
            endcase
        end

    end


endmodule