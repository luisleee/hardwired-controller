module top (
    input  logic CLR,
    input  logic T3,
    input  logic SWA,
    input  logic SWB,
    input  logic SWC,
    input  logic IR4,
    input  logic IR5,
    input  logic IR6,
    input  logic IR7,
    input  logic W1,
    input  logic W2,
    input  logic W3,
    input  logic C,
    input  logic Z,

    output logic DRW,
    output logic PCINC,
    output logic LPC,
    output logic LAR,
    output logic PCADD,
    output logic ARINC,
    output logic SELCTL,
    output logic MEMW,
    output logic STOP,
    output logic LIR,
    output logic LDZ,
    output logic LDC,
    output logic CIN,
    output logic [3:0] S,
    output logic M,
    output logic ABUS,
    output logic SBUS,
    output logic MBUS,
    output logic SHORT,
    output logic LONG,
    output logic [3:0] SEL
);

// 瞎写的
logic [7:0] a;
logic [7:0] b;
logic [2:0] op;
logic [7:0] result;
logic       carry_out;
logic       zero;

assign a  = {IR7, IR6, IR5, IR4, W3, W2, W1, T3};
assign b  = 8'h12;
assign op = {SWA, SWB, SWC};

alu u_alu (
    .a        (a),
    .b        (b),
    .op       (op),
    .result   (result),
    .zero     (zero),
    .carry_out(carry_out)
);

assign DRW    = result[0];
assign PCINC  = result[1];
assign LPC    = result[2];
assign LAR    = result[3];
assign PCADD  = result[4];
assign ARINC  = result[5];
assign SELCTL = result[6];
assign MEMW   = result[7];
assign STOP   = carry_out;
assign LIR    = CLR;
assign LDZ    = zero;
assign LDC    = carry_out;
assign CIN    = C;
assign S      = result[3:0];
assign M      = result[4];
assign ABUS   = result[5];
assign SBUS   = result[6];
assign MBUS   = result[7];
assign SHORT  = IR6;
assign LONG   = IR7;
assign SEL    = 4'b0101;

endmodule
