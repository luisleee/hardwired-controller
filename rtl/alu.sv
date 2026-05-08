// 8-bit ALU — SystemVerilog demo for MAX10 / CPU lab
// Supports 8 operations selected by the 3-bit op input.
module alu (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic [2:0] op,
    output logic [7:0] result,
    output logic       zero,
    output logic       carry_out
);

localparam OP_ADD = 3'd0;
localparam OP_SUB = 3'd1;
localparam OP_AND = 3'd2;
localparam OP_OR  = 3'd3;
localparam OP_XOR = 3'd4;
localparam OP_SHL = 3'd5;  // shift left, carry_out = a[7]
localparam OP_SHR = 3'd6;  // logical shift right, carry_out = a[0]
localparam OP_NOT = 3'd7;

always_comb begin
    // Default prevents latches in synthesis and satisfies Icarus.
    carry_out = 1'b0;
    result    = 8'b0;

    case (op)
        OP_ADD: {carry_out, result} = {1'b0, a} + {1'b0, b};
        OP_SUB: {carry_out, result} = {1'b0, a} - {1'b0, b};
        OP_AND: result = a & b;
        OP_OR:  result = a | b;
        OP_XOR: result = a ^ b;
        OP_SHL: {carry_out, result} = {a, 1'b0};
        OP_SHR: begin result = a >> 1; carry_out = a[0]; end
        OP_NOT: result = ~a;
        default: ; // unreachable; silences Verilator
    endcase

    zero = (result == 8'b0);
end

endmodule
