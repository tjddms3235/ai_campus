`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/12 12:27:37
// Design Name: 
// Module Name: mealy
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


// module mealy(
//     input clk,
//     input rst,
//     input din_bit,
//     output dout_bit
// );
//     reg [2:0] state_reg, next_state;

//     parameter start = 3'b000;
//     parameter rd0_once =3'b001;
//     parameter rd1_once =3'b010;
//     parameter rd0_twice =3'b011;
//     parameter rd1_twice =3'b100;

//     always @(state_reg or din_bit) begin
//         case(state_reg)
//             start :     if       (din_bit==0) next_state = rd0_once;
//                         else if  (din_bit==0) next_state = rd1_once;
//                         else                  next_state = start;
            
//             rd0_once :  if       (din_bit==0) next_state = rd0_twice;
//                         else if  (din_bit==1) next_state = rd1_once;
//                         else                  next_state = start;
            
//             rd0_twice : if       (din_bit==0) next_state = rd0_twice;
//                         else if  (din_bit==1) next_state = rd1_once;
//                         else                  next_state = start;
            
//             rd1_once :  if       (din_bit==0) next_state = rd0_once;
//                         else if  (din_bit==1) next_state = rd1_twice;
//                         else                  next_state = start;
            
//             rd1_twice : if       (din_bit==0) next_state = rd0_once;
//                         else if  (din_bit==1) next_state = rd1_twice;
//                         else                  next_state = start;
            
//             default : next_state = start;
//         endcase
            
//     end

//     always @(posedge clk or posedge rst) begin
//         if(rst ==1) state_reg <=start;
//         else        state_reg <=next_state;  
//     end   
//     //mealy
//     assign dout_bit = (((state_reg == rd0_twice)&&(din_bit==0) || (state_reg==rd1_twice) &&(din_bit==1))) ? 1:0;
    
//     //moore
//     //assign dout_bit =((state_reg == rd0_twice) || (state_reg == rd1_twice )) ? 1:0;
// endmodule



module pattern_mealy (
    input clk,
    input reset,
    input p_bit,
    output mealy_out

);
    reg [1:0] state_reg, next_state;

    parameter S0 = 2'b00;
    parameter S1 = 2'b01;
    parameter S2 = 2'b10;
    parameter S3 = 2'b11;

    always @(posedge clk or posedge reset) begin
        if(reset == 1)  state_reg <=S0;
        else            state_reg <=next_state;  
    end

    always @(*) begin
        case(state_reg)
            S0  :   if  (p_bit == 0)    next_state = S1;
                    else                next_state = S0;
            S1  :   if  (p_bit == 1)    next_state = S2;
                    else                next_state = S1;
            S2  :   if  (p_bit == 0)    next_state = S3;
                    else                next_state = S0;
            S3  :   if  (p_bit == 1)    next_state = S0;
                    else                next_state = S1;
        default : next_state = S0;
        endcase
    end
    
    //mealy
    assign mealy_out = (state_reg == S3) && (p_bit == 1); 

endmodule                  


module pattern_moore (
    input clk,
    input reset,
    input p_bit,
    output moore_out

);
    reg [2:0] state_reg, next_state;

    parameter S0 = 3'b000;
    parameter S1 = 3'b001;
    parameter S2 = 3'b010;
    parameter S3 = 3'b011;
    parameter S4 = 3'b100;

    always @(posedge clk or posedge reset) begin
        if(reset == 1)  state_reg <=S0;
        else            state_reg <=next_state;  
    end

    always @(*) begin
        case(state_reg)
            S0  :   if  (p_bit == 0)    next_state = S1;
                    else                next_state = S0;
            S1  :   if  (p_bit == 1)    next_state = S2;
                    else                next_state = S1;
            S2  :   if  (p_bit == 0)    next_state = S3;
                    else                next_state = S0;
            S3  :   if  (p_bit == 1)    next_state = S4;
                    else                next_state = S1;
            S4  :   if  (p_bit == 1)    next_state = S0;
                    else                next_state = S1;        
        default : next_state = S0;
        endcase
    end
    
    //moore
    assign moore_out = (state_reg == S4);

endmodule                  