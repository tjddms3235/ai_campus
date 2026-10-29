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
    input btnR, //run_stop
    input btnL, //clear
    input btnU, //mode
    output [3:0] fnd_com,
    output [7:0] fnd_font
    );
    
    //sw0 : 0 stop/1 run
    //sw1 : clear
    //sw2 : 0 up/1 down


    wire [13:0] w_counter;
    wire w_run_stop, w_clear, w_mode;
    wire w_btn_run_stop, w_btn_clear, w_btn_mode;


button_debounce dut_run_stop(
    .clk(clk),
    .reset(reset),
    .i_btn(btnR),
    .o_btn(w_btn_run_stop)
    );

button_debounce dut_clear(
    .clk(clk),
    .reset(reset),
    .i_btn(btnL),
    .o_btn(w_btn_clear)
    );

button_debounce dut_mode(
    .clk(clk),
    .reset(reset),
    .i_btn(btnU),
    .o_btn(w_btn_mode)
    );


control_unit dut_control(
    .clk(clk),
    .reset(reset),
    .btn_run_stop(w_btn_run_stop),
    .btn_clear(w_btn_clear),
    .btn_mode(w_btn_mode),
    .run_stop(w_run_stop),
    .clear(w_clear),
    .mode(w_mode)
    );





counter_datapass DUT_datapass(
    .clk(clk),
    .reset(reset),
    .run_stop(w_run_stop),
    .clear(w_clear),
    .mode(w_mode),
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
    input [2:0] sw,
    input run_stop,clear, mode,
    output [13:0] counter
);

    wire w_tick;
  
  
    tick_gen DUT_tick_gen(
        .clk(clk),
        .reset(reset),               
        .o_tick(w_tick),
        .run_stop(run_stop),
        .clear(clear)
    );




    tick_counter DUT_tick_counter(
        .clk(clk),
        .reset(reset), 
        .clear(w_clear),
        .mode(w_mode),
        .i_tick(w_tick),
        .counter(counter)
    );



endmodule




module tick_counter(
    input clk,
    input reset,
    input i_tick,
    input clear, mode,
    output [13:0] counter
);

    reg [13:0] counter_reg;


    assign counter = counter_reg;

    always @(posedge clk, posedge reset) begin

        // // 1. Reset
        if (reset | clear) begin
            counter_reg <= 14'd0;
        end
        else begin
            if (!mode) begin
                 if (i_tick) begin
                    counter_reg <= counter_reg + 1'b1;
                    if (counter_reg == 14'd9999) begin
                        counter_reg <= 14'd0;
                    end
                        
                 end
                 else begin
                    if (i_tick) begin
                    counter_reg <= counter_reg - 1'b1;
                    if (counter_reg == 14'd0) begin
                        counter_reg <= 14'd9999;
                    end
                        
                    end
                 end

        end
        end
    end
endmodule
        

module tick_gen(
    input clk,
    input reset, 
    input run_stop,clear,
    output o_tick
);

    parameter F_COUNT = 10_000_000;
    reg [$clog2(F_COUNT)-1:0] counter_reg;
    reg tick;
    
    
    assign o_tick = tick;

    always @(posedge clk, posedge reset) begin
        if(reset | clear ) begin
            counter_reg <= 0;
            tick        <=1'b0;
        end
        else begin
            if (run_stop) begin
            counter_reg <= counter_reg+1;
            
                if (counter_reg == (F_COUNT-1)) begin
                //gengerate 10hz tick
                 counter_reg <= 0;
                 tick <= 1'b1;                
            end else begin
                tick <= 1'b0;
                end 
            end

        end
    end
    
        
    



endmodule