module Ram #(
    parameter DATA_WIDTH = 8,
    parameter MEM_SIZE = 16
) (
    //inputs
    input i_clk,
    input i_we,
    input i_bus_writable,
    input i_jmp_imme,
    input [DATA_WIDTH-1:0] i_addr,
    //inout
    inout [DATA_WIDTH-1:0] io_data
);

reg [DATA_WIDTH-1:0] mem [0:MEM_SIZE-1];
wire [DATA_WIDTH-1:0] out; 

always @ (posedge i_clk) begin
    if (i_we) mem[i_addr[3:0]] <= io_data;
end 

assign out = (i_jmp_imme) ? {4'h0, mem[i_addr[3:0]][3:0]} : mem[i_addr[3:0]];
assign io_data = (i_bus_writable) ? out : {DATA_WIDTH{1'bz}};

endmodule