`default_nettype none 
`timescale 1ns / 1ns

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED at %2d in %m: signal != value", $time); \
            $finish; \
        end

module top_tb;

  localparam integer DATA_WIDTH = 8;

  reg clk;
  reg rst;
  wire [7:0] debug;

  Top #(
      .DATA_WIDTH(DATA_WIDTH)
  ) dut (
      .clk  (clk),
      .rst  (rst),
      .debug(debug)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 1'b1;
    rst = 1'b1;
  end

  initial begin
    $display("+------------------------------------------+");
    $display("|   RUN FIRST TESTBENCH - INITIALIZE RAM   |");
    $display("+------------------------------------------+");

    //CODE
    dut.ram.mem[0] = 8'b0010_1111;  //LOAD  (0x2F) ACC      = MEM[0xF]
    dut.ram.mem[1] = 8'b0000_1110;  //ADD   (0x0E) ACC      = ACC + MEW[0xE] (4 + 1)
    dut.ram.mem[2] = 8'b0011_1101;  //STORE (0x3D) MEM[0xD] = ACC
    dut.ram.mem[3] = 8'b0001_1110;  //SUB   (0x1E) ACC      = ACC - MEM[0xE] (5 - 1)
    dut.ram.mem[4] = 8'b0010_1101;  //LOAD  (0x2D) ACC      = MEM[0xD]
    dut.ram.mem[5] = 8'b0011_1000;  //STORE (0x38) MEM[0x8] = ACC
    dut.ram.mem[6] = 8'b0111_0000;  //JZ    (0x70) PC       = 0x00
    dut.ram.mem[7] = 8'b0000_0000;
    //DATA
    dut.ram.mem[8] = 8'b00000000;
    dut.ram.mem[9] = 8'b00000000;
    dut.ram.mem[10] = 8'b00000000;
    dut.ram.mem[11] = 8'b00000000;
    dut.ram.mem[12] = 8'b00000000;
    dut.ram.mem[13] = 8'b00000000;
    dut.ram.mem[14] = 8'b00000001; //(MEM[0xE]=0x01)
    dut.ram.mem[15] = 8'b00000100; //(MEM[0xF]=0x04)

    rst = 1'b1;
    #10;
    rst = 1'b0;
    #360;

    `assert(dut.ram.mem[8], 8'b00000101);
    `assert(dut.ram.mem[9], 8'b00000000);
    `assert(dut.ram.mem[10], 8'b0000000);
    `assert(dut.ram.mem[11], 8'b0000000);
    `assert(dut.ram.mem[12], 8'b0000000);
    `assert(dut.ram.mem[13], 8'b00000101);
    `assert(dut.ram.mem[14], 8'b00000001);
    `assert(dut.ram.mem[15], 8'b00000100);

    $display("");
    $display("+------------------------------------------+");
    $display("|   RUN SECOND TESTBENCH - INITIALIZE RAM   |");
    $display("+------------------------------------------+");

    //CODE
    dut.ram.mem[0] = 8'b0010_1111;  //LOAD  (0x2F) ACC      = MEM[0xF]
    dut.ram.mem[1] = 8'b0000_1110;  //ADD   (0x0E) ACC      = ACC + MEW[0xE] (15 + 2)
    dut.ram.mem[2] = 8'b0110_0101;  //JC    (0x65) PC       = 0x05
    dut.ram.mem[3] = 8'b0001_1110;  //SUB   (0x1E) ACC      = ACC - MEM[0xE] (15 - 2)
    dut.ram.mem[4] = 8'b0010_1101;  //LOAD  (0x2D) ACC      = MEM[0xD]
    dut.ram.mem[5] = 8'b0011_1000;  //STORE (0x38) MEM[0x8] = ACC
    dut.ram.mem[6] = 8'b0001_1101;  //SUB   (0x1D) ACC      = ACC - MEM[0xD] (1-1)
    dut.ram.mem[7] = 8'b0111_0000;  //JZ    (0x70) PC       = 0x00
    //DATA
    dut.ram.mem[8] = 8'b00000000;
    dut.ram.mem[9] = 8'b00000000;
    dut.ram.mem[10] = 8'b00000000;
    dut.ram.mem[11] = 8'b00000000;
    dut.ram.mem[12] = 8'b00000000;
    dut.ram.mem[13] = 8'b00000001;  //(MEM[0xD]=0x01)
    dut.ram.mem[14] = 8'b00000010;  //(MEM[0xE]=0x02)
    dut.ram.mem[15] = 8'b11111111;  //(MEM[0xF]=0xFF) 

    rst = 1'b1;
    #10;
    rst = 1'b0;
    #320;

    `assert(dut.ram.mem[8], 8'b00000001);
    `assert(dut.ram.mem[9], 8'b00000000);
    `assert(dut.ram.mem[10], 8'b0000000);
    `assert(dut.ram.mem[11], 8'b0000000);
    `assert(dut.ram.mem[12], 8'b0000000);
    `assert(dut.ram.mem[13], 8'b00000001);
    `assert(dut.ram.mem[14], 8'b00000010);
    `assert(dut.ram.mem[15], 8'b11111111);

    $display("");
    $display("+------------------------------------------+");
    $display("|   RUN THIRD TESTBENCH - INITIALIZE RAM   |");
    $display("+------------------------------------------+");
    //CODE
    dut.ram.mem[0] = 8'b0100_1111;  //LOAD  (0x4F) ACC      = IMME(#15)
    dut.ram.mem[1] = 8'b0000_1101;  //ADD   (0x0D) ACC      = ACC + MEM[0xD] (15 + 1)
    dut.ram.mem[2] = 8'b0110_0101;  //JC    (0x65) PC       = 0x05 
    dut.ram.mem[3] = 8'b0001_1110;  //SUB   (0x1E) ACC      = ACC - MEM[0xE] (15 - 2)
    dut.ram.mem[4] = 8'b0011_1001;  //STORE (0x39) MEM[0x9] = ACC
    dut.ram.mem[5] = 8'b0011_1000;  //STORE (0x38) MEM[0x8] = ACC
    dut.ram.mem[6] = 8'b0001_1000;  //SUB   (0x18) ACC      = ACC - MEM[0x8] (1-1)
    dut.ram.mem[7] = 8'b0111_0000;  //JZ    (0x70) PC       = 0x00
    //DATA
    dut.ram.mem[8] = 8'b00001111;
    dut.ram.mem[9] = 8'b00000000;
    dut.ram.mem[10] = 8'b00000000;
    dut.ram.mem[11] = 8'b00000000;
    dut.ram.mem[12] = 8'b00000000;
    dut.ram.mem[13] = 8'b00000001;  //(MEM[0xD]=0x01)
    dut.ram.mem[14] = 8'b00000010;  //(MEM[0xE]=0x02)
    dut.ram.mem[15] = 8'b11111111;  //(MEM[0xF]=0xFF) 

    rst = 1'b1;
    #10;
    rst = 1'b0;
    #420;

    `assert(dut.ram.mem[8], 8'b00001110);
    `assert(dut.ram.mem[9], 8'b00001110);
    `assert(dut.ram.mem[10], 8'b0000000);
    `assert(dut.ram.mem[11], 8'b0000000);
    `assert(dut.ram.mem[12], 8'b0000000);
    `assert(dut.ram.mem[13], 8'b00000001);
    `assert(dut.ram.mem[14], 8'b00000010);
    `assert(dut.ram.mem[15], 8'b11111111);
    $finish;

  end

  task print_ram;
    integer i;
    begin
      $display("Print RAM");
      for (i = 0; i < 16; i = i + 1) begin
        $display("ram[%0d]: %b", i, dut.ram.mem[i]);  // Accessing the DUT's RAM memory
      end
    end
  endtask

  // Define parameters for fixed string representations
  reg [0:31] PC = "PC";
  reg [0:31] INCR = "INCR";
  reg [0:31] MEM = "MEM";
  reg [0:31] ALU = "ALU";
  reg [0:31] ACC = "ACC";
  reg [0:31] TMP = "TMP";
  reg [0:31] CONTROLER = "CTRL";
  reg [0:31] UNKNOWN = "UKNW";

  always @(posedge clk) begin
    $display(
        "Time %2t, clk = %b, rst = %b, pc_reg = %2h, bus_access = %s, acc_reg = %2h, ir_reg = %2h",
        $time, clk, rst, dut.pc_reg.register, get_write_access_string(dut.ctrl.o_write_enable_bus),
        dut.acc.register, dut.ir.register);
  end

  // Function to get string representation of write_access
  function [31:0] get_write_access_string(input [7:0] access);
    begin
      case (access)
        8'h01:   get_write_access_string = PC;
        8'h02:   get_write_access_string = INCR;
        8'h04:   get_write_access_string = MEM;
        8'h08:   get_write_access_string = ALU;
        8'h10:   get_write_access_string = ACC;
        8'h20:   get_write_access_string = TMP;
        8'h40:   get_write_access_string = CONTROLER;
        default: get_write_access_string = UNKNOWN;
      endcase
    end
  endfunction

  
  initial begin
    $dumpfile("top_tb.vcd");
    $dumpvars;
  end

endmodule

