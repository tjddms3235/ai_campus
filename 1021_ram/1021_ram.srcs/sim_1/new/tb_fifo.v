`timescale 1ns / 1ps

module tb_fifo ();
    parameter DEPTH = 4;
    reg clk, rst, push, pop;
    reg  [7:0] push_data;
    wire [7:0] pop_data;
    wire full, empty;


    //simulator, mon
    reg [7:0] compare_buffer[0:DEPTH-1];

    integer i;
    integer pass_cnt, fail_cnt;
    reg [1:0] push_cnt, pop_cnt;
    

    fifo #(
        .DEPTH(DEPTH)
    ) dut_fifo (
        .clk(clk),
        .rst(rst),
        .push(push),
        .pop(pop),
        .push_data(push_data),
        .pop_data(pop_data),
        .full(full),
        .empty(empty)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        push = 0;
        pop = 0;
        push_data = 0;
        i = 0;
        push_cnt = 0;
        pop_cnt = 0;

        pass_cnt =0;
        fail_cnt =0;

        @(negedge clk);
        @(negedge clk);

        rst = 0;
        @(negedge clk);
        if (full == 0) $display("%t : pass full signal", $stime);
        else $display("%t : fail full signal", $stime);


        if (empty == 1) $display("%t : pass empty signal", $stime);
        else $display("%t :fail empty signal", $stime);


        //push only
        for (i = 0; i < 5; i = i + 1) begin
            @(negedge clk);
            push_data = 8'h0a + i;
            push = 1'b1;
            if (!full) begin
                compare_buffer[push_cnt] = push_data;
                push_cnt = push_cnt + 1;
            end
        end
        @(negedge clk);
        push = 1'b0;

        //pop only
        for (i = 0; i < 5; i = i + 1) begin
            @(negedge clk);
            pop = 1'b1;
            
            if (!empty) begin
                if (pop_data == compare_buffer[pop_cnt]) begin
                    $display("%t : pass pop data = %d", $stime, pop_data);
                end else begin
                     $display("%t : fail pop data %d, compare =%d", $stime,
                        pop_data, compare_buffer[pop_cnt]);
                end
                pop_cnt = pop_cnt + 1;
            end
        end
        //empty state would be '1'/ 5번 pop :empty 상황 가정
        if (empty) begin
            $display("%t : pass empty siganl", $stime);
        end else begin
            $display("%t : fail empty siganl", $stime);
        end

        @(negedge clk);
        push = 1'b0;
        pop  = 1'b0;



        // push&pop
        for (i = 0; i < 5; i = i + 1) begin
            @(negedge clk);
            push = 1'b1;
            pop = 1'b1;
            push_data = 8'h0f - i;
            if (!full) begin
                compare_buffer[push_cnt] = push_data;
                push_cnt = push_cnt + 1;
            end
            pop = 1'b1;

            if (!empty) begin

                if (pop_data == compare_buffer[pop_cnt]) begin
                    $display("%t : pass pop data = %d", $stime, pop_data);
                end else begin
                    $display("%t : fail pop data %d, compare =%d", $stime,
                             pop_data, compare_buffer[pop_cnt]);
                end
                pop_cnt = pop_cnt + 1;
            end
        end

        @(negedge clk);
        push = 1'b0;
        pop  = 1'b1;
        pop_cnt = pop_cnt + 1;
        @(negedge clk);
        pop  = 1'b0;
        @(negedge clk);


        $display("to start random test");
        //3-1.random
        for (i = 0; i < 256; i = i + 1) begin
            @(negedge clk);
            push = $random() % 2;
            pop = $random() % 2;
            push_data = $random() % 256;
            
            //push1
            if(push &(!full)) begin
                compare_buffer[push_cnt] = push_data;
                push_cnt = push_cnt +1;
            end
            //pop1
            if(pop &(~empty)) begin
                if(pop_data == compare_buffer[pop_cnt]) begin
                    pass_cnt = pass_cnt +1;
                    $display ("%t : pass!",$stime);
                end else begin
                   // $display ("%t : fail!",$stime);
                    fail_cnt = fail_cnt +1;
                     $display("%t : fail pop data %d, compare =%d", $stime, pop_data, compare_buffer[pop_cnt]);
                end
            
                pop_cnt = pop_cnt +1;
            end
        end
        
        $display("** randaom tset result **");
        $display("*total test=        %d",i);
        $display("*pass count =       %d",pass_cnt);
        $display("*fail count =       %d",fail_cnt);
        #10;
        $finish;

    end
endmodule
