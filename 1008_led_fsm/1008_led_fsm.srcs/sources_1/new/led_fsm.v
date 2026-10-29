`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/08 15:08:24
// Design Name: 
// Module Name: led_fsm
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


// module led_fsm(
//     input clk, reset,
//     input  sw,
//     output [1:0] led
//     ); 


//     parameter S1 = 1'b0, S2=1'b1;
//     reg current_state, next_state;

//     //state register
//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             current_state <= S1;
//         end
//         else begin
//             current_state <= next_state;
//         end
//     end


//     //next state conbinational logic
//     always @(*) begin
//         if (current_state == S1) begin
//             if(sw == 1'b1) begin
//                 next_state = S2;
//             end
//             else begin
//                 next_state = current_state;
//             end
//         end
//         else if (current_state == S2) begin
//             if(sw == 1'b0) begin
//                 next_state = S1;
//             end
//             else begin
//                 next_state = current_state;
//             end  
//         end
//         else begin
//             next_state = current_state;
//         end    
//     end


// //output 
// assign led = (current_state == 0) ? 2'b01 : 2'b10;

// endmodule




module led_fsm_1 (
    input clk,
    reset,
    input [1:0] sw,
    output reg [2:0] led
);

    parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b111;
    reg [2:0] c_state, n_state;

    // assign led = (c_state == S0) ? 3'b000:
    //              (c_state == S1) ? 3'b001:
    //              (c_state == S2) ? 3'b010:
    //              (c_state == S3) ? 3'b100:
    //              (c_state == S4) ? 3'b111 : 3'b000;

    // always @(*) begin
    //     case (c_state)
    //        S0 : led = 3'b000;
    //        S1 : led = 3'b001;
    //        S2 : led = 3'b010;
    //        S3 : led = 3'b100;
    //        S4 : led = 3'b111; 
    //         default :  led = 3'b000;
    //     endcase 
    // end

    //state resiger : sl
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state <= S0;
        end else begin
            c_state <= n_state;
        end
    end

    // next  & output : cl
    always @(*) begin

        case (c_state)
            S0: begin
                led = 3'b000;
                if (sw == 2'b01) n_state = S1;
                else n_state = c_state;
            end
            S1: begin
                led = 3'b001;
                if (sw == 2'b10) n_state = S2;
                else n_state = c_state;
            end
            S2: begin
                led = 3'b010;
                if (sw == 2'b11) n_state = S3;
                else n_state = c_state;
            end
            S3: begin
                led = 3'b100;
                if (sw == 2'b00) n_state = S0;
                else if (sw == 2'b01) n_state = S1;
                else if (sw == 2'b10) n_state = S4;
                else n_state = c_state;
            end
            S4: begin
                led = 3'b111;
                if (sw == 2'b00) n_state = S0;
                else n_state = c_state;
            end
            default: begin
                n_state = c_state;
                led = 3'b000;
            end
        endcase
    end




endmodule
