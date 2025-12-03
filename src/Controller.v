module Controller #(
    parameter DATA_WIDTH = 8
) (
    //inputs
    input i_clk,
    input i_rst,
    input [DATA_WIDTH-1:0] i_inst,
    input i_jc,
    input i_jz,
    //output
    output reg [7:0] o_write_enable_bus,
    output reg o_opcode,
    output reg o_we_mem,
    output reg o_load_pc,
    output reg o_load_tmp,
    output reg o_load_mar,
    output reg o_load_inst,
    output reg o_load_acc,
    output reg o_jmp,
    output reg o_imme
);
    // DEFINE INSTRUCTION SET (top 4 pits of i_inst[7:4])
    localparam OP_ADD   = 4'b0000;
    localparam OP_SUB   = 4'b0001;
    localparam OP_LOAD  = 4'b0010;
    localparam OP_STORE = 4'b0011;
    localparam OP_IMME  = 4'b0100;
    localparam OP_JMP   = 4'b0101;
    localparam OP_JC    = 4'b0110;
    localparam OP_JZ    = 4'b0111;

    //STATES
    localparam PC_OUT       = 3'b000;
    localparam LOAD_IR      = 3'b001;
    localparam DECODE       = 3'b010;
    localparam EXECUTE      = 3'b011;
    localparam LOAD_TMP     = 3'b100;
    localparam LOAD_ACC     = 3'b101;
    localparam STORE_MEM    = 3'b110;
    localparam INCREMENT_PC = 3'b111;

    //write_enable_bus
    localparam PC           = 8'b0000_0001;
    localparam INCREMENTER  = 8'b0000_0010;
    localparam MEM          = 8'b0000_0100;
    localparam ALU          = 8'b0000_1000;
    localparam ACC          = 8'b0001_0000;
    localparam TMP          = 8'b0010_0000;
    localparam DECODER      = 8'b0100_0000;

    reg [2:0] state = PC_OUT;
    reg [2:0] next_state = PC_OUT;
    reg opcode;

    //on clock cycle or reset
    always @ (posedge i_clk or posedge i_rst) begin
        if (i_rst) begin 
            state <= PC_OUT;
            next_state <= PC_OUT;
            opcode <= 1'b0;
        end
        else begin
            state <= next_state;
            if (state == DECODE) begin
                if(i_inst[7:4] == OP_ADD) begin
                    opcode <= 1'b1;
                end
                else begin
                    opcode <= 1'b0; 
                end                   
            end
        end 
    end

    //FSM
    always @(*) begin
        next_state = state;                              
        o_load_pc   = 1'b0;
        o_load_mar  = 1'b0;
        o_opcode    = 1'b0;
        o_we_mem    = 1'b0;
        o_load_acc  = 1'b0;
        o_load_tmp  = 1'b0;
        o_jmp       = 1'b0;
        o_imme      = 1'b0;
        o_load_inst = 1'b0;
        case (state)
        PC_OUT: begin
            o_write_enable_bus = PC;
            o_load_mar = 1'b1;
            next_state = LOAD_IR;
        end
        LOAD_IR : begin
            o_write_enable_bus = MEM;
            o_load_inst = 1'b1;
            next_state = DECODE;
        end
        DECODE: begin
            o_write_enable_bus = MEM;
            case (i_inst[7:4])
            OP_ADD,OP_SUB: begin
                o_load_mar = 1'b1;
                next_state = LOAD_TMP;
            end
            OP_LOAD: begin
                o_load_mar = 1'b1;
                next_state = LOAD_ACC;
            end
            OP_STORE: begin
                o_load_mar = 1'b1;
                next_state = STORE_MEM;
            end
            OP_IMME: begin
                o_imme = 1'b1;
                o_load_acc = 1'b1;
                next_state = INCREMENT_PC;
            end
            OP_JMP: begin
                o_jmp = 1'b1;
                o_load_pc = 1'b1;
                next_state = PC_OUT;
            end
            OP_JC: begin
                if (i_jc) begin
                    o_jmp = 1'b1;
                    o_load_pc = 1'b1;
                    next_state = PC_OUT; 
                end
                else begin
                    next_state = INCREMENT_PC;
                    end
            end
            OP_JZ: begin
                if (i_jz) begin
                    o_jmp = 1'b1;
                    o_load_pc = 1'b1;
                    next_state = PC_OUT; 
                end
                else begin
                    next_state = INCREMENT_PC;
                    end
            end
            default : begin
                $display ("Should not end here!");
            end
            endcase
        end
        LOAD_TMP: begin
            o_write_enable_bus = MEM;
            o_load_tmp = 1'b1;
            next_state = EXECUTE;
        end
        EXECUTE: begin
            o_opcode = opcode;
            o_write_enable_bus = ALU;
            o_load_acc = 1'b1;
            next_state = INCREMENT_PC;
        end
        LOAD_ACC: begin
            o_write_enable_bus = MEM;
            o_load_acc = 1'b1;
            next_state = INCREMENT_PC;
        end
        STORE_MEM: begin
            o_write_enable_bus = ACC;
            o_we_mem = 1'b1;
            next_state = INCREMENT_PC; 
        end 
        INCREMENT_PC: begin
            o_write_enable_bus = INCREMENTER;
            o_load_pc = 1'b1;
            next_state = PC_OUT;
        end
        endcase
    end
endmodule