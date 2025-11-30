`default_nettype none
`timescale 1ns/1ns

`define assert(signal, value)\
    if (signal !== value) begin\
    $display("Assertion Failed at %2d in %m: signal != value", $time);\
    $finish;\
    end

module Alu_tb;
    localparam DATA_WIDTH = 8;

    //variables to connect to dut ports
    reg clk;
    reg rst;
    reg opcode;
    reg bus_writable;
    reg [DATA_WIDTH-1:0]a;
    reg [DATA_WIDTH-1:0]b;


    Alu #(.DATA_WIDTH(DATA_WIDTH)) dut (
        .i_clk(clk),
        .i_rst(rst),
        .i_opcode(opcode),
        .i_bus_writable(bus_writable),
        .i_a(a),
        .i_b(b)
    );


    initial begin
        //initialize signals
        clk = 0;
        rst = 1;
        bus_writable = 0;
        opcode = 1'b1;
        a = 8'b00000000;
        b = 8'b11111111;

    @(posedge clk); //check reset 
    #1
    `assert(dut.o_jc, 1'b0);
    `assert(dut.o_jz, 1'b0);

    @(negedge clk); //let alu drive bus and release rst
    rst = 0;
    bus_writable = 1'b1;

    @(posedge clk);
    #1
    `assert(dut.o_c, 8'b11111111);
    `assert(dut.o_jc, 1'b0);
    `assert(dut.o_jz, 1'b0);

    @(negedge clk);
    a = 8'b11111111;
    b = 8'b00000001;

    @(posedge clk); // check addition with carry
    #1
    `assert(dut.tmp, 8'b00000000);
    `assert(dut.carry, 1'b1);
    `assert(dut.o_jc, 1'b1);
    `assert(dut.o_jz, 1'b0);

    @(negedge clk); //set to subtract
    opcode = 1'b0;
    a = 8'b11110000;
    b = 8'b11110000;

    @(posedge clk); //check subtraction with zero flag
    #1
    `assert(dut.tmp, 8'b0);
    `assert(dut.carry, 1'b0);
    `assert(dut.o_jz, 1'b1);
    `assert(dut.o_jc, 1'b0);

    @(negedge clk); //set to subtract with carry needed
    a = 8'b00000001;
    b = 8'b00000010;

    @(posedge clk); //check subtraction with carry needed
    #1
    `assert(dut.tmp, 8'b11111111);
    `assert(dut.carry, 1'b1);
    `assert(dut.o_c, 8'b11111111);
    `assert(dut.o_jc, 1'b1);
    `assert(dut.o_jz, 1'b0);

    @(negedge clk); //check theat when we = 0, o_c = z
    bus_writable = 1'b0;

    @(posedge clk); 
    #1
    `assert(dut.o_c, {DATA_WIDTH{1'bz}});

    #5
    $display("TestBench Passed!");
    $finish;
    end

    always #5 clk = ~clk;

    always @(posedge clk) begin 
       $display("Clock toggled at time %2t, clk = %0b, bus_writable = %0b, opcode = %0b, a = %0b, b = %0b", $time, clk, bus_writable,opcode,a,b); 
        end  

    initial begin 
        $dumpfile("Alu.vcd"); 
        $dumpvars;  
        end 

endmodule