`default_nettype none
`timescale 1ns/1ns

`define assert(signal, value) \
    if (signal !== value) begin \
        $display("Assertion Failed at %2d in %m: Signal != value", $time); \
        $finish; \
    end 

module controller_tb;

    localparam DATA_WIDTH = 8;

    reg clk;
    reg rst;
    reg [DATA_WIDTH-1:0] inst;
    reg jc;
    reg jz;

    wire [7:0] write_enable_bus;
    wire opcode;
    wire we_mem;
    wire load_pc;
    wire load_tmp;
    wire load_mar;
    wire load_inst;
    wire load_acc;
    wire jmp;
    wire imme;

    //Write enable bus access
    localparam PC           = 8'b0000_0001;
    localparam INCREMENTER  = 8'b0000_0010;
    localparam MEM          = 8'b0000_0100;
    localparam ALU          = 8'b0000_1000;
    localparam ACC          = 8'b0001_0000;
    localparam TMP          = 8'b0010_0000;
    localparam DECODER      = 8'b0100_0000;

    //Decoding Operations
    localparam OP_ADD   = 4'b0000;
    localparam OP_SUB   = 4'b0001;
    localparam OP_LOAD  = 4'b0010;
    localparam OP_STORE = 4'b0011;
    localparam OP_IMME  = 4'b0100;
    localparam OP_JMP   = 4'b0101;
    localparam OP_JC    = 4'b0110;
    localparam OP_JZ    = 4'b0111;

    Controller #(.DATA_WIDTH(DATA_WIDTH)) dut (
        //inputs
        .i_clk(clk),
        .i_rst(rst),
        .i_inst(inst),
        .i_jc(jc),
        .i_jz(jz),
        //outputs
        .o_write_enable_bus(write_enable_bus),
        .o_opcode(opcode),
        .o_we_mem(we_mem),
        .o_load_pc(load_pc),
        .o_load_acc(load_acc),
        .o_load_tmp(load_tmp),
        .o_load_mar(load_mar),
        .o_load_inst(load_inst),
        .o_jmp(jmp),
        .o_imme(imme)
    );

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        inst = 8'b00; // OP ADD/SUB to MEM[0]
        jc = 1'b0;
        jz = 1'b0;

    //CHECKING ADD INST PATH FIRST

    @(posedge clk); // checking state, PC OUT, after reset
    #1
    `assert(write_enable_bus, PC);
    `assert(we_mem, 1'b0);
    `assert(load_pc, 1'b0);
    `assert(load_acc, 1'b0);
    `assert(load_tmp, 1'b0);
    `assert(load_mar, 1'b1);
    `assert(load_inst, 1'b0);
    `assert(jmp, 1'b0);
    `assert(imme, 1'b0);
    
    @(negedge clk); //turns off reset, should start going through states now
    rst = 1'b0;

    @(posedge clk); //State = load IR
    #1
    `assert(write_enable_bus, MEM);
    `assert(we_mem, 1'b0);
    `assert(load_pc, 1'b0);
    `assert(load_acc, 1'b0);
    `assert(load_tmp, 1'b0);
    `assert(load_mar, 1'b0);
    `assert(load_inst, 1'b1);
    `assert(jmp, 1'b0);
    `assert(imme, 1'b0);

    @(posedge clk); // State = Decode (ADD)
    #1
    `assert(write_enable_bus, MEM);
    `assert(we_mem, 1'b0);
    `assert(load_pc, 1'b0);
    `assert(load_acc, 1'b0);
    `assert(load_tmp, 1'b0);
    `assert(load_mar, 1'b1);
    `assert(load_inst, 1'b0);
    `assert(jmp, 1'b0);
    `assert(imme, 1'b0);

    @(posedge clk); // State = Load Tmp
    #1
    `assert(write_enable_bus, MEM);
    `assert(we_mem, 1'b0);
    `assert(load_pc, 1'b0);
    `assert(load_acc, 1'b0);
    `assert(load_tmp, 1'b1);
    `assert(load_mar, 1'b0);
    `assert(load_inst, 1'b0);
    `assert(jmp, 1'b0);
    `assert(imme, 1'b0);

    @(posedge clk); //State = Execute
    #1
    `assert(write_enable_bus, ALU);
    `assert(we_mem, 1'b0);
    `assert(load_pc, 1'b0);
    `assert(load_acc, 1'b1);
    `assert(load_tmp, 1'b0);
    `assert(load_mar, 1'b0);
    `assert(load_inst, 1'b0);
    `assert(jmp, 1'b0);
    `assert(imme, 1'b0);

    @(posedge clk); //State = Increment PC
    #1
    `assert(write_enable_bus, INCREMENTER);
    `assert(we_mem, 1'b0);
    `assert(load_pc, 1'b1);
    `assert(load_acc, 1'b0);
    `assert(load_tmp, 1'b0);
    `assert(load_mar, 1'b0);
    `assert(load_inst, 1'b0);
    `assert(jmp, 1'b0);
    `assert(imme, 1'b0);
    
    @(posedge clk); //State = PC Out
    #1
    `assert(write_enable_bus, PC);
    `assert(we_mem, 1'b0);
    `assert(load_pc, 1'b0);
    `assert(load_acc, 1'b0);
    `assert(load_tmp, 1'b0);
    `assert(load_mar, 1'b1);
    `assert(load_inst, 1'b0);
    `assert(jmp, 1'b0);
    `assert(imme, 1'b0);

    #1
    $display("ADD PATH COMPLETED SUCCESSFULLY");
    

    // ONE FULL CYCLE COMPLETE
    // NOW CHECKING LOAD PATH

    @(negedge clk); //instr set to OP_LOAD to MEM[0]
    inst = {OP_LOAD, 4'b0000};

    @(posedge clk); //State = load IR
    #1
    `assert(write_enable_bus, MEM);
    `assert(we_mem, 1'b0);
    `assert(load_pc, 1'b0);
    `assert(load_acc, 1'b0);
    `assert(load_tmp, 1'b0);
    `assert(load_mar, 1'b0);
    `assert(load_inst, 1'b1);
    `assert(jmp, 1'b0);
    `assert(imme, 1'b0);

    @(posedge clk); // State = Decode (OP_LOAD)
    #1
    `assert(write_enable_bus, MEM);
    `assert(we_mem, 1'b0);
    `assert(load_pc, 1'b0);
    `assert(load_acc, 1'b0);
    `assert(load_tmp, 1'b0);
    `assert(load_mar, 1'b1);
    `assert(load_inst, 1'b0);
    `assert(jmp, 1'b0);
    `assert(imme, 1'b0);

    @(posedge clk); // State = LOAD ACC
    #1 
    `assert(write_enable_bus, MEM);
    `assert(we_mem, 1'b0);
    `assert(load_pc, 1'b0);
    `assert(load_acc, 1'b1);
    `assert(load_tmp, 1'b0);
    `assert(load_mar, 1'b0);
    `assert(load_inst, 1'b0);
    `assert(jmp, 1'b0);
    `assert(imme, 1'b0);

    @(posedge clk); //State = Increment PC
    #1
    `assert(write_enable_bus, INCREMENTER);
    `assert(we_mem, 1'b0);
    `assert(load_pc, 1'b1);
    `assert(load_acc, 1'b0);
    `assert(load_tmp, 1'b0);
    `assert(load_mar, 1'b0);
    `assert(load_inst, 1'b0);
    `assert(jmp, 1'b0);
    `assert(imme, 1'b0);

    @(posedge clk); //State = PC Out
    #1
    `assert(write_enable_bus, PC);
    `assert(we_mem, 1'b0);
    `assert(load_pc, 1'b0);
    `assert(load_acc, 1'b0);
    `assert(load_tmp, 1'b0);
    `assert(load_mar, 1'b1);
    `assert(load_inst, 1'b0);
    `assert(jmp, 1'b0);
    `assert(imme, 1'b0);

    #1
    $display("LOAD PATH COMPLETED SUCCESSFULLY");
    

    //Second Cycle Complete
    //NOW TESTING IMME

    @(posedge clk); //State = load IR
    #1
    `assert(write_enable_bus, MEM);
    `assert(we_mem, 1'b0);
    `assert(load_pc, 1'b0);
    `assert(load_acc, 1'b0);
    `assert(load_tmp, 1'b0);
    `assert(load_mar, 1'b0);
    `assert(load_inst, 1'b1);
    `assert(jmp, 1'b0);
    `assert(imme, 1'b0);

    @(negedge clk); // set inst to imme
    inst = {OP_IMME, 4'b000};

    @(posedge clk); // State = DECODE (Imme) which immediately loads ACC with instr from MEM
    #1
    `assert(write_enable_bus, MEM);
    `assert(we_mem, 1'b0);
    `assert(load_pc, 1'b0);
    `assert(load_acc, 1'b1);
    `assert(load_tmp, 1'b0);
    `assert(load_mar, 1'b0);
    `assert(load_inst, 1'b0);
    `assert(jmp, 1'b0);
    `assert(imme, 1'b1);

    @(posedge clk); // State = Increment PC
    #1
    `assert(write_enable_bus, INCREMENTER);
    `assert(we_mem, 1'b0);
    `assert(load_pc, 1'b1);
    `assert(load_acc, 1'b0);
    `assert(load_tmp, 1'b0);
    `assert(load_mar, 1'b0);
    `assert(load_inst, 1'b0);
    `assert(jmp, 1'b0);
    `assert(imme, 1'b0);

    #1
    $display("IMME PATH COMPLETED SUCCESSFULLY");
    $finish;
    end

    always #5 clk = ~clk;

    always @(posedge clk) begin
        $display("Clock toggled at time %2t, clk = %0b, rst = %0b, inst = %8b, jc = %0b, jz = %0b, write_enable_bus = %8b, opcode = %0b, we_mem = %0b, load_pc = %0b, load_acc = %0b, load_tmp = %0b, load_mar = %0b, load_inst = %0b, jmp = %0b, imme = %0b",               $time, clk, rst, inst, jc, jz, write_enable_bus, opcode, we_mem, load_pc, load_acc, load_tmp, load_mar, load_inst, jmp, imme);
    end

    initial begin 
        $dumpfile("Controller.vcd"); 
        $dumpvars;  
        end 

endmodule