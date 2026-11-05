`timescale 1ns / 1ps


interface reg_interface (
    input clk
);

    logic       rst;
    logic [7:0] d;
    logic [7:0] q;
endinterface


//seq item
class transaction;
    bit            rst; 
    rand bit [7:0] d;
    logic    [7:0] q;

    function debug_print(string name);
        $display("%d : [%s] resset = %d, d=%d, q=%d",$time, name, rst, d, q);
    endfunction
endclass

class generator;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    event gen_next_evt;

    //set up
    function new(mailbox#(transaction) gen2drv_mbox, event gen_next_evt);
        this.gen2drv_mbox = gen2drv_mbox;
        this.gen_next_evt = gen_next_evt;
    endfunction

    task run(int run_count);
        repeat (run_count) begin
            tr = new;
            tr.randomize();
            gen2drv_mbox.put(tr);
            tr.debug_print("GEN");
            @(gen_next_evt);  //from scoreboard
            //이벤트 감지가 마지막에 위치해야 pass/fail 후 다시 tr 생성
        end
    endtask
endclass

class drive;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    event mon_next_evt;
    virtual reg_interface reg_vif;

    function new(mailbox#(transaction) gen2drv_mbox, event mon_next_evt,
                 virtual reg_interface reg_vif);
        this.gen2drv_mbox = gen2drv_mbox;
        this.mon_next_evt = mon_next_evt;
        this.reg_vif = reg_vif;
    endfunction

    task preset();
        reg_vif.rst = 1;
        @(posedge reg_vif.clk);
        @(posedge reg_vif.clk);

    endtask

    task run();
        forever begin
            @(posedge reg_vif.clk);
            gen2drv_mbox.get(tr);
            tr.debug_print("DRV - GET");
            //@(posedge reg_vif.clk);
            #1;
            tr.debug_print("DRV - AFTER POSEDGE ");
            reg_vif.rst = 0;
            reg_vif.d   = tr.d;
            ->mon_next_evt;
        end
    endtask
endclass

class monitor;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    event mon_next_evt;
    virtual reg_interface reg_vif;

    function new(mailbox#(transaction) mon2scb_mbox, event mon_next_evt,
                 virtual reg_interface reg_vif);
        this.mon2scb_mbox = mon2scb_mbox;
        this.mon_next_evt = mon_next_evt;
        this.reg_vif = reg_vif;
    endfunction

    task run();
        forever begin
            tr   = new;
            @(mon_next_evt);
            tr.debug_print("MON");
            @(posedge reg_vif.clk);
            tr.d = reg_vif.d;
            tr.q = reg_vif.q;
            tr.debug_print("MON - AFTER POSEDGE");
            mon2scb_mbox.put(tr);
        end
    endtask

endclass

class scoreboard;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    event gen_next_evt;

    logic [7:0] expected_d; //실제 출력 값이 4state이므로 동일하게 설정
    bit fisrt_flag = 1;

    int pass_cnt,  fail_cnt;


    function new(mailbox#(transaction) mon2scb_mbox, event gen_next_evt);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen_next_evt = gen_next_evt;
    endfunction

    task run();
        forever begin
            //get mail box
            mon2scb_mbox.get(tr);
            tr.debug_print("SCB");
            
            //pass/fail dectection
            if (fisrt_flag) begin
                fisrt_flag = 0;
            end else begin
                //pass fail
                if (expected_d === tr.q) begin
                    $display("pass");
                    pass_cnt++;
                end else begin
                    $display("fail");
                    fail_cnt++;
                end
            end
            expected_d = tr.d;
            //event generate
            ->gen_next_evt;
        end
    endtask
endclass

class environment;
    generator gen;
    drive drv;
    monitor mon;
    scoreboard scb;

    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;

    event gen_next_evt;
    event mon_next_evt;

    function new(virtual reg_interface reg_vif);
        gen2drv_mbox = new;
        mon2scb_mbox = new;

        gen = new(gen2drv_mbox, gen_next_evt);
        drv = new(gen2drv_mbox, mon_next_evt, reg_vif);
        mon = new(mon2scb_mbox, mon_next_evt, reg_vif);
        scb = new(mon2scb_mbox, gen_next_evt);
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
        //pass /fail count display
        $display("*************************************");
        $display("***register 8bit verification test***");
        $display("***       total test = %3d        ***", run_count);
        $display("***      1st pass/fail skip       ***");
        $display("***        pass_cnt : %3d         ***", scb.pass_cnt);
        $display("***        fail_cnt : %3d         ***", scb.fail_cnt);
        $display("*************************************");

    endtask
endclass



module tb_reg8 ();
    logic clk;

    reg_interface reg_if (clk);
    environment env;
    register8 dut_reg8 (
        .clk(clk),
        .rst(reg_if.rst),
        .d  (reg_if.d),
        .q  (reg_if.q)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;

        env = new(reg_if);
        env.run(20);
        $finish;
    end
endmodule
