`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/09 11:48:59
// Design Name: 
// Module Name: tb_sv_ram
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


interface ram_interface(
    input clk
);
      logic [5:0] addr;
      logic [7:0] wdata;
      logic       we;
      logic [7:0] rdata;
endinterface

class transaction;
    rand bit[5:0] addr;
    rand bit [7:0] wdata;
    rand bit we;
    logic   [7:0] rdata;

    function void debug_print(string name);
        $display("%t : [%s] addr = %d, wdata =%d, we = %d, rdata=%d",
            $time,name,addr,wdata,we,rdata);
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
        repeat(run_count) begin
            tr = new;
            tr.randomize();

            gen2drv_mbox.put(tr);
            tr.debug_print("gen");
            @(gen_next_evt);
        end
    endtask 
endclass

class driver;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    event mon_next_evt;
    virtual ram_interface ram_vif;

    function new(mailbox #(transaction) gen2drv_mbox,
                event mon_next_evt,
                virtual ram_interface ram_vif);
        this.gen2drv_mbox = gen2drv_mbox;
        this.mon_next_evt = mon_next_evt;
        this.ram_vif = ram_vif;
    endfunction
    
    task run();
        forever begin
            @(negedge ram_vif.clk);
            gen2drv_mbox.get(tr);
            ram_vif.addr =tr.addr;
            ram_vif.wdata = tr.wdata;
            ram_vif.we = tr.we;
            tr.debug_print("drv");
            //->mon_next_evt; 
        end

    endtask
endclass



class monitor;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    event mon_next_evt;
    virtual ram_interface ram_vif;

    function new(mailbox #(transaction) mon2scb_mbox,
                event mon_next_evt,
                virtual ram_interface ram_vif);
        this.mon2scb_mbox = mon2scb_mbox;
        this.mon_next_evt = mon_next_evt;
        this.ram_vif = ram_vif;
    endfunction

    task run();
        forever begin
        //@(mon_next_evt);
        @(posedge ram_vif.clk);
        tr=new;
        tr.addr = ram_vif.addr;
        tr.wdata =ram_vif. wdata;
        tr.we =ram_vif.we;
        tr.rdata = ram_vif.rdata;
        mon2scb_mbox.put(tr);
        tr.debug_print("mon");
        end
    endtask
endclass

class scoreboard;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    event gen_next_evt;
    int pass_cnt, fail_cnt, total_cnt;

        function new(mailbox #(transaction) mon2scb_mbox,
                event gen_next_evt);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen_next_evt = gen_next_evt;

    endfunction
    logic [7:0] expected_buf[0:63];

    task run();
        forever begin
            mon2scb_mbox.get(tr);
            tr.debug_print("scb");
            total_cnt++;
            if(tr.we)begin
                //store for expected buffer
                expected_buf[tr.addr] = tr.wdata;
            end
            else begin
                //we =0
                //pass fail
                if(expected_buf[tr.addr] === tr.rdata) begin
                    $display("pass");
                    $display("expected =%d", expected_buf[tr.addr]);
                    pass_cnt++;
                end else begin
                    $display("fail");
                    $display("expected =%d", expected_buf[tr.addr]);
                    fail_cnt++;
                end
            end
            ->gen_next_evt;
        end
    endtask

    task report();
        $display("***************************");
        $display("ram size 64 write/read test");
        $display("  ram total test num =  %d ",total_cnt);
        $display("  ram pass  test num =  %d ",pass_cnt);
        $display("  ram fail  test num =  %d ",fail_cnt);
        $display("***************************");

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
    event mon_next_evt;

    function new(virtual ram_interface ram_vif);
        gen2drv_mbox =new;
        mon2scb_mbox= new;

        gen = new(gen2drv_mbox, gen_next_evt);
        drv = new(gen2drv_mbox, mon_next_evt, ram_vif);
        mon = new(mon2scb_mbox, mon_next_evt, ram_vif);
        scb = new(mon2scb_mbox, gen_next_evt); 
    
    endfunction

    task run(int run_count);
        fork
            gen.run(run_count);
            drv.run();
            mon.run();
            scb.run();
        join_any

        #10;
        scb.report();
    endtask

endclass

module tb_sv_ram();
    
    logic clk = 0;
    ram_interface ram_if(clk);
    environment env;
    ram_ip_sv dut_ram(
        .clk(clk),
        .addr(ram_if.addr),
        .wdata(ram_if.wdata),
        .we(ram_if.we),
        .rdata(ram_if.rdata)
    );


    always #5 clk = ~clk;
    initial begin
        env =new(ram_if);
        env.run(100);
        $finish;
    end
endmodule
