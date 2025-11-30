module Alu #(
    parameter DATA_WIDTH = 8
) (
    //inputs
    input i_clk,
    input i_rst,
    input i_opcode,
    input i_bus_writable,
    input [DATA_WIDTH-1:0] i_a,
    input [DATA_WIDTH-1:0] i_b,
    //outputs
    output reg o_jc,
    output reg o_jz,
    output wire [DATA_WIDTH-1:0] o_c
);

    reg carry;
    reg [DATA_WIDTH-1:0] tmp;

    always @ (posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            o_jc <= 1'b0;
            o_jz <= 1'b0;
        end
        else if (i_bus_writable) begin
            o_jc <= carry;
            if (tmp == 0 && !i_opcode)
            o_jz <= 1'b1;
            else
            o_jz <= 1'b0;
        end
    end

    always@(*) begin
        if (i_opcode) begin
            {carry,tmp} = i_a + i_b;
        end
        else begin
            {carry,tmp} = i_a - i_b;
        end
    end

    assign o_c = i_bus_writable ? tmp : {DATA_WIDTH{1'bz}};

endmodule