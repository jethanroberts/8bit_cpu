`default_nettype none 
 `timescale 1ns/1ns 

 `define assert(signal, value) \ 
     if (signal !== value) begin \ 
         $display("ASSERTION FAILED at %2d in %m: signal != value", $time); \ 
         $finish; \ 
     end 

 module register_tb; 
   localparam integer DATA_WIDTH = 8; 

   reg clk; 
   reg rst;  
   reg we; 
   reg bus_writable;  

   wire [7:0] o_data; 

   reg [DATA_WIDTH-1:0] io_data_driver; // Register to drive the inout signal 
   wire [DATA_WIDTH-1:0] io_data;       // Wire to read the inout signal 
   reg io_data_drive_enable;            // Control signal to enable driving the inout signal 

   // Conditionally drive the inout signal 
   assign io_data = io_data_drive_enable ? io_data_driver : {DATA_WIDTH{1'bz}}; 

   Register #(.DATA_WIDTH(DATA_WIDTH)) dut ( 
     .i_clk(clk), 
     .i_rst(rst), 
     .i_we(we), 
     .i_bus_writable(bus_writable), 
     .o_data(o_data), 
     .io_data(io_data) 
   ); 

   initial begin 
     // Initialize signals 
     clk = 0; 
     rst = 1; 
     we = 0; 
     bus_writable = 0; 
     io_data_driver = 8'h00; 
     io_data_drive_enable = 0; 

     #5 // Release reset and perform operations 
     	rst = 0; 
     	`assert(dut.i_rst, 1'b0); 
     	`assert(io_data, 8'bzzzzzzz); 
     	`assert(dut.io_data, 8'bzzzzzzz); 
     #10 // Example operation: driving the inout port 
     	io_data_driver = 8'hA5; 
         io_data_drive_enable = 1'b1; 
        	we = 1'b1; 
     	`assert(dut.o_data, 8'b00000000); 
     #10 io_data_drive_enable = 0; 
     	io_data_driver = 8'h00; 
     	bus_writable = 1'b1; 
 		we = 1'b0; 
     	`assert(dut.o_data, 8'b10100101); 
     	`assert(dut.io_data, 8'b10100101); 
     	`assert(dut.i_bus_writable, 1'b1); 
     	`assert(io_data, 8'b10100101); 
     #10 // Disconnect bus 
     	io_data_drive_enable = 0; 
     	io_data_driver = 8'h00; 
     	bus_writable = 1'b0; 
     	we = 1'b0; 
     	`assert(dut.o_data, 8'b10100101); 
     	`assert(dut.io_data, 8'b10100101); 
     #10 
     	io_data_drive_enable = 1; 
     	io_data_driver = 8'h00; 
     	bus_writable = 1'b0; 
     	we = 1'b1; 
     	`assert(dut.o_data, 8'b10100101); 
     #10 
     	io_data_drive_enable = 0; 
     	io_data_driver = 8'hA5; 
     	bus_writable = 1'b1; 
     	we = 1'b0; 
     	`assert(dut.o_data, 8'b00000000); 
     	`assert(dut.io_data, 8'b00000000); 
     	`assert(io_data, 8'b00000000); 
 	#5; 
     	$display("Testbench Passed!"); 
     	$finish; 
   end 

   // Clock generation 
   always #5 clk = ~clk; 

   always @(posedge clk) begin 
       $display("Clock toggled at time %2t, clk = %0b, rst = %0b, we = %0b, bus_writable = %0b, o_data = %8b, io_data = %8b",		$time, clk, rst, we, bus_writable, o_data, io_data); 
   end 

   initial begin 
     $dumpfile("register.vcd"); 
     $dumpvars;  
   end 
 endmodule