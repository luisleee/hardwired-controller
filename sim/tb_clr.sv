`timescale 1ns/1ps
`include "macro.sv"

module tb_clr;

logic       CLR;
logic       CLK;
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

always #5 CLK = ~CLK;

top dut (
    .CLR(CLR),
    .CLK(CLK),
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

    CLK = 1'b0;
    CLR = 1'b1;

    // drive a state that should produce non-zero registered outputs
    T3  = 1'b1;
    SWA = 1'b0;
    SWB = 1'b0;
    SWC = 1'b0;      // MODE_FETCH_EXEC
    IR  = `OP_ADD;
    W1  = 1'b0;
    W2  = 1'b0;
    W3  = 1'b0;
    C   = 1'b0;
    Z   = 1'b0;

    // Wait for first active clock edge to latch non-zero controls
    @(posedge CLK);
    #1;
    if (ctrl_bus === zero_bus) begin
        $display("FAIL: control bus is still zero after clock edge; setup did not create active controls");
        $finish;
    end else begin
        $display("INFO: control bus is non-zero after clock edge, proceeding to CLR pulse test");
    end

    // Assert asynchronous active-low clear between clock edges
    #2;
    CLR = 1'b0;
    #1;

    if (ctrl_bus !== zero_bus) begin
        $display("FAIL: control outputs did not clear immediately on negative CLR pulse");
        $display("      ctrl_bus = %b", ctrl_bus);
        $finish;
    end else begin
        $display("PASS: control outputs cleared immediately on negative CLR pulse");
    end

    // Release reset and confirm logic can become non-zero again on next clock
    #3;
    CLR = 1'b1;
    @(posedge CLK);
    #1;

    if (ctrl_bus === zero_bus) begin
        $display("FAIL: control outputs did not recover after CLR release and next clock edge");
    end else begin
        $display("PASS: control outputs recovered after CLR release");
    end

    $finish;
end

endmodule
