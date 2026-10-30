`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/30 11:38:37
// Design Name: 
// Module Name: tb11
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


module tb11();
    reg clk, rst, btnR;
    wire dht11_io;
    reg sensor_io;
    reg [39:0] sensor_data;
    reg [15:0] humidity, temperature;
    reg [7:0] check_sum; 
    integer i;

top_dht11 dut_dht11(
    .clk(clk),
    .rst(rst),
    .btnR(btnR),
    .dht11_io(dht11_io)
);




always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    btnR = 1'b0;
    sensor_io =1;
    i=0;
    humidity= {8'd50,8'd01};
    temperature = {8'd25, 8'd01};
    check_sum = humidity[15:8] + humidity[7:0] + temperature[15:8]+temperature[7:0];
    sensor_data = {humidity,temperature,check_sum};

    #10;
    rst = 0;


    #10;
    btnR = 1;
    #10_000;
    btnR = 0; 

    //start 
    @(posedge dht11_io);
   // @(19_000_000);

    #(20_000); //20usec wait

    force dht11_io= sensor_io;
    //sensor io pattern
    //sync, repose sensor
    sensor_io = 1'b0;
    #(80_000); //80usec low
    sensor_io = 1'b1;
    #(80_000); //
    

    //data pattern1 :  
    for (i =0; i<40; i=i+1) begin
        sensor_io = 1'b0;
        #(50_000);
        if(sensor_data[39-i]) begin
            sensor_io= 1'b1;
            #(70_000);
        end else begin
            //data bit 0
            sensor_io= 1'b1;
            #(30_000);
        end 
         sensor_io= 1'b1;
        #(50_000);
    end
    release dht11_io;
#(100);
$finish;

end


endmodule




// `timescale 1ns / 1ps

// module tb11();

//     reg clk, rst, btnR;
//     wire dht11_io;

//     reg sensor_io;
//     reg [39:0] sensor_data;
//     reg [15:0] humidity, temperature;
//     reg [7:0] check_sum;

//     integer i;

//     top_dht11 dut_dht11 (
//         .clk(clk),
//         .rst(rst),
//         .btnR(btnR),
//         .dht11_io(dht11_io)
//     );

//     // 100MHz clock
//     always #5 clk = ~clk;

//     // Sensor output control
//     // 0 : Sensor drives Low
//     // 1 : Sensor releases bus (Hi-Z)
//     assign dht11_io = (sensor_io == 0) ? 1'b0 : 1'bz;

//     // External pull-up
//     pullup(dht11_io);


//     initial begin

//         clk = 0;
//         rst = 1;
//         btnR = 0;
//         sensor_io = 1;

//         i = 0;

//         humidity    = {8'd50, 8'd01};
//         temperature = {8'd25, 8'd01};

//         check_sum = humidity[15:8] +
//                     humidity[7:0] +
//                     temperature[15:8] +
//                     temperature[7:0];

//         sensor_data = {humidity, temperature, check_sum};

//         #10;
//         rst = 0;

//         #10;
//         btnR = 1;
//         #10_000;
//         btnR = 0;


//         // ----------------------------------
//         // START: Wait for FPGA to release bus
//         // ----------------------------------
//         @(posedge dht11_io);

//         #(20_000); // 20us wait


//         // ----------------------------------
//         // Sensor Response
//         // ----------------------------------
//         sensor_io = 1'b0;
//         #(80_000); // 80us Low

//         sensor_io = 1'b1;
//         #(80_000); // 80us High


//         // ----------------------------------
//         // Data Transmission: 40 bits
//         // ----------------------------------
//         for (i = 0; i < 40; i = i + 1) begin

//             // 50us Low
//             sensor_io = 1'b0;
//             #(50_000);

//             // Data High
//             sensor_io = 1'b1;

//             if (sensor_data[39-i]) begin
//                 #(70_000); // Data 1
//             end
//             else begin
//                 #(28_000); // Data 0
//             end

//         end


//         // ----------------------------------
//         // Sensor End Signal
//         // ----------------------------------
//         sensor_io = 1'b0;
//         #(50_000); // 50us Low

//         // Release bus
//         sensor_io = 1'b1;

//         #(200_000);

//         $finish;

//     end

// endmodule
