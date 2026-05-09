// Top-level wrapper for MAX EPM7128 CPLD.
//
// Pin locations live in fpga/project.qsf.
// Replace the placeholder PIN_* assignments there with the actual package pins
// from your board or schematic.
//
//  SW[9:7]  = ALU op (3 bits → 8 operations)
//  SW[6:0]  = operand A (7 bits; A[7] is tied to 0)
//  B        = hardcoded 8'h12
//  LED[7:0] = result
//  LED[8]   = zero flag
//  LED[9]   = carry-out / borrow flag
module top (
    input  logic [9:0] SW,
    output logic [9:0] LED
);

logic [7:0] result;
logic       zero;
logic       carry_out;

alu u_alu (
    .a        ({1'b0, SW[6:0]}),
    .b        (8'h12),
    .op       (SW[9:7]),
    .result   (result),
    .zero     (zero),
    .carry_out(carry_out)
);

assign LED[7:0] = result;
assign LED[8]   = zero;
assign LED[9]   = carry_out;

endmodule
