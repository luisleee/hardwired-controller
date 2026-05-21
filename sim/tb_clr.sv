`timescale 1ns/1ps
`include "macro.sv"
`include "tb_wcycles.svh"

module tb_clr;

logic       CLR;
logic       T1;
logic       T2;
logic       T3;
logic       SWA;
logic       SWB;
logic       SWC;
logic [7:4] IR;
logic       W1;
logic       W2;
logic       W3;
logic       C;
logic       Z;
int         w_state;

logic       DRW;
logic       PCINC;
logic       LPC;
logic       LAR;
logic       PCADD;
logic       ARINC;
logic       SELCTL;
logic       MEMW;
logic       STOP;
logic       LIR;
logic       LDZ;
logic       LDC;
logic       CIN;
logic [3:0] S;
logic       M;
logic       ABUS;
logic       SBUS;
logic       MBUS;
logic       SHORT;
logic       LONG;
logic [3:0] SEL;

logic [22:0] ctrl_bus;
logic [22:0] zero_bus;

assign ctrl_bus = {
    DRW, PCINC, LPC, LAR, PCADD, ARINC, SELCTL, MEMW, STOP,
    LIR, LDZ, LDC, CIN,
    S,
    M, ABUS, SBUS, MBUS, SHORT, LONG,
    SEL
};

assign zero_bus = '0;

top dut (
    .CLR(CLR),
    .T3(T3),
    .SWA(SWA),
    .SWB(SWB),
    .SWC(SWC),
    .IR(IR),
    .W1(W1),
    .W2(W2),
    .W3(W3),
    .C(C),
    .Z(Z),
    .DRW(DRW),
    .PCINC(PCINC),
    .LPC(LPC),
    .LAR(LAR),
    .PCADD(PCADD),
    .ARINC(ARINC),
    .SELCTL(SELCTL),
    .MEMW(MEMW),
    .STOP(STOP),
    .LIR(LIR),
    .LDZ(LDZ),
    .LDC(LDC),
    .CIN(CIN),
    .S(S),
    .M(M),
    .ABUS(ABUS),
    .SBUS(SBUS),
    .MBUS(MBUS),
    .SHORT(SHORT),
    .LONG(LONG),
    .SEL(SEL)
);

initial begin
    $dumpfile("tb_clr.vcd");
    $dumpvars(0, tb_clr);

    init_w_state(w_state, T1, T2, T3, W1, W2, W3);
    CLR = 1'b1;

    SWA = 1'b0;
    SWB = 1'b0;
    SWC = 1'b0;      // MODE_FETCH_EXEC
    IR  = `OP_INC;
    C   = 1'b0;
    Z   = 1'b0;

    next_cycle(w_state, T1, T2, T3, W1, W2, W3, SHORT, LONG, STOP); // W1
    next_cycle(w_state, T1, T2, T3, W1, W2, W3, SHORT, LONG, STOP); // W2
    if (ctrl_bus === zero_bus) begin
        $display("FAIL: instruction cycles did not create active INC controls");
        $finish;
    end else begin
        $display("INFO: INC execution controls are active after W2, proceeding to CLR pulse test");
    end

    // Assert asynchronous active-low clear between T3 edges
    #5;
    CLR = 1'b0;
    #1;

    if (ctrl_bus !== zero_bus) begin
        $display("FAIL: control outputs did not clear immediately on negative CLR pulse");
        $display("      ctrl_bus = %b", ctrl_bus);
        $finish;
    end else begin
        $display("PASS: control outputs cleared immediately on negative CLR pulse");
    end

    $finish;
end

endmodule
