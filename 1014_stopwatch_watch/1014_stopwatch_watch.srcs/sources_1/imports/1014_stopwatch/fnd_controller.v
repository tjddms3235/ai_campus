`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/13 14:06:31
// Design Name: 
// Module Name: fnd_controller
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


module fnd_controller #(
    parameter MSEC_BIT_WIDTH = 7,
    parameter SEC_BIT_WIDTH  = 6,
    parameter MIN_BIT_WIDTH  = 6,
    parameter HOUR_BIT_WIDTH = 5
) (
    input clk,
    input rst,
    input sw_display_mode,
    input [MSEC_BIT_WIDTH-1:0] msec,
    input [SEC_BIT_WIDTH-1:0] sec,
    input [MIN_BIT_WIDTH-1:0] min,
    input [HOUR_BIT_WIDTH-1:0] hour,
    output [3:0] fnd_com,
    output [7:0] fnd_font
);
    //wire [3:0] w_bin;
    wire [2:0] w_ds_sel;
    wire w_clk_800hz;

    //
    wire [3:0] w_msec_ds1, w_msec_ds10;
    wire [3:0] w_sec_ds1, w_sec_ds10;
    wire [3:0] w_min_ds1, w_min_ds10;
    wire [3:0] w_hour_ds1, w_hour_ds10;
    wire [3:0] w_mux_out, w_msec_sec_mux_out, w_min_hour_mux_out;

    wire w_dot_on_off;

    clk_div_800hz DUT_clk_div_800hz (
        .clk(clk),
        .reset(rst),
        .o_clk_800hz(w_clk_800hz)
    );

    count_8 DUT_counter_8 (
        .clk(w_clk_800hz),
        .reset(rst),
        .ds_sel(w_ds_sel)
    );



    decoder_2x4 DUT_decoder_2x4 (
        .ds_sel (w_ds_sel[1:0]),
        .fnd_com(fnd_com)
    );




    digit_splitter #(
        .BIT_WIDTH(HOUR_BIT_WIDTH)
    ) DUT_hour_digit_splitter (
        .ds_in(hour),
        .ds1  (w_hour_ds1),
        .ds10 (w_hour_ds10)
    );
    digit_splitter #(
        .BIT_WIDTH(MIN_BIT_WIDTH)
    ) DUT_min_digit_splitter (
        .ds_in(min),
        .ds1  (w_min_ds1),
        .ds10 (w_min_ds10)
    );
    digit_splitter #(
        .BIT_WIDTH(SEC_BIT_WIDTH)
    ) DUT_sec_digit_splitter (
        .ds_in(sec),
        .ds1  (w_sec_ds1),
        .ds10 (w_sec_ds10)
    );

    digit_splitter #(
        .BIT_WIDTH(MSEC_BIT_WIDTH)
    ) DUT_msec_digit_splitter (
        .ds_in(msec),
        .ds1  (w_msec_ds1),
        .ds10 (w_msec_ds10)
    );


    dot_comparator dut_dot (
        .msec(msec),
        .dot_on_off(w_dot_on_off)
    );


    mux_8x1 DUT_msec_x_sec_mux_8x1 (
        .sel(w_ds_sel),
        .in0(w_msec_ds1),
        .in1(w_msec_ds10),
        .in2(w_sec_ds1),
        .in3(w_sec_ds10),
        .in4(4'hf),
        .in5(4'hf),
        .in6({3'b111, w_dot_on_off}),  //dot display
        .in7(4'hf),
        .mux_out(w_msec_sec_mux_out)
    );
    mux_8x1 DUT_min_x_hour_mux_4x1 (
        .sel(w_ds_sel),
        .in0(w_min_ds1),
        .in1(w_min_ds10),
        .in2(w_hour_ds1),
        .in3(w_hour_ds10),
        .in4(4'hf),
        .in5(4'hf),
        .in6({3'b111, w_dot_on_off}),  //dot display
        .in7(4'hf),
        .mux_out(w_min_hour_mux_out)
    );

    mux_2x1 dut_mux_display_mode (
        .sel(sw_display_mode),
        .in0(w_msec_sec_mux_out),
        .in1(w_min_hour_mux_out),
        .mux_out(w_mux_out)
    );

    bcd U_bcd (
        .bin(w_mux_out),
        .fnd_font(fnd_font)
    );

endmodule



module dot_comparator (
    input  [6:0] msec,
    output       dot_on_off
);
    //true : 1 dot off, 0 dot on
    assign dot_on_off = (msec >= 50);
endmodule









module mux_2x1 (
    input sel,
    input [3:0] in0,
    input [3:0] in1,
    output [3:0] mux_out
);

    assign mux_out = (sel) ? in1 : in0;

endmodule




module clk_div_800hz (
    input clk,
    input reset,
    output reg o_clk_800hz
);

    reg [16:0] counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 17'd0;
            o_clk_800hz <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == (62500 - 1)) begin
                counter_reg <= 17'b0;
                o_clk_800hz <= ~o_clk_800hz;
            end

            if (counter_reg == (125_000 - 1)) begin
                counter_reg <= 17'd0;
                o_clk_800hz <= 1'b0;
            end
        end
    end


endmodule



module count_8 (
    input clk,
    input reset,
    output  [2:0] ds_sel
);

    reg [2:0] counter_reg;

    assign ds_sel = counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            //reset : 1'b1
            counter_reg <= 3'b0;
        end else begin
            counter_reg <= counter_reg + 1'b1;
        end

    end

endmodule






module decoder_2x4 (
    input [1:0] ds_sel,
    output reg [3:0] fnd_com
);

    always @(ds_sel) begin
        case (ds_sel)
            2'b00:   fnd_com = 4'b1110;
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1111;
        endcase
    end

endmodule




module mux_8x1 (
    input [2:0] sel,
    input [3:0] in0,
    input [3:0] in1,
    input [3:0] in2,
    input [3:0] in3,
    input [3:0] in4,
    input [3:0] in5,
    input [3:0] in6,
    input [3:0] in7,
    output reg [3:0] mux_out
);

    always @(*) begin

        case (sel)
            3'b000:  mux_out = in0;
            3'b001:  mux_out = in1;
            3'b010:  mux_out = in2;
            3'b011:  mux_out = in3;
            3'b100:  mux_out = in4;
            3'b101:  mux_out = in5;
            3'b110:  mux_out = in6;
            3'b111:  mux_out = in7;
            default: mux_out = in0;
        endcase


    end


endmodule



//digit splitter
module digit_splitter #(
    parameter BIT_WIDTH = 7
) (
    input [BIT_WIDTH-1:0] ds_in,
    output [3:0] ds1,  //digit1 1
    output [3:0] ds10  //digit2 10 

);

    assign ds1  = ds_in % 10;
    assign ds10 = (ds_in / 10) % 10;


endmodule





module bcd (
    input [3:0] bin,
    output reg [7:0] fnd_font
);

    always @(bin) begin
        case (bin)
            4'b0000: fnd_font = 8'hc0;
            4'b0001: fnd_font = 8'hf9;
            4'b0010: fnd_font = 8'ha4;
            4'b0011: fnd_font = 8'hb0;
            4'b0100: fnd_font = 8'h99;
            4'b0101: fnd_font = 8'h92;
            4'b0110: fnd_font = 8'h82;
            4'b0111: fnd_font = 8'hf8;
            4'b1000: fnd_font = 8'h80;
            4'b1001: fnd_font = 8'h90;
            4'b1010: fnd_font = 8'h88;
            4'b1011: fnd_font = 8'h83;
            4'b1100: fnd_font = 8'hc6;
            4'b1101: fnd_font = 8'ha1;
            4'b1110: fnd_font = 8'h7f; // segment dot only on
            4'b1111: fnd_font = 8'hff; // segment off
            default: fnd_font = 8'hff;
        endcase
    end

endmodule
