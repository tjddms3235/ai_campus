`timescale 1ns / 1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

//uart interface
interface uart_interface(input clk);
    
    logic      rst;
    logic      rx;
    logic      rx_done;
    logic[7:0] rx_data;  //from PC
    
endinterface

typedef enum bit[1:0] {
    FASTER,NORMAL, SLOWER
} kind_e;

//uart seq_item
class uart_seq_item extends uvm_sequence;
    
    rand bit [7:0] send_data; //range 0~255
    rand bit [9:0] interval;  //range 0~651 clk, unit 10clk
    kind_e         kind;      //uart frame baudrate mode
    bit            rst;       //dut reset, active positive
    logic          rx_done;   //1tick signal 
    logic    [7:0] rx_data;   //uart receive data, sync with rx_done

    
    `uvm_object_utils_begin(uart_seq_item)
        `uvm_field_int(send_data, UVM_ALL_ON)
        `uvm_field_int(interval, UVM_ALL_ON)
        `uvm_field_enum(kind_e,kind, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "uart_seq_item");
        super.new(name);
    endfunction

    function void debug_print(string name);
        `uvm_info(name, $sformatf(
             " send_data = %d, interval = %d, kind = %d, rst = %d,rx_done = %d, rx_data = %d",
                send_data,
                interval,
                kind,
                rst,
                rx_done,
                rx_data
                ), UVM_MEDIUM)
    endfunction

endclass

//sequence
class uart_rx_sequence extends uvm_sequence #(uart_seq_item);
    `uvm_object_utils(uart_rx_sequence)

    function new(string name = "uart_rx_seq");
        super.new(name);
    endfunction

   // taks body();
    
   // endtask

endclass

//uvm driver
class uart_rx_driver extends uvm_driver #(uart_seq_item);
    //factory registry
    `uvm_component_utils(uart_rx_driver)
    //virtual interface
    virtual uart_interface uart_vif;
    function new (string name ="uart_rx_drv", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("DRV","build phase!",UVM_LOW)
        //to get vitrual interface from uvm_config_db
        if (!uvm_config_db #(virtual uart_interface)::get(this,"", "uart_vif", uart_vif)) begin
            `uvm_fatal("uaur_rx_driver","uvm fatal error can't access uart_interface");
        end
    endfunction

endclass

class uart_rx_monitor_in extends uvm_monitor;
    //factory registry
    `uvm_component_utils(uart_rx_monitor_in)
    virtual uart_interface uart_vif;

    function new(string name = "uart_rx_mon_in", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("MON_IN","build phase!",UVM_LOW)
        //to get vitrual interface from uvm_config_db
        
        if (!uvm_config_db #(virtual uart_interface)::get(this,"", "uart_vif", uart_vif)) begin
            `uvm_fatal("mon_in","uvm fatal error can't access uart_interface");
        end
    endfunction

endclass

class uart_rx_monitor_out extends uvm_monitor;
    //factory registry
    `uvm_component_utils (uart_rx_monitor_out)
    virtual uart_interface uart_vif;

    function new(string name = "uart_rx_mon_out", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("mon_out","build phase!",UVM_LOW)
        //to get vitrual interface from uvm_config_db
        if (!uvm_config_db #(virtual uart_interface)::get(this, "", "uart_vif", uart_vif)) begin
            `uvm_fatal("mon_out","uvm fatal error can't access uart_interface");
        end
    endfunction

endclass

//uart rx in agent
class uart_agent_in extends uvm_agent;
   //factory registry
    `uvm_component_utils(uart_agent_in)
    uart_rx_driver      drv;
    uart_rx_monitor_in  mon_in;
    uvm_sequencer      #(uart_seq_item)  sqr;

    function new(string name = "uart_agt_in", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
         `uvm_info("agt_in","build phase!",UVM_LOW)
         drv    = uart_rx_driver::type_id::create("drv",this);
         mon_in = uart_rx_monitor_in::type_id::create("mon_in",this);
         sqr    = uvm_sequencer #(uart_seq_item)::type_id::create("sqr",this);
    endfunction
endclass
//uart rx out agent
class uart_agent_out extends uvm_agent;
   //factory registry
    `uvm_component_utils(uart_agent_out)
    uart_rx_monitor_out  mon_out;
    
    function new(string name = "uart_agt_out", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
         `uvm_info("agt_out","build phase!",UVM_LOW)
         mon_out = uart_rx_monitor_out::type_id::create("mon_out",this);
    endfunction
endclass

class uart_rx_environment extends uvm_env;
       //factory registry
    `uvm_component_utils(uart_rx_environment)

    uart_agent_in   agt_in;
    uart_agent_out  agt_out;

    function new(string name = "uart_rx_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("ENV","build phase!",UVM_LOW)
        agt_in = uart_agent_in::type_id::create("agt_in",this);
        agt_out = uart_agent_out::type_id::create("agt_out",this);
    endfunction

endclass

class uvm_test_uart extends uvm_test;
        //factory registry
    `uvm_component_utils(uvm_test_uart)
    uart_rx_environment env;   

    function new(string name = "uvm_test_uart", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uart_rx_environment::type_id::create("env",this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_root::get().print_topology();
    endfunction
endclass

module tb_uart_uvm();
    
    logic clk = 0;
    uart_interface uart_if (clk);
    
    always #5 clk =~clk;

    uart_top UART(
        .clk(clk),
        .rst(uart_if.rst),
        .rx(uart_if.rx),
        .rx_done(uart_if.rx_done),
        .rx_data(uart_if.rx_data)
    );

    initial begin
        uvm_config_db #(virtual uart_interface)::set(null,"*","uart_vif",uart_if);
        
        run_test("uvm_test_uart");
        $finish;
    end
endmodule
