


`timescale 1ns / 1ps
interface adder_interface ();
    logic [7:0] a, b;
    logic       mode;
    logic [9:0] s;
    logic       c;
endinterface

class transaction;
    rand bit [7:0] a;
    rand bit [7:0] b;
    rand bit       mode;

    // monior variable
    logic    [9:0] s;
    logic          c;

    constraint adder_limit {
        a > 128;
        b < 64;
    }
    // //    constraint는 끝에 ; 없음

    // //    128 <a <200 범위를 사용할 때는 inside 
    //     constraint adder_inside{ a inside {[128:200]};} 

    // //    list 형식으로 사용할 때도 inside 
    //     constraint adder_inside{ a inside {128,200,212,250};} 

    // //    확률(dist언급) :/ 는 % 개념(모두 더해서 자기 값으로 나눔) -> 100으로 만드는게 편함
    // //    := 는 모두 더한 값 % 연산 후 지정값  
    constraint adder_dist {
        mode dist {
            0 :/ 80,
            1 :/ 20
        };
    }

    function debug_print(string name);
        $display("%t : [%s] a=%d, b=%d, mode=%d, s=%d, c=%d", $time, name, a,
                 b, mode, s, c);
    endfunction

endclass

class generator;
    transaction tr;

    mailbox #(transaction) gen2drv_mbox;
    event gen_next_evt;

    function new(
        mailbox#(transaction) gen2drv_mbox,
        event gen_next_evt
    );  //객체 생성 초기화 
        this.gen2drv_mbox = gen2drv_mbox; //assign 처럼 연결한다는 개념으로 접근할 것
        this.gen_next_evt=gen_next_evt; 
    endfunction

    task run(int run_count);
        repeat (run_count) begin
            tr = new;
            tr.randomize();
            tr.debug_print("gen");
            gen2drv_mbox.put(tr);
            //wait gen next event
            @(gen_next_evt);
        end
        #10;

        $display("%t : end gen", $time);
    endtask
endclass

class driver;
    transaction tr;
    event drv2mon_evt;
    mailbox #(transaction) gen2drv_mbox;

    virtual adder_interface adder_if_v;

    function new(mailbox#(transaction) gen2drv_mbox_a, event drv2mon_evt,
                 virtual adder_interface adder_if_v_a);
        this.gen2drv_mbox = gen2drv_mbox_a;
        this.drv2mon_evt  = drv2mon_evt;
        this.adder_if_v   = adder_if_v_a;
    endfunction

    task run();
        forever begin
            gen2drv_mbox.get(tr);
            tr.debug_print("drv");
            //drive
            adder_if_v.a = tr.a;
            adder_if_v.b = tr.b;
            adder_if_v.mode = tr.mode;
            #5;
            ->drv2mon_evt;
            #5;
               //-> : 이벤트 발생
        end

    endtask
endclass

class monitor;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    virtual adder_interface adder_if_v;
    event drv2mon_evt;

    function new(mailbox#(transaction) mon2scb_mbox, event drv2mon_evt,
                 virtual adder_interface adder_if_v);
        this.mon2scb_mbox = mon2scb_mbox;
        this.drv2mon_evt = drv2mon_evt;
        this.adder_if_v = adder_if_v; //this.adder_if_v : class 내부의 adder_if_v, 
                                      //  adder_if_v : function new 의 argument
    endfunction
    task run();
        forever begin
            //wait event
            @(drv2mon_evt);
            //generate transaction
            tr =new; // generate mailbox에서 get 하면 gabbge collect 로 인해 사라질 수 있음 ->  모니터-스코어보드를 위해 새로 생성.
            tr.a = adder_if_v.a;
            tr.b = adder_if_v.b;
            tr.mode = adder_if_v.mode;
            tr.s = adder_if_v.s;
            tr.c = adder_if_v.c;
            tr.debug_print("monitor");
            mon2scb_mbox.put(tr);  //monitor에서 tr로 생성한 거를 mailbox로 넣음
        end
    endtask
endclass

class scoreboard;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    event gen_next_evt;

    bit [9:0] expected_s;
    bit expected_c;

    int pass_cnt = 0, fail_cnt = 0;

    function new(mailbox#(transaction) mon2scb_mbox,
                event gen_next_evt);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen_next_evt = gen_next_evt;
    endfunction


    task run();
        forever begin
            //get trasaction
            mon2scb_mbox.get(tr);
            if (tr.mode) begin
                {expected_c, expected_s} = tr.a - tr.b;
            end else begin
                {expected_c, expected_s} = tr.a + tr.b;
            end
            //pass fail
            if ({expected_c, expected_s} == {tr.c, tr.s}) begin
                $display("pass");
               
                pass_cnt++;
            end else begin
                //fail
                $display("faill");
                
                fail_cnt++;
            end
           tr.debug_print("scb");
           -> gen_next_evt;
        end

    endtask
endclass



class environment;
    generator              gen;
    driver                 drv;
    monitor                mon;
    scoreboard             scb;

    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;

    event                  drv2mon_evt;
    event                  gen_next_evt;

    function new(virtual adder_interface adder_if_v);
        gen2drv_mbox = new;
        mon2scb_mbox = new;
        gen = new(gen2drv_mbox, gen_next_evt);
        drv = new(gen2drv_mbox, drv2mon_evt, adder_if_v);
        mon = new(mon2scb_mbox, drv2mon_evt, adder_if_v);
        scb = new(mon2scb_mbox, gen_next_evt);
    endfunction

    task run(int run_count);  //tb에서 값 할당 env.run(10); 
        fork  //gen과 drv 각각 동작
            gen.run(run_count);
            drv.run();
            mon.run();
            scb.run();
        join_any
        $display("%t : end fork join", $time);
        #100;
        $display("pass count = %d", scb.pass_cnt);
        $display("fail count = %d", scb.fail_cnt);
    endtask


endclass



module tb_adder ();

    adder_interface adder_if ();
    environment env;
    generator   gen;

    adder dut_adder (
        .a(adder_if.a),
        .b(adder_if.b),
        .mode(adder_if.mode),
        .s(adder_if.s),
        .c(adder_if.c)
        //port 동일한 경우 자동 연결 .* 
    );

    initial begin
        $timeformat(-9, 0, " ns", 0);
        env = new(adder_if);
        env.run(10);  //데이터 횟수 지정 값 할당해주기
        $finish;
    end
endmodule