`timescale 1ns/1ps
`include "macro.sv"
`include "alu_mock.svh"

module sim_cpu_mock (
    input  logic       CLR,
    input  logic       T2,
    input  logic       T3,
    input  logic       SWA,
    input  logic       SWB,
    input  logic       SWC,
    input  logic       W1,
    input  logic       W2,
    input  logic       W3,
    input  logic [7:0] SD,

    output logic [7:0] DBUS_MON,
    output logic [7:0] INS,
    output logic [7:0] IR_FULL,
    output logic [7:0] PC,
    output logic [7:0] AR,
    output logic [7:0] R0,
    output logic [7:0] R1,
    output logic [7:0] R2,
    output logic [7:0] R3,
    output logic       FLAG_C,
    output logic       FLAG_Z,
    output logic [1:0] RD_SEL,
    output logic [1:0] RS_SEL,

    output logic       DRW,
    output logic       PCINC,
    output logic       LPC,
    output logic       LAR,
    output logic       PCADD,
    output logic       ARINC,
    output logic       SELCTL,
    output logic       MEMW,
    output logic       STOP,
    output logic       LIR,
    output logic       LDZ,
    output logic       LDC,
    output logic       CIN,
    output logic [3:0] S,
    output logic       M,
    output logic       ABUS,
    output logic       SBUS,
    output logic       MBUS,
    output logic       SHORT,
    output logic       LONG,
    output logic [3:0] SEL
);

tri [7:0] DBUS;

logic [7:0] regfile [0:3];
logic [7:0] alu_a;
logic [7:0] alu_b;
logic [7:0] alu_f;
logic       alu_c;
logic       alu_z;
logic [7:0] mem_dbus;
logic [3:0] sel_field;
logic       drw_eff;
logic       pcinc_eff;
logic       lpc_eff;
logic       lar_eff;
logic       pcadd_eff;
logic       arinc_eff;
logic       selctl_eff;
logic       memw_eff;
logic       stop_eff;
logic       lir_eff;
logic       ldz_eff;
logic       ldc_eff;
logic       cin_eff;
logic [3:0] s_eff;
logic       m_eff;
logic       abus_eff;
logic       sbus_eff;
logic       mbus_eff;
logic       short_eff;
logic       long_eff;
logic [3:0] sel_eff;

top ctrl (
    .CLR(CLR),
    .T3(T3),
    .SWA(SWA),
    .SWB(SWB),
    .SWC(SWC),
    .IR(IR_FULL[7:4]),
    .W1(W1),
    .W2(W2),
    .W3(W3),
    .C(FLAG_C),
    .Z(FLAG_Z),
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

// The controller registers its public outputs on negedge T3.
// For datapath simulation we use the combinational intent signals directly
// so writes still happen on the user-visible T3 posedge.
assign drw_eff    = ctrl.DRW_d;
assign pcinc_eff  = ctrl.PCINC_d;
assign lpc_eff    = ctrl.LPC_d;
assign lar_eff    = ctrl.LAR_d;
assign pcadd_eff  = ctrl.PCADD_d;
assign arinc_eff  = ctrl.ARINC_d;
assign selctl_eff = ctrl.SELCTL_d;
assign memw_eff   = ctrl.MEMW_d;
assign stop_eff   = ctrl.STOP_d;
assign lir_eff    = ctrl.LIR_d;
assign ldz_eff    = ctrl.LDZ_d;
assign ldc_eff    = ctrl.LDC_d;
assign cin_eff    = ctrl.CIN_d;
assign s_eff      = ctrl.S_d;
assign m_eff      = ctrl.M_d;
assign abus_eff   = ctrl.ABUS_d;
assign sbus_eff   = ctrl.SBUS_d;
assign mbus_eff   = ctrl.MBUS_d;
assign short_eff  = ctrl.SHORT_d;
assign long_eff   = ctrl.LONG_d;
assign sel_eff    = ctrl.SEL_d;

assign sel_field = selctl_eff ? sel_eff : IR_FULL[3:0];
assign RD_SEL = sel_field[3:2];
assign RS_SEL = sel_field[1:0];

always_comb begin
    alu_a = regfile[RD_SEL];
    alu_b = regfile[RS_SEL];
end

alu #(
    .WIDTH(8)
) alu_i (
    .A(alu_a),
    .B(alu_b),
    .ABUS(abus_eff),
    .M(m_eff),
    .S(s_eff),
    .CIN(cin_eff),
    .F(alu_f),
    .C(alu_c),
    .Z(alu_z)
);

sim_vn_mem #(
    .ADDR_W(8),
    .DATA_W(8)
) mem_i (
    .t2(T2),
    .pc(PC),
    .ir(INS),
    .ar(AR),
    .sbus_data(DBUS),
    .mbus(mbus_eff),
    .memw(memw_eff),
    .mbus_data(mem_dbus)
);

assign DBUS = alu_f;
assign DBUS = sbus_eff ? SD : 8'bz;
assign DBUS = mbus_eff ? mem_dbus : 8'bz;
assign DBUS_MON = DBUS;

assign R0 = regfile[0];
assign R1 = regfile[1];
assign R2 = regfile[2];
assign R3 = regfile[3];

always_ff @(posedge T3 or negedge CLR) begin
    if (!CLR) begin
        regfile[0] <= 8'h00;
        regfile[1] <= 8'h00;
        regfile[2] <= 8'h00;
        regfile[3] <= 8'h00;
        IR_FULL    <= 8'h00;
        PC         <= 8'h00;
        AR         <= 8'h00;
        FLAG_C     <= 1'b0;
        FLAG_Z     <= 1'b0;
    end else begin
        if (drw_eff) begin
            regfile[RD_SEL] <= DBUS;
        end

        if (lir_eff) begin
            IR_FULL <= INS;
        end

        if (ldc_eff) begin
            FLAG_C <= alu_c;
        end

        if (ldz_eff) begin
            FLAG_Z <= alu_z;
        end

        if (lpc_eff) begin
            PC <= DBUS;
        end else if (pcadd_eff) begin
            PC <= PC + $signed({{4{IR_FULL[3]}}, IR_FULL[3:0]});
        end else if (pcinc_eff) begin
            PC <= PC + 8'h01;
        end

        if (lar_eff) begin
            AR <= DBUS;
        end else if (arinc_eff) begin
            AR <= AR + 8'h01;
        end
    end
end

task automatic poke_mem(
    input logic [7:0] addr,
    input logic [7:0] data
);
begin
    mem_i.poke(addr, data);
end
endtask

function automatic logic [7:0] peek_mem(
    input logic [7:0] addr
);
begin
    peek_mem = mem_i.peek(addr);
end
endfunction

task automatic poke_reg(
    input logic [1:0] idx,
    input logic [7:0] data
);
begin
    regfile[idx] = data;
end
endtask

function automatic logic [7:0] peek_reg(
    input logic [1:0] idx
);
begin
    peek_reg = regfile[idx];
end
endfunction

task automatic seed_fetch(
    input logic [7:0] next_pc,
    input logic [7:0] ir_value
);
begin
    PC = next_pc;
    IR_FULL = ir_value;
end
endtask

endmodule
