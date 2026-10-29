`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/13 10:52:05
// Design Name: 
// Module Name: tb_fsm
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


module tb_fsm();

reg clk, reset,start;
wire mealy_out, moore_out, p_bit; 
reg [14:0] i_bit;  

pattern_mealy dut_meealy (
    .clk(clk),
    .reset(reset),
    .p_bit(p_bit),
    .mealy_out(mealy_out)

);
pattern_moore dut_moore (
    .clk(clk),
    .reset(reset),
    .p_bit(p_bit),
    .moore_out(moore_out)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    reset = 0;
    reset = 1;
    start = 0;
    
    #20 reset = 0;
    #10 start = 1;  
     
    repeat (20) @(posedge clk);
    
    #5 start = 0;
    #10;
    $finish;
   
end
assign p_bit = i_bit[14];

always @(posedge clk or posedge reset) begin
    if(reset) begin
        i_bit <= 15'b001101011010101;  
    end
    else begin
        if (start) i_bit <= {i_bit[13:0], 1'b0};
        else i_bit <= 15'b001101011010101;
    end
end





endmodule



 
 
