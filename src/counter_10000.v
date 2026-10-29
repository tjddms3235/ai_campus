`timescale 1ns / 1ps


module counter_10000 (
    input        clk,
    input        reset,
    input        btnU,
    input        btnL,
    input        btnR,
    output [7:0] fnd_font,
    output [3:0] fnd_com
);
    wire [13:0] w_counter;
    wire w_run_stop, w_clear, w_mode;
    wire w_btn_runstop, w_btn_mode, w_btn_clear;
    button_debounce U_BD_RUNSTOP (
        .clk  (clk),
        .reset(reset),
        .i_btn(btnR),
        .o_btn(w_btn_runstop)
    );
    button_debounce U_BD_CLEAR (
        .clk  (clk),
        .reset(reset),
        .i_btn(btnL),
        .o_btn(w_btn_clear)
    );
    button_debounce U_BD_MODE (
        .clk  (clk),
        .reset(reset),
        .i_btn(btnU),
        .o_btn(w_btn_mode)
    );
    controll_unit U_CONTROLL_UNIT (
        .clk         (clk),
        .reset       (reset),
        .btn_run_stop(w_btn_runstop),
        .btn_clear   (w_btn_clear),
        .btn_mode    (w_btn_mode),
        .run_stop    (w_run_stop),
        .clear       (w_clear),
        .mode        (w_mode)
    );
    counter_datapath U_COUNTER_DATAPATH (
        .clk     (clk),
        .reset   (reset),
        .counter (w_counter),
        .run_stop(w_run_stop),
        .clear   (w_clear),
        .mode    (w_mode)
    );
    fnd_controller U_FND_CONTROLLER (
        .clk     (clk),
        .reset   (reset),
        .fnd_data(w_counter),
        .fnd_com (fnd_com),
        .fnd_font(fnd_font)
    );

endmodule

module counter_datapath (
    input         clk,
    input         reset,
    input         run_stop,
    input         clear,
    input         mode,
    output [13:0] counter
);
    wire w_tick;
    // wire w_runstop, w_clear, w_updown;
    tick_counter U_TICK_COUNTER (
        .clk    (clk),
        .reset  (reset),
        .i_tick (w_tick),
        .mode   (mode),
        .clear  (clear),
        .counter(counter)
    );

    tick_gen U_TICK_GEN (
        .clk   (clk),
        .reset (reset),
        .o_tick(w_tick),
        .clear(clear),
        .run_stop(run_stop)
    );
endmodule
module tick_counter (
    input         clk,
    input         reset,
    input         i_tick,
    input         mode,
    input         clear,
    output [13:0] counter
);
    reg [13:0] counter_reg;  // tick_gen 의 counter_reg와 다르다.
    assign counter = counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset | clear) begin
            counter_reg <= 0;
        end else begin
            if (!mode) begin
                if (i_tick) begin
                    counter_reg <= counter_reg + 1;
                    if (counter_reg == (10000 - 1)) begin
                        counter_reg <= 0;
                    end
                end
            end else begin
                if (i_tick) begin
                    counter_reg <= counter_reg - 1;
                    if (counter_reg == 0) begin
                        counter_reg <= 9999;
                    end
                end
            end
        end
    end
endmodule

module tick_gen (
    input  clk,
    input  reset,
    input  run_stop,
    input  clear,
    output o_tick
);
    parameter F_COUNT = 10_000_000;

    reg [$clog2(F_COUNT)-1:0] counter_reg;
    reg tick_reg;
    reg pass;

    assign o_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset | clear) begin
            counter_reg <= 0;
            tick_reg <= 0;
            pass <= 0;
        end else if (~run_stop) begin
            tick_reg <= 0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == F_COUNT - 1) begin
                counter_reg <= 0;
                tick_reg <= 1'b1;
            end else begin
                tick_reg <= 1'b0;
            end
        end
    end
endmodule
