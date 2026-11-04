// `timescale 1ns / 1ps

// 1. 기본 구조
// class transaction; //변수 선언을 위한 자료형(객체)만 생성/
//     rand bit [7:0] a;
//     rand bit [7:0] b;
//     rand bit       mode;
    
//     // monior variable
//     logic [7:0] s;
//     logic       c;    
// endclass

// class generator; //벡터 생성 동작 실행을 위한 객체 생성
//     transaction tr; //handle 선언(pointer). 나중에 'new'를 통해 동적 할당함.
//     virtual adder_interface adder_if_v; 
//     //객체에서 연결할 때는 virtual 사용(선언만)
//     function new(virtual adder_interface adder_if_v_a); //function new(); 을 통해 호출 될 때 만 할당
//         adder_if_v = adder_if_v_a;  //virtual connection
//         //제너레이터 생성 시 adder_if_v_a를 통해 adder_interface와 연결
//         //adder_if_v_a는 빵 내용물, adder_if_v는 빵 틀 
           //adder_if_v 는 객체만 (실제 내용물 없음)
           //new 하면서 내용물? 생성  ->adder_if_v = adder_if_v_a; 연결해줌
//         tr = new; // new를 통해 동적 할당.
//     endfunction

//     task run();
//         repeat (10) begin
//             //to generate for randomize stimulus by tr
//             tr.randomize();
//             //drive
//             adder_if_v.a = tr.a;
//             adder_if_v.b = tr.b;
//             adder_if_v.mode = tr.mode;
//             #10;
//         end
//     endtask

// endclass

// interface adder_interface ();
//     logic [7:0] a, b;
//     logic       mode;
//     logic [7:0] s;
//     logic       c;
// endinterface

// module tb_adder ();

//     adder_interface   adder_if ();
//     generator gen;    
    
//     adder dut_adder (
//         .a(adder_if.a),
//         .b(adder_if.b),
//         .mode(adder_if.mode),
//         .s(adder_if.s),
//         .c(adder_if.c)
//         //port 동일한 경우 자동 연결 .* 
//     );

//     initial begin
//         gen = new(adder_if); 
//         gen.run();
//         $finish;
//     end
// endmodule


// 2. class environment 내  generator와 data drive 두개의 class를 생성, 실행
// generator 랜덤 값 생성, driver는 generator에서 생성된 랜덤 값 drive 
// `timescale 1ns / 1ps
// interface adder_interface ();
//     logic [7:0] a, b;
//     logic       mode;
//     logic [7:0] s;
//     logic       c;
// endinterface

// class transaction; //변수 선언을 위한 자료형(객체)만 생성/
//     rand bit [7:0] a;
//     rand bit [7:0] b;
//     rand bit       mode;
    
//     // monior variable
//     logic [7:0] s;
//     logic       c;   


// endclass

// class generator; 
//     transaction tr; 

//     mailbox #(transaction) gen2drv_mbox;

//     function new(mailbox #(transaction) gen2drv_mbox_a); //transaction 형식으로 데이터 전달
//         gen2drv_mbox = gen2drv_mbox_a;
//     endfunction

//     task run();
//         repeat (10) begin
//             tr = new; 
//             //계속 tr 생성. 
//             //수정 전 코드 function new 안에서 tr =new 실행 (주소 하나에 값 10번 덮어씀 //결국 마지막 값만 할당될 수 도 있음)
//             tr.randomize();
//             gen2drv_mbox.put(tr);
//         end
//     endtask
// endclass

// class driver;
//     transaction tr;
//     mailbox#(transaction) gen2drv_mbox;

//     virtual adder_interface adder_if_v;
    
//     function new(mailbox #(transaction) gen2drv_mbox_a, 
//                  virtual adder_interface adder_if_v_a);
        
//         gen2drv_mbox = gen2drv_mbox_a;
//         adder_if_v = adder_if_v_a;
//     endfunction

//     task run();
//         forever begin
//         gen2drv_mbox.get(tr); //get : tr 비어있는 경우 wait
//         //drive
//              adder_if_v.a = tr.a;
//              adder_if_v.b = tr.b;
//              adder_if_v.mode = tr.mode;
//             #10;
//         end

//     endtask
// endclass

