`timescale 1ns / 1ps


module ascii_decoder (
    input            clk,
    input            rst,
    input            enable,
    input      [7:0] ascii,
    output reg       pop,
    output reg [3:0] bin


);
    reg run_stop, clear,mode, sender;
    reg [7:0] data_reg, data_next;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            data_reg <= 0;
        end else begin
            data_reg <= data_next;
        end
    end

    always @(*) begin
        bin = 4'h0;
        pop = 1'b0;

        run_stop = 1'b0;
        clear    = 1'b0;
        mode    = 1'b0; 
        sender  = 1'b0;
        

        data_next = data_reg;
        if (enable == 1) begin
            data_next = ascii;
            pop = 1'b1;
            case (ascii)
                "r", "R" : run_stop = 1'b1; //r
                "c", "C" : clear    = 1'b1; //c
                "u", "U" : mode     = 1'b1;  //u
                "s", "S" : sender   = 1'b1;
            endcase

        end else begin
            case (data_reg)
                8'h30: bin = 4'h0;
                8'h31: bin = 4'h1;
                8'h32: bin = 4'h2;
                8'h33: bin = 4'h3;
                8'h34: bin = 4'h4;
                8'h35: bin = 4'h5;
                8'h36: bin = 4'h6;
                8'h37: bin = 4'h7;
                8'h38: bin = 4'h8;
                8'h39: bin = 4'h9;
                8'h41: bin = 4'ha;
                8'h42: bin = 4'hb;
                8'h43: bin = 4'hc;
                8'h44: bin = 4'hd;
                8'h45: bin = 4'he;
                8'h46: bin = 4'hf;
            endcase
        end

    end


endmodule