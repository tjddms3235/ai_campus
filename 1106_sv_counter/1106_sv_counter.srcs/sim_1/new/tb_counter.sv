`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/06 09:57:26
// Design Name: 
// Module Name: tb_counter
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


interface counter_interface (
    input clk
);
    logic       rst;
    logic [7:0] counter;
endinterface

class transaction;
    rand bit rst;
    logic [7:0] counter;

endclass

class generator;

    event gen_next_evt;

    function new(event gen_next_evt);
        this.gen_next_evt = gen_next_evt;
    endfunction

    task run(int count);
        repeat (count) begin
            @(gen_next_evt);
        end
    endtask
endclass

class drive;

    virtual counter_interface counter_vif;
    event gen_next_evt;

    function new(virtual counter_interface counter_vif, event gen_next_evt);
        this.counter_vif  = counter_vif;
        this.gen_next_evt = gen_next_evt;
    endfunction

    task preset();
        counter_vif.rst = 1;
        @(negedge counter_vif.clk);
        @(negedge counter_vif.clk);
        counter_vif.rst = 0;
    endtask

    task run();
        forever begin
            @(posedge counter_vif.clk);
            -> gen_next_evt;
        end
    endtask
endclass

class monitor;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    virtual counter_interface counter_vif;

    function new(mailbox#(transaction) mon2scb_mbox,
                 virtual counter_interface counter_vif);
        this.mon2scb_mbox = mon2scb_mbox;
        this.counter_vif  = counter_vif;
    endfunction

    task run();
        forever begin
            @(posedge counter_vif.clk);
            tr = new();
            tr.rst = counter_vif.rst;
            tr.counter = counter_vif.counter;
            mon2scb_mbox.put(tr);
        end
    endtask
endclass

class scoreboard;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;

    function new(mailbox#(transaction) mon2scb_mbox);
        this.mon2scb_mbox = mon2scb_mbox;
    endfunction

    logic [7:0] expected_count = 0;
    int pass_cnt = 0, fail_cnt = 0, total_cnt = 0;
    task run();
        forever begin
            mon2scb_mbox.get(tr);
            if (!tr.rst) begin
                if (expected_count == tr.counter) begin
                    pass_cnt++;
                end else begin
                    fail_cnt++;
                end
                expected_count++;
            end else begin
                expected_count = 0;
            end
        end
    endtask

    task report();
        $display("**********************");
        $display("** counter 256 test **");
        $display("** total test = %d **", total_cnt);
        $display("**  pass test = %d **", pass_cnt);
        $display("**  fail test = %d **", fail_cnt);
    endtask
endclass

class environment;
    generator gen;
    drive drv;
    monitor mon;
    scoreboard scb;

    mailbox #(transaction) mon2scb_mbox;
    event gen_next_evt;

    function new(virtual counter_interface counter_vif);
        mon2scb_mbox = new;
        gen = new(gen_next_evt);
        drv = new(counter_vif,gen_next_evt);
        mon = new(mon2scb_mbox, counter_vif);
        scb = new(mon2scb_mbox);
    endfunction

    task run(int run_count);
        drv.preset();
        fork
            gen.run(run_count);
            drv.run();
            mon.run();
            scb.run();
        join_any

        #10;
        scb.report();
        disable fork;
    endtask

endclass


module tb_counter ();

    logic clk = 0;
    environment env;
    counter_interface counter_if (clk);

    counter_256 dut_counter (
        .clk(clk),
        .rst(counter_if.rst),
        .counter(counter_if.counter)
    );

    always #5 clk = ~clk;

    initial begin
        env = new(counter_if);
        env.run(256);
        $finish;
    end
endmodule
