`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/11 09:09:31
// Design Name: 
// Module Name: sv_fifo
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




module sv_fifo(
    input  logic       clk,
    input  logic       rst,
    input  logic [7:0] push_data,
    input  logic       push,
    input  logic       pop,
    output logic [7:0] pop_data,
    output logic       full,
    output logic       empty
);

logic [1:0] waddr,raddr;

    register_file u_register_file (
        .*,
        .waddr(waddr),
        .raddr(raddr),
        .we(push&(~full))
    );

    control_unit u_control (
        .*,
        .wptr (waddr),
        .rptr (raddr)

    );


endmodule


module register_file (
    input  logic       clk,
    input  logic [1:0] waddr,
    input  logic [1:0] raddr,
    input  logic [7:0] push_data,
    input  logic       we,
    output logic [7:0] pop_data
);

    reg [7:0] reg_file[0:3];

    always @(posedge clk) begin
        if (we) begin
            reg_file[waddr] <= push_data;
        end
    end
    assign pop_data = reg_file[raddr];
endmodule


module control_unit (
    input  logic       clk,
    input  logic       rst,
    input  logic       push,
    input  logic       pop,
    output logic [1:0] wptr,
    output logic [1:0] rptr,
    output logic       full,
    output logic  empty

);
    logic [1:0] wptr_next;
    logic [1:0] rptr_next;

    logic full_next;
    logic empty_next;




    always @(posedge clk, posedge rst) begin
        if (rst) begin
            wptr  <= 0;
            rptr  <= 0;
            full  <= 0;
            empty <= 1;
        end else begin
            wptr  <= wptr_next;
            rptr  <= rptr_next;
            full  <= full_next;
            empty <= empty_next;
        end
    end

    always @(*) begin
        wptr_next  = wptr;
        rptr_next  = rptr;
        full_next  = full;
        empty_next = empty;

        case ({ push, pop })

            //push olny
            2'b10: begin
                if (!full) begin
                    wptr_next  = wptr + 1;
                    empty_next = 1'b0;
                    if (wptr_next == rptr) full_next = 1'b1;
                end
            end

            //pop only
            2'b01: begin
                if (!empty) begin
                    rptr_next = rptr + 1;
                    full_next = 1'b0;
                    if (rptr_next == wptr) empty_next = 1'b1;
                end
            end

            //push & pop
            2'b11: begin
                if (full) begin
                    rptr_next = rptr + 1;
                    full_next = 1'b0;
                end else if (empty) begin
                    wptr_next  = wptr + 1;
                    empty_next = 1'b0;
                end else begin
                    wptr_next = wptr + 1;
                    rptr_next = rptr + 1;
                end
            end

        endcase

    end


endmodule
