`default_nettype none
`timescale 1ns /1ns

`define assert(signal, value)\
    if (signal !== value) begin\
    $display("Assertion Failed at %2d in %m: signal != value", $time);\
    $finish;\
    end 

module Ram_tb;
    localparam DATA_WIDTH = 8;
    localparam MEM_SIZE = 16;
    
    // variables controlling dut
    reg clk;
    reg we;
    reg bus_writable;
    reg jmp_imme;
    reg [DATA_WIDTH-1:0]addr;

    // variables controlling tb
    reg [DATA_WIDTH-1:0] io_data_driver;
    reg io_data_drive_enable;

    //shared variables
    wire [DATA_WIDTH-1:0] io_data;

    assign io_data = (io_data_drive_enable) ? io_data_driver : {DATA_WIDTH{1'bz}};

    //instantiation of Ram and connecting ports to tb
    Ram #(.DATA_WIDTH(DATA_WIDTH), .MEM_SIZE(MEM_SIZE)) dut (
        .i_clk(clk),
        .i_we(we),
        .i_bus_writable(bus_writable),
        .i_jmp_imme(jmp_imme),
        .i_addr(addr),
        .io_data(io_data)
    );

    initial begin
        //initialize signals
        clk = 0;
        we = 0;
        bus_writable = 0;
        jmp_imme = 0;
        addr = 8'b00000000;
        io_data_driver = 8'h00; 
        io_data_drive_enable = 0; 

        //initialize RAM
        //Instructions
        dut.mem[0] = 8'b0010_1111;  //LOAD  (2F) ACC      = MEM[0xF] (LOAD 4)
        dut.mem[1] = 8'b0000_1110;  //ADD   (0E) ACC      = ACC + MEW[0xE] (4 + 1)
        dut.mem[2] = 8'b0011_1101;  //STORE (3D) MEM[0xD] = ACC
        dut.mem[3] = 8'b0001_1110;  //SUB   (1E) ACC      = ACC - MEM[0xE] (5 - 1)
        dut.mem[4] = 8'b0010_1101;  //LOAD  (2D) ACC      = MEM[0xD]
        dut.mem[5] = 8'b0011_1000;  //STORE (38) MEM[0x8] = ACC
        dut.mem[6] = 8'b0111_0000;  //JZ    (70) PC       = [0x0]
        dut.mem[7] = 8'b0000_0000;
        //DATA
        dut.mem[8] = 8'b00000000;
        dut.mem[9] = 8'b00000000;
        dut.mem[10] = 8'b00000000;
        dut.mem[11] = 8'b00000000;
        dut.mem[12] = 8'b00000000;
        dut.mem[13] = 8'b00000000;
        dut.mem[14] = 8'b00000001;
        dut.mem[15] = 8'b00000100;

        #5 //5ns
        `assert(dut.io_data, {DATA_WIDTH{1'bz}});

        #5 //Test load; 10ns
        addr = 8'b00001111;
        bus_writable = 1'b1;
        #5 //15ns
        `assert(dut.io_data, 8'b00000100);

        #5 //Test Store in mem[10]; 20ns
        bus_writable = 1'b0;
        io_data_drive_enable = 1'b1;
        io_data_driver = 8'b00110011;
        we = 1'b1;
        addr = 8'b00001010;
        #10 // 30ns
        `assert(dut.mem[10], 8'b00110011);

        #5 // Test jmp_imme with adress mem[10]; 35ns
        io_data_drive_enable = 1'b0;
        we = 1'b0;  
        bus_writable = 1'b1;
        jmp_imme = 1'b1;
        #10 // 45ns
        `assert(dut.io_data, 8'b00000011);

        #5//Test we=0 to make sure it doesn't change value; 50ns
        bus_writable = 1'b0;
        jmp_imme = 1'b0;
        io_data_drive_enable = 1'b1;
        io_data_driver = 8'b00001111;
        addr = 00000001;
        #5 // 55ns
        `assert(dut.mem[1], 8'b0000_1110);

        #5 //
        $display ("TestBench Passed!");
        $finish;
    end

    always #5 clk = ~clk;

    always @(posedge clk) begin 
       $display("Clock toggled at time %2t, clk = %0b, we = %0b, bus_writable = %0b, jmp_imme = %0b, addr = %8b, io_data = %8b", $time, clk, we, bus_writable, jmp_imme, addr, io_data); 
        end  

    initial begin 
     $dumpfile("ram.vcd"); 
     $dumpvars;  
    end 

endmodule