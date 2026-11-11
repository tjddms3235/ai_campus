`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/11 09:10:09
// Design Name: 
// Module Name: tb
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

`timescale 1ns / 1ps


interface fifo_interface(input clk);

    logic       rst;
    logic [7:0] push_data;
    logic       push;
    logic       pop;
    logic [7:0] pop_data;
    logic       full;
    logic       empty;

  
    property rst_full;
        @(posedge clk) rst |-> (full === 1'b0); //x,z 포함해서 비교
    endproperty
    property rst_empty;
        @(posedge clk) rst |-> (empty === 1'b1); //x,z 포함해서 비교
    endproperty

    a_rst_full :  assert property(rst_full)
     else $display("%t assert error full %d", $time,full);
    a_rst_empty :  assert property(rst_empty)
    else $display("%t assert error empty %d", $time,empty);

endinterface

class transaction;
    rand bit    rst;
    rand bit[7:0]  push_data;
    rand bit    push;
    rand bit    pop;
    logic [7:0] pop_data;
    logic       full;
    logic       empty;

    int         scenario;
    constraint test_1{
        if(scenario == 1) { 
        push dist{
            0:/0,
            1:/10
        };
        pop dist{
            0:/10,
            1:/0
        };
        
        }  
        if(scenario == 2) { 
        push dist{
            0:/10,
            1:/0
        };
        pop dist{
            0:/0,
            1:/10
        };
        } 

    }


    function void debug_print(string name);
        $display("%t : [%s] rst=%d push(%d) = [%d], full(%d) / pop(%d) = [%d], empty(%d)  "
                ,$time, name, rst, push, push_data, full, pop, pop_data,empty);
    endfunction

endclass 

class generator;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    event gen_next_evt;

    function new(mailbox #(transaction) gen2drv_mbox,
                event gen_next_evt);
        this.gen2drv_mbox = gen2drv_mbox;
        this.gen_next_evt = gen_next_evt;
    endfunction

    task run(int run_count);
       //push test
       $display("push only =%d",run_count);
       repeat(run_count) begin
            tr = new;
            tr.scenario = 1;
            tr.randomize();

            gen2drv_mbox.put(tr);
            tr.rst =0;
            tr.debug_print("gen");
            @(gen_next_evt);
       end
       //pop test
       $display("pop only =%d",run_count);
        repeat(run_count) begin
            tr = new;
            tr.scenario = 2;
            tr.randomize();

            gen2drv_mbox.put(tr);
            tr.rst =0;
            tr.debug_print("gen");
            @(gen_next_evt);
       end
       //ramdom
       $display("pop only =%d",run_count);
        repeat(run_count) begin
            tr = new;
            tr.scenario = 3;
            tr.randomize();

            gen2drv_mbox.put(tr);
            tr.rst =0;
            tr.debug_print("gen");
            @(gen_next_evt);
       end
    endtask
endclass

class driver;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    virtual fifo_interface fifo_vif;

    function new(mailbox #(transaction) gen2drv_mbox,
                virtual fifo_interface fifo_vif);
        this.gen2drv_mbox = gen2drv_mbox;
        this.fifo_vif     = fifo_vif;
    endfunction

    task preset();
        fifo_vif.rst = 1;
        fifo_vif.push =0;
        fifo_vif.push_data = 0;
        fifo_vif.pop = 0;
        repeat(2) @(negedge fifo_vif.clk);
        fifo_vif.rst = 0;
    endtask

    task run();
        forever begin
            @(posedge fifo_vif.clk);
            gen2drv_mbox.get(tr);
            tr.debug_print("drv");
            #1;
            fifo_vif.rst        = tr.rst;
            fifo_vif.push       = tr.push;
            fifo_vif.push_data  = tr.push_data;
            fifo_vif.pop        = tr.pop;
        end
    endtask
endclass

class monitor;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    virtual fifo_interface fifo_vif;
    
    function new(mailbox #(transaction) mon2scb_mbox,
                virtual fifo_interface fifo_vif);
        this.mon2scb_mbox = mon2scb_mbox;
        this.fifo_vif     = fifo_vif;
    endfunction

    task run();
        forever begin
            @(negedge fifo_vif.clk);
            tr = new;
            tr.rst        = fifo_vif.rst;  
            tr.push_data  = fifo_vif.push_data;
            tr.push       = fifo_vif.push;
            tr.pop_data   = fifo_vif.pop_data;
            tr.pop        = fifo_vif.pop;
            tr.full        = fifo_vif.full;
            tr.empty        = fifo_vif.empty;
            mon2scb_mbox.put(tr);
            tr.debug_print("mon");
        end
    endtask
endclass

class scoreboard;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    event gen_next_evt;
    
    covergroup cg_fifo;
        option.per_instance = 1;
        //fifo push data
        cp_push_data : coverpoint tr.push_data{
            bins full[] = {[0:255]};  //범위지정. 이 범위 중 출력된 값이 %로 나타남. 256개 중 몇개 -> x%
        }
    endgroup

    function new(mailbox #(transaction) mon2scb_mbox,
                event gen_next_evt);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen_next_evt =  gen_next_evt;
        this.cg_fifo = new;
    endfunction


    logic [7:0] expected_fifo[$:3];
    int total_cnt = 0, pass_cnt =0, fail_cnt = 0;
    int empty_pass_cnt=0, empty_fail_cnt;
    int full_pass_cnt =0, full_fail_cnt;
    bit expect_full = 0, expect_empty = 1;
    task run();
        forever begin
            mon2scb_mbox.get(tr);
            tr.debug_print("scb");
            total_cnt++;
            if(!tr.rst) begin
                if(expected_fifo.size()==4) begin
                    expect_full = 1;
                end else expect_full = 0;
                if(expected_fifo.size()==0) begin
                    expect_empty = 1;
                end else expect_empty = 0;

                //full  pass/fail
                if(expect_full == tr.full) begin
                    $display("pass : fifo full siganl");
                    full_pass_cnt++;
                end else begin
                     $display("fail : fifo full siganl");
                    full_fail_cnt++;
                end

                //empty pass/fail
                if(expect_empty == tr.empty) begin
                    $display("pass : fifo empty siganl");
                    empty_pass_cnt++;
                end else begin
                     $display("fail : fifo empty siganl");
                    empty_fail_cnt++;
                end


                if(!expect_full & tr.push) begin
                    expected_fifo.push_back(tr.push_data);
                end
                if(!expect_empty & tr.pop)begin
                    if(expected_fifo.pop_front()===tr.pop_data) begin
                        $display("pass");
                        pass_cnt++;
                    end
                    else begin
                        $display("fail");
                        fail_cnt++;
                    end
                end
                //coverage update
               cg_fifo.sample();
            end
            ->gen_next_evt;
        end
    endtask

    task report();
        $display("***********************************");
        $display("******fifo verification test*******");    
        $display("******total test num  =  %4d*******", total_cnt);
        $display("****** pass test num  =  %4d*******", pass_cnt);
        $display("****** fail test num  =  %4d*******", fail_cnt);
        $display("***********************************");
        $display("****** full pass test  = %4d*******", full_pass_cnt);
        $display("****** full fail test  = %4d*******", full_fail_cnt);
        $display("******empty pass test  = %4d*******", empty_pass_cnt);
        $display("******empty fail test  = %4d*******", empty_fail_cnt);
        $display("***********************************");
        $display(" *fifo coverag push data = %4.2f%%*", cg_fifo.cp_push_data.get_coverage());
    endtask
endclass

class environment;
    generator   gen;
    driver      drv; 
    monitor     mon;
    scoreboard scb;

    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;

    event gen_next_evt;

    
    
    function new(virtual fifo_interface fifo_vif);
        gen2drv_mbox = new;
        mon2scb_mbox = new;

        gen = new(gen2drv_mbox,  gen_next_evt);
        drv = new(gen2drv_mbox, fifo_vif);
        mon = new(mon2scb_mbox, fifo_vif);
        scb = new(mon2scb_mbox, gen_next_evt); 
    endfunction

    task run(int run_count);
        drv.preset;
        fork 
            gen.run(run_count);
            drv.run();
            mon.run();
            scb.run();
        join_any
        #10;
        $display("end fifo test");
        scb.report();

    endtask
endclass

module tb_fifo();
   
    logic clk = 0;
    fifo_interface fifo_if(clk); 
    environment env;


    sv_fifo dut_fifo(
        .clk        (clk),
        .rst        (fifo_if.rst),
        .push_data  (fifo_if.push_data),
        .push       (fifo_if.push),
        .pop         (fifo_if.pop),
        .pop_data   (fifo_if.pop_data),
        .full       (fifo_if.full),
        .empty      (fifo_if.empty)
    );

    always #5 clk = ~clk;
    initial begin
        env =new(fifo_if);
        env.run(10);
        $finish;
    end
endmodule

