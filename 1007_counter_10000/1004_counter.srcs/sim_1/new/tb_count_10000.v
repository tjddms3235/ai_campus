
`timescale 1ns / 1ps

module tb_counter_datapass;

    reg clk;
    reg reset;
    reg sw0, sw1, sw2;

    wire [13:0] counter;

    integer errors;
    integer tick_count;
    integer count_count;

    reg [13:0] prev_counter;
    realtime prev_count_time;
    realtime sim_start;
    realtime now_time;
    reg prev_count_valid;

    // ==========================================
    // DUT : F_COUNT 변경 없음
    // ==========================================
    counter_datapass DUT (
        .clk(clk),
        .reset(reset),
        .sw0(sw0),
        .sw1(sw1),
        .sw2(sw2),
        .counter(counter)
    );

    // ==========================================
    // 100 MHz Clock
    // Period = 10 ns
    // ==========================================
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ==========================================
    // 스위치 변경 출력 Task
    // ==========================================
    task set_switch;
        input integer sw_num;
        input sw_value;

        reg old_value;
        reg [13:0] before_count;

        begin
            @(negedge clk);

            before_count = counter;

            case (sw_num)
                0: begin
                    old_value = sw0;
                    sw0 = sw_value;
                end

                1: begin
                    old_value = sw1;
                    sw1 = sw_value;
                end

                2: begin
                    old_value = sw2;
                    sw2 = sw_value;
                end
            endcase

            $display(
                "[SW%0d] %b -> %b | t=%0.6f ms | Before=%0d",
                sw_num,
                old_value,
                sw_value,
                $realtime / 1_000_000.0,
                before_count
            );
        end
    endtask

    // ==========================================
    // Counter 변경 감지 및 출력
    // ==========================================
    always @(counter) begin

        if ($realtime > 0 && !reset &&
            (^counter !== 1'bx)) begin

            now_time = $realtime;
            count_count = count_count + 1;

            $display(
                "[COUNT] t=%0.6f ms | %0d -> %0d",
                now_time / 1_000_000.0,
                prev_counter,
                counter
            );

            // RUN 중 연속 카운트 간격 출력
            if (sw0 && !sw1) begin
                if (prev_count_valid) begin
                    $display(
                        "        Interval = %0.6f ms",
                        (now_time - prev_count_time)
                        / 1_000_000.0
                    );
                end

                prev_count_time = now_time;
                prev_count_valid = 1'b1;
            end
            else begin
                prev_count_valid = 1'b0;
            end

            prev_counter = counter;
        end
    end

    // ==========================================
    // Tick 발생 횟수 기록
    // ==========================================
    initial tick_count = 0;

    always @(posedge DUT.w_tick) begin
        if (!reset)
            tick_count = tick_count + 1;
    end

    // ==========================================
    // 예상 Counter 확인 Task
    // ==========================================
    task check_count;
        input [13:0] expected;
        begin
            if (counter !== expected) begin
                errors = errors + 1;
                $display(
                    "[FAIL] Expected=%0d Actual=%0d",
                    expected, counter
                );
            end
            else begin
                $display(
                    "[PASS] Counter=%0d | t=%0.6f ms",
                    counter,
                    $realtime / 1_000_000.0
                );
            end
        end
    endtask

    // ==========================================
    // Timeout
    // ==========================================
    initial begin
        #4_000_000_000;
        $fatal(1, "SIMULATION TIMEOUT");
    end

    // ==========================================
    // Main Scenario
    // ==========================================
    initial begin

        reset = 0;
        sw0 = 0;
        sw1 = 0;
        sw2 = 0;

        errors = 0;
        count_count = 0;
        prev_counter = 0;
        prev_count_time = 0;
        prev_count_valid = 0;

        sim_start = $realtime;

        $display("");
        $display("==============================================");
        $display("       COUNTER SIMULATION START");
        $display("       Clock=100 MHz, Tick=10 Hz");
        $display("==============================================");

        // --------------------------------------
        // 1. RESET -> 9900
        // --------------------------------------
        $display("\n========== TEST 1 : RESET ==========");

       
         #20;
        reset = 1;
        #20;
        reset = 0;
        #10;

        prev_counter = counter;
        check_count(14'd9900);

        // --------------------------------------
        // 2. STOP : 9900 유지
        // --------------------------------------
        $display("\n========== TEST 2 : STOP ==========");

        repeat (2) @(posedge DUT.w_tick);
        @(negedge clk);
        #1;

        check_count(14'd9900);

        // --------------------------------------
        // 3. UP : 9900 -> 9910
        // --------------------------------------
        $display("\n========== TEST 3 : UP ==========");

        set_switch(0, 1'b1);  // RUN

        wait(counter == 14'd9910);
        @(negedge clk);

        check_count(14'd9910);

        // --------------------------------------
        // 4. STOP : 9910 유지
        // --------------------------------------
        $display("\n========== TEST 4 : STOP ==========");

        set_switch(0, 1'b0);

        repeat (2) @(posedge DUT.w_tick);
        @(negedge clk);
        #1;

        check_count(14'd9910);

        // --------------------------------------
        // 5. CLEAR : 9910 -> 0
        // --------------------------------------
        $display("\n========== TEST 5 : CLEAR ==========");

        set_switch(1, 1'b1);

        @(negedge clk);
        #1;

        check_count(14'd0);

        set_switch(1, 1'b0);

        // --------------------------------------
        // 6. DOWN : 0 -> 9999 -> 9985
        // --------------------------------------
        $display("\n========== TEST 6 : DOWN ==========");

        set_switch(2, 1'b1);  // DOWN
        set_switch(0, 1'b1);  // RUN

        wait(counter == 14'd9999);
        @(negedge clk);

        check_count(14'd9999);

        wait(counter == 14'd9985);
        @(negedge clk);

        check_count(14'd9985);

        // --------------------------------------
        // 7. FINAL STOP
        // --------------------------------------
        $display("\n========== TEST 7 : FINAL STOP ==========");

        set_switch(0, 1'b0);

        repeat (2) @(posedge DUT.w_tick);
        @(negedge clk);
        #1;

        check_count(14'd9985);

        // --------------------------------------
        // SUMMARY
        // --------------------------------------
        $display("");
        $display("==============================================");
        $display("          SIMULATION SUMMARY");
        $display("==============================================");

        $display(
            "Total Simulation Time : %0.6f ms",
            ($realtime - sim_start) / 1_000_000.0
        );

        $display("Total Tick Pulses     : %0d", tick_count);
        $display("Counter Changes       : %0d", count_count);
        $display("Final Counter         : %0d", counter);
        $display("Errors                : %0d", errors);

        if (errors == 0)
            $display("RESULT                : PASS");
        else
            $display("RESULT                : FAIL");

        $display("==============================================");

        $finish;
    end

endmodule
