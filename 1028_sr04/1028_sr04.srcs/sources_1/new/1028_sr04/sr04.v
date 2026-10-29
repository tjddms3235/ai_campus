`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 12:01:00
// Design Name: 
// Module Name: sr04
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


module sr04_controll_unit(
    input clk,
    input rst,
    input sr04_start,
    input echo,
    input us_tick,
    output trig,
    output [8:0]distance
    );



// parameter [2:0] IDLE = 3'b000, START = 3'b001, WAIT= 3'b010, DISTANCE= 3'b011, STOP = 3'b100;
// parameter TRIGGER_COUNT = 11;
// reg [1:0] c_state, next_state;
// reg trigger_reg, trigger_next;
// reg [4:0] counter_reg, counter_next;

// ////wait :  rising edge detec
// reg edge_reg;
// wire echo_rising;



// always @(posedge clk, posedge rst) begin
//     if (rst|| clear) begin
//         c_state <= IDLE;
//         counter_reg <= 4'b0;
//         trigger_reg <= 1'b0;
//     end
//     else begin
//         c_state <= next_state;
//         counter_reg <= counter_next;
//         trigger_reg <= trigger_next;
//     end
// end

// always @(*) begin
//     n_state      = c_state;
//     counter_next = counter_reg;
//     trigger_next = trigger_reg;
//     case(c_state)
//         IDLE     : begin
//                    counter_next = 0; 
//                    if(sr04_start) begin
//                     n_state = START;
//                    end 
                   
//         end
//         START    : begin
//                     trigger_next= 1'b1;
//                     if (us_tick) begin
//                         if(counter_reg == TRIGGER_COUNT-1 ) begin
//                             n_state = WAIT;
//                             counter_next = 0;
//                             trigger_next = 1'b0;
//                         end 
//                         else begin
//                             counter_next = counter_reg +1;
//                         end     
//                     end
//         end
//         WAIT     : begin

//         end 
//         DISTANCE : begin
//         end 
//         STOP     : begin
//         end 
//     endcase 

// end
// assign echo_rising = echo & (~edge_reg); 
// //wait :  rising edge detec
// always @(posedge clk) begin
//     edge_reg <= echo;
// end

    localparam IDLE = 0, START = 1, WAIT= 2, DISTANCE= 3, STOP = 4;
    reg [2:0] c_state, n_state;
    reg [14:0] tick_cnt_reg, tick_cnt_next;
    reg [8:0] distance_reg, distance_next;
    reg trig_reg, trig_next;

    assign distance = distance_reg;
    assign trig =trig_reg;

    //state register
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            c_state         <= IDLE;
            tick_cnt_reg    <= 0;
            distance_reg    <=0;
            trig_reg <=0;
        end else begin
            c_state      <= n_state;
            tick_cnt_reg <= tick_cnt_next;
            distance_reg <= distance_next;
            trig_next <= trig_reg;
        end
    end

    always @(*) begin
        n_state = c_state;
        tick_cnt_next = tick_cnt_reg;
        trig_next <= trig_reg;
        case (c_state) 
            IDLE : begin
                if(sr04_start) begin
                    tick_cnt_next =0;
                    n_state = START;
                end
            end
            START : begin
                if(us_tick) begin
                    if(tick_cnt_reg ==10) begin
                        n_state = WAIT;
                    end else begin
                        tick_cnt_next = tick_cnt_reg +1;
                    end
            end
            end
            WAIT : begin
                trig_next =0;
                if(echo & us_tick) begin
                    tick_cnt_next =0;
                    n_state = DISTANCE;
                end
            end
            DISTANCE : begin
                if(us_tick) begin
                    if(!echo) begin
                        distance_next = tick_cnt_reg /58;
                        tick_cnt_next =0;
                        n_state = STOP;
                    end else begin
                        if(tick_cnt_reg >= 36_000-1) begin
                            distance_next=400;
                            tick_cnt_next =0;
                            n_state = STOP;
                        end
                        tick_cnt_next = tick_cnt_reg+1;
                    end
                end
            end
            STOP : begin
                
                if(us_tick)begin
                    if(tick_cnt_reg >=10_000) begin
                        n_state = IDLE;
                    end else begin
                        tick_cnt_next =tick_cnt_reg+1;
                    end
                end
            end
        endcase
    end

endmodule




