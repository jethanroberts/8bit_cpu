module Incrementer #(
    parameter DATA_WIDTH = 8
) (
    input [DATA_WIDTH-1:0] i_pc,
    input i_bus_writable,
    output [DATA_WIDTH-1:0] o_pc
);

    assign o_pc = (i_bus_writable) ? (i_pc + 1'b1) : {DATA_WIDTH{1'bz}};

endmodule