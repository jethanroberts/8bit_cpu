`default_nettype none
`timescale 1ns/1ns

module Top #(
    parameter DATA_WIDTH = 8
) (
    //inputs
    input clk,
    input rst,
    //output
    output [DATA_WIDTH-1:0] debug
);

    wire [4:0] write_enable_bus;
    wire opcode;
    wire we_mem;
    wire load_pc;
    wire load_acc;
    wire load_tmp;
    wire load_mar;
    wire load_imme;
    wire load_jmp;
    wire load_inst;
    wire [DATA_WIDTH-1:0] o_tmp;
    wire [DATA_WIDTH-1:0] o_acc;
    wire [DATA_WIDTH-1:0] bus;
    wire [DATA_WIDTH-1:0] o_pc;
    wire [DATA_WIDTH-1:0] o_mar;
    wire [DATA_WIDTH-1:0] inst;
    wire jc;
    wire jz;

    Controller #( 
        .DATA_WIDTH(DATA_WIDTH)
    ) ctrl (
        .i_clk(clk),
        .i_rst(rst),
        .i_inst(inst),
        .i_jz(jz),
        .i_jc(jc),
        .o_write_enable_bus(write_enable_bus),
        .o_opcode(opcode),
        .o_we_mem(we_mem),
        .o_load_pc(load_pc),
        .o_load_acc(load_acc),
        .o_load_inst(load_inst),
        .o_load_mar(load_mar),
        .o_load_tmp(load_tmp),
        .o_jmp(load_jmp),
        .o_imme(load_imme)
    );

    Register #(
        .DATA_WIDTH(DATA_WIDTH)
    ) pc_reg (
        .i_clk(clk),
        .i_rst(rst),
        .i_we(load_pc),
        .i_bus_writable(write_enable_bus[0]),
        .o_pc(o_pc),                                //change to .o_data after testing
        .io_data(bus)
    );

    Incrementer #(
      .DATA_WIDTH(DATA_WIDTH)
    ) inc (
      .i_pc(o_pc),
      .i_bus_writable(write_enable_bus[1]),
      .o_pc(bus)
    );

    Ram #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ram (
        .i_clk(clk),
        .i_we(we_mem),
        .i_bus_writable(write_enable_bus[2]),
        .i_jmp_imme(load_jmp | load_imme),
        .i_addr(o_mar),
        .io_data(bus)
    );

    Register #(
      .DATA_WIDTH(DATA_WIDTH)
    ) mar (
      .i_clk(clk),
      .i_rst(rst),
      .i_we(load_mar),
      .i_bus_writable(1'b0),
      .o_pc(o_mar),
      .io_data(bus)
    );

    Register #(
      .DATA_WIDTH(DATA_WIDTH)
    ) ir (
      .i_clk(clk),
      .i_rst(rst),
      .i_we(load_inst),
      .i_bus_writable(1'b0),
      .o_pc(inst),
      .io_data(bus)
    );

     Alu #(
      .DATA_WIDTH(DATA_WIDTH)
    ) alu (
      .i_clk(clk),
      .i_rst(rst),
      .i_a(o_acc),
      .i_b(o_tmp),
      .i_opcode(opcode),
      .i_bus_writable(write_enable_bus[3]),
      .o_c(bus),
      .o_jc(jc),
      .o_jz(jz)
    ); 

      Register #(
      .DATA_WIDTH(DATA_WIDTH)
    ) acc (
      .i_clk(clk),
      .i_rst(rst),
      .i_we(load_acc),
      .i_bus_writable(write_enable_bus[4]),
      .o_pc(o_acc),
      .io_data(bus)
    );

    assign debug = bus;

    Register #(
      .DATA_WIDTH(DATA_WIDTH)
    ) tmp (
      .i_clk(clk),
      .i_rst(rst),
      .i_we(load_tmp),
      .i_bus_writable(1'b0),
      .o_pc(o_tmp),
      .io_data(bus)
    );

endmodule

