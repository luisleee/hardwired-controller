// Top-level wrapper for DE10-Lite (device: 10M50DAF484C7G)
// Pin assignments are in fpga/project.qsf — change them to match your board.
//
//  SW[9:7]   = ALU op (3 bits → 8 operations)
//  SW[6:0]   = operand A (7 bits; A[7] is tied to 0)
//  B         = hardcoded 8'h12 (18 decimal)
//  LEDR[7:0] = result
//  LEDR[8]   = zero flag
//  LEDR[9]   = carry-out / borrow flag
module top (
    /* verilator lint_off UNUSEDSIGNAL */
    input  logic        CLOCK_50,   // reserved for future CPU clock
    /* verilator lint_on  UNUSEDSIGNAL */
    input  logic [9:0]  SW,
    output logic [9:0]  LEDR
);

logic [7:0] result;
logic       zero, carry_out;

alu u_alu (
    .a        ({1'b0, SW[6:0]}),
    .b        (8'h12),
    .op       (SW[9:7]),
    .result   (result),
    .zero     (zero),
    .carry_out(carry_out)
);

assign LEDR[7:0] = result;
assign LEDR[8]   = zero;
assign LEDR[9]   = carry_out;


endmodule