// class environment;
//     generator gen;
//     driver drv;

//     mailbox #(transaction) gen2drv_mbox;

//     function new(virtual adder_interface adder_if_v); 
//         gen2drv_mbox = new();
//         gen =new(gen2drv_mbox);
//         drv = new(gen2drv_mbox,adder_if_v);
//     endfunction

//     task run();
//         forever begin //drive 가 forever loop 안에 있어서 environment 가 끝나지 않음.
//             gen.run();
//             drv.run();
//         end
//     endtask
// endclass



// module tb_adder ();

//     adder_interface   adder_if ();
//     environment env;
//     generator gen;    
    
//     adder dut_adder (
//         .a(adder_if.a),
//         .b(adder_if.b),
//         .mode(adder_if.mode),
//         .s(adder_if.s),
//         .c(adder_if.c)
//         //port 동일한 경우 자동 연결 .* 
//     );

//     initial begin
//         env = new(adder_if);
//         env.run();
//         $finish;     
//     end
// endmodule


// 3. 
`timescale 1ns / 1ps
interface adder_interface ();
    logic [7:0] a, b;
    logic       mode;
    logic [8:0] s;
    logic       c;
endinterface

class transaction; //변수 선언을 위한 자료형(객체)만 생성/
    rand bit [7:0] a;
    rand bit [7:0] b;
    rand bit       mode;
    
    // monior variable
    logic [8:0] s;
    logic       c;   

    function debug_print(string name);
        $display("%t : [%s] a=%d, b=%d, mode=%d, s=%d, c=%d", $time, name, a,b, mode, s, c);
    endfunction

endclass

class generator; 
    transaction tr; 

    mailbox #(transaction) gen2drv_mbox; //put 시 데이터 전달, get 시 데이터 수신(driver에서 get)

    function new(mailbox #(transaction) gen2drv_mbox_a); //객체 생성 초기화 /transaction 형식으로 데이터 전달
        gen2drv_mbox = gen2drv_mbox_a; //assign 처럼 연결한다는 개념으로 접근할 것
    endfunction

    task run();
        repeat (256) begin
            tr = new; 
            //계속 tr 생성. 
            //수정 전 코드 function new 안에서 tr =new 실행 (주소 하나에 값 10번 덮어씀 //결국 마지막 값만 할당될 수 도 있음)
            tr.randomize();
            tr.debug_print("gen");
            gen2drv_mbox.put(tr);
        end
    endtask
endclass

class driver;
    transaction tr;
    mailbox#(transaction) gen2drv_mbox;

    virtual adder_interface adder_if_v;
    
    function new(mailbox #(transaction) gen2drv_mbox_a, 
                 virtual adder_interface adder_if_v_a);
        gen2drv_mbox = gen2drv_mbox_a;
        adder_if_v = adder_if_v_a;
    endfunction

    task run();
        forever begin
        gen2drv_mbox.get(tr); //get : tr 비어있는 경우 wait
         tr.debug_print("drv");
        //drive
             adder_if_v.a = tr.a;
             adder_if_v.b = tr.b;
             adder_if_v.mode = tr.mode;
            #10;
        end

    endtask
endclass

class environment; //다른 객체들 연결 
    generator gen;
    driver drv;

    mailbox #(transaction) gen2drv_mbox;

    function new(virtual adder_interface adder_if_v); 
        gen2drv_mbox = new();
        gen =new(gen2drv_mbox);
        drv = new(gen2drv_mbox,adder_if_v);
    endfunction

    task run();
        forever begin //drive 가 forever loop 안에 있어서 environment 가 끝나지 않음.
            gen.run();
            drv.run();
        end
    endtask
endclass



module tb_adder ();

    adder_interface   adder_if ();
    environment env;
    generator gen;    
    
    adder dut_adder (
        .a(adder_if.a),
        .b(adder_if.b),
        .mode(adder_if.mode),
        .s(adder_if.s),
        .c(adder_if.c)
        //port 동일한 경우 자동 연결 .* 
    );

    initial begin
        $timeformat(-9, 0, " ns", 0); //-9: 나노, 0: 소수점 이하 0자리
        env = new(adder_if);
        env.run();
        $finish;
    end
endmodule