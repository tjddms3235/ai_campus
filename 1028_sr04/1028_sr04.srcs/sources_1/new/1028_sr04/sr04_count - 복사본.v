`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 12:00:03
// Design Name: 
// Module Name: sr04_count
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


module us_tick_gen (
    input      clk,
    input      rst,
    //input      enable,
    //input      clear,
    output reg us_tick
);
    // parameter 1us
    parameter F_COUNT = 100_000_000/1_000_000;
    reg [$clog2(F_COUNT) -1:0] counter_reg;
    
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            us_tick      <= 1'b0;
        end else begin
           
            //if(enable) begin
                counter_reg <= counter_reg + 1;
                if (counter_reg == F_COUNT - 1) begin
                    counter_reg <= 0;
                    us_tick      <= 1'b1;
                end else  us_tick <= 1'b0;
            //end
        end
    end
endmodule

// module us_tick_gen (
//     input      clk,
//     input      rst,
//     input      enable,
//     input      clear,
//     output reg us_tick
// );
//     // parameter 1us
//     parameter F_COUNT = 100;
//     reg [$clog2(F_COUNT) -1:0] counter_reg;
    
//     always @(posedge clk, posedge rst) begin
//         if (rst || clear ) begin
//             counter_reg <= 0;
//             us_tick      <= 1'b0;
//         end else begin
//             us_tick <= 1'b0;
//             if(enable) begin
//                 counter_reg <= counter_reg + 1;
//                 if (counter_reg == F_COUNT - 1) begin
//                     counter_reg <= 0;
//                     us_tick      <= 1'b1;
//                 end
//             end
//         end
//     end
// endmodule