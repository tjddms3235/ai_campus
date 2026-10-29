`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/12 16:26:14
// Design Name: 
// Module Name: button_debounce
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


module button_debounce(
    input clk,
    input reset,
    input i_btn,
    output o_btn
    );

    //8bit shift register : sipo
    reg [7:0] q_reg;
    wire debounce; //debounced 
    reg edge_reg; //edge detect signal

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            q_reg <= 8'h00;
        end
        else begin 
            q_reg <= {i_btn,q_reg[7:1]}; //right shift , msb : in, 7:1-> 6:0
        end 
    end

    //8input and gate
    assign debounce = &q_reg;


   
    //edge detection
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            edge_reg <= 1'b0;
        end
        else begin
            edge_reg <= debounce;
        end
    end

    assign o_btn = ~edge_reg & debounce;
endmodule
