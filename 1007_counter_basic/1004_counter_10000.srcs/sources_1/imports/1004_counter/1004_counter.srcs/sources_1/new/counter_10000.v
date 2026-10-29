`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/07 12:43:14
// Design Name: 
// Module Name: counter_10000
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


module counter_10000(
    input clk,
    input reset,
    output [3:0] fnd_com,
    output [7:0] fnd_font
    );
    
    wire [13:0] w_counter;
counter_datapass DUT_datapass(
    .clk(clk),
    .reset(reset),
    .counter(w_counter)
);
    
fnd_controller DUT_fnd_contl(

    .fnd_data(w_counter),
    .fnd_com(fnd_com),
    .fnd_font(fnd_font),
    .clk(clk), 
    .reset(reset)
);

endmodule


module counter_datapass(
    input clk,
    input reset,
    output [13:0] counter
);

    wire w_tick;

    tick_counter DUT_tick_counter(
        .clk(clk),
        .reset(reset),
        .i_tick(w_tick),
        .counter(counter)
    );

    tick_gen DUT_tick_gen(
        .clk(clk),
        .reset(reset),
        .o_tick(w_tick)
    );


endmodule




module tick_counter(
    input clk,
    input reset,
    input i_tick,
    output [13:0] counter
);

    reg [13:0] counter_reg;

    assign counter = counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset)begin
            counter_reg <=0;
        end
        else begin
            if (i_tick) begin
                counter_reg <= counter_reg+1;
                if (counter_reg == (10000-1)) begin
                    counter_reg <=0;
                end
            end
        end
    end
    

endmodule







module tick_gen(
    input clk,
    input reset,
    output o_tick
);
    
    parameter F_COUNT = 10_000_000;
    reg [$clog2(F_COUNT)-1:0] counter_reg;
    reg tick;
    
    
    assign o_tick = tick;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            counter_reg <= 0;
            tick        <=1'b0;
        end
        else begin
            counter_reg <= counter_reg+1;
            if (counter_reg == (F_COUNT-1)) begin
                //gengerate 10hz tick
                 counter_reg <= 0;
                 tick <= ~tick;                
            end else begin
                tick <= 0;
                end 
            end

        end
    
        
    



endmodule