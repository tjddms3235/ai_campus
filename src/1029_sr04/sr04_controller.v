`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/29 09:06:48
// Design Name: 
// Module Name: sr04_controller
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


// module sr04_controller (
//     input clk,
//     input rst,
//     input sr04_start,
//     input echo,
//     input us_tick,
//     output trig,
//     output [8:0] distance
// );

//     localparam IDLE = 0, START = 1, WAIT = 2, DISTANCE = 3, STOP = 4;
//     reg [2:0] c_state, n_state;
//     reg [14:0] tick_cnt_reg, tick_cnt_next;
//     reg [8:0] distance_reg, distance_next;
//     reg trig_reg, trig_next;

//     assign distance = distance_reg;
//     assign trig = trig_reg;

//     //state register
//     always @(posedge clk, posedge rst) begin
//         if (rst) begin
//             c_state      <= IDLE;
//             tick_cnt_reg <= 0;
//             distance_reg <= 0;
//             trig_reg     <= 0;
//         end else begin
//             c_state      <= n_state;
//             tick_cnt_reg <= tick_cnt_next;
//             distance_reg <= distance_next;
//             trig_reg     <= trig_next;
//         end
//     end

//     // next
//     always @(*) begin
//         n_state       = c_state;
//         tick_cnt_next = tick_cnt_reg;
//         distance_next = distance_reg;
//         trig_next     = trig_reg;
//         case (c_state)
//             IDLE: begin
//                 trig_next = 0;
//                 if (sr04_start) begin
//                     distance_next = 0;
//                     tick_cnt_next = 0;
//                     n_state = START;
//                 end
//             end

//             START: begin
//                 trig_next = 1'b1;
//                 if (us_tick) begin
//                     if (tick_cnt_reg == 10) begin
//                         n_state = WAIT;
//                     end else begin
//                         tick_cnt_next = tick_cnt_reg + 1;
//                     end
//                 end
//             end

//             WAIT: begin
//                 trig_next = 1'b0;
//                 if (echo & us_tick) begin
//                     tick_cnt_next = 0;
//                     n_state = DISTANCE;
//                 end
//             end

//             DISTANCE: begin
//                 if (us_tick) begin
//                     if (!echo) begin
//                         distance_next = tick_cnt_reg / 58;
//                         tick_cnt_next = 0;
//                         n_state = STOP;
//                     end else begin
//                         if (tick_cnt_reg >= 36_000 - 1) begin
//                             distance_next = 400;
//                             tick_cnt_next = 0;
//                             n_state = STOP;
//                         end
//                         tick_cnt_next = tick_cnt_reg + 1;
//                     end
//                 end
//             end

//             STOP: begin
//                 if (us_tick) begin
//                     if (tick_cnt_reg >= 10_000) begin
//                         n_state = IDLE;
//                     end else begin
//                         tick_cnt_next = tick_cnt_reg + 1;
//                     end
//                 end
//             end
//         endcase
//     end
// endmodule
////////////

module sr04_controller (
    input        clk,
    input        rst,
    input        sr04_start,
    input        echo,
    input        us_tick,
    output       trig,
    output [8:0] distance
);
    localparam IDLE = 0, START = 1, WAIT = 2, DISTANCE = 3, STOP = 4;
    reg [2:0] c_state, n_state;
    reg [14:0] tick_cnt_reg, tick_cnt_next;
    reg [8:0] distance_reg, distance_next;
    reg trig_reg, trig_next;


    // intergrate logic analyer
    //probing trig,echo, fsm c_state
    ila_0 U_ILA (
        .clk(clk),
        .probe0(trig),
        .probe1(echo),
        .probe2(c_state)
    );








    assign distance = distance_reg;
    assign trig = trig_reg;

    //state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= IDLE;
            tick_cnt_reg <= 0;
            distance_reg <= 0;
            trig_reg <= 0;
        end else begin
            c_state <= n_state;
            tick_cnt_reg <= tick_cnt_next;
            distance_reg <= distance_next;
            trig_reg <= trig_next;
        end
    end

    always @(*) begin
        n_state       = c_state;
        tick_cnt_next = tick_cnt_reg;
        distance_next = distance_reg;
        trig_next     = trig_reg;

        case (c_state)
            IDLE: begin
                if (sr04_start) begin
                    tick_cnt_next = 0;
                    n_state = START;
                end
            end
            START: begin
                trig_next = 1'b1;
                if (us_tick) begin
                    if (tick_cnt_reg == 10) begin
                        n_state = WAIT;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            WAIT: begin
                trig_next = 1'b0;
                if (echo & us_tick) begin
                    tick_cnt_next = 0;
                    n_state = DISTANCE;
                end
            end
            DISTANCE: begin
                if (us_tick) begin
                    if (!echo) begin
                        distance_next = tick_cnt_reg / 58;
                        tick_cnt_next = 0;
                        n_state = STOP;
                    end else begin
                        if (tick_cnt_reg >= 36_000 - 1) begin
                            distance_next = 400;
                            tick_cnt_next = 0;
                            n_state = STOP;
                        end
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                if (us_tick) begin
                    if (tick_cnt_reg >= 10_000) begin
                        n_state = IDLE;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end



        endcase
    end
endmodule
