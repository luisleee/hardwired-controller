`timescale 1ns/1ps
`include "macro.sv"

module tb_system;

logic       CLR;
logic       T1;
logic       T2;
logic       T3;
logic       SWA;
logic       SWB;
logic       SWC;
logic       W1;
logic       W2;
logic       W3;
logic [7:0] SD;
int         in_idx;

logic [7:0] DBUS_MON;
logic [7:0] INS;
logic [7:0] IR_FULL;
logic [7:0] PC;
logic [7:0] AR;
logic [7:0] R0;
logic [7:0] R1;
logic [7:0] R2;
logic [7:0] R3;
logic       FLAG_C;
logic       FLAG_Z;
logic [1:0] RD_SEL;
logic [1:0] RS_SEL;

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

logic [7:0] prog_inputs [0:7];

sim_cpu_mock sys (
    .CLR(CLR),
    .T2(T2),
    .T3(T3),
    .SWA(SWA),
    .SWB(SWB),
    .SWC(SWC),
    .W1(W1),
    .W2(W2),
    .W3(W3),
    .SD(SD),
    .DBUS_MON(DBUS_MON),
    .INS(INS),
    .IR_FULL(IR_FULL),
    .PC(PC),
    .AR(AR),
    .R0(R0),
    .R1(R1),
    .R2(R2),
    .R3(R3),
    .FLAG_C(FLAG_C),
    .FLAG_Z(FLAG_Z),
    .RD_SEL(RD_SEL),
    .RS_SEL(RS_SEL),
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

function automatic logic [7:0] instr(
    input logic [3:0] opcode,
    input logic [1:0] rd,
    input logic [1:0] rs
);
begin
    instr = {opcode, rd, rs};
end
endfunction

task automatic assert_eq8(
    input logic [7:0] got,
    input logic [7:0] exp,
    input string      tag
);
begin
    if (got !== exp) begin
        $display("FAIL: %s got=%02h expected=%02h", tag, got, exp);
        $finish;
    end
end
endtask

task automatic assert_eq1(
    input logic got,
    input logic exp,
    input string tag
);
begin
    if (got !== exp) begin
        $display("FAIL: %s got=%0b expected=%0b", tag, got, exp);
        $finish;
    end
end
endtask

task automatic reset_system;
begin
    CLR = 1'b1;
    T1 = 1'b0;
    T2 = 1'b0;
    T3 = 1'b0;
    W1 = 1'b0;
    W2 = 1'b0;
    W3 = 1'b0;
    SD = 8'h00;
    SWA = 1'b0;
    SWB = 1'b0;
    SWC = 1'b0;
    #1;
    CLR = 1'b0;
    #1;
    CLR = 1'b1;
    #1;
    in_idx = 0;
end
endtask

task automatic prime_first_instruction;
begin
    sys.seed_fetch(8'h01, sys.peek_mem(8'h00));
end
endtask

task automatic prepare_sd_for_instruction;
begin
    if (IR_FULL[7:4] == `OP_IN) begin
        SD = prog_inputs[in_idx];
        in_idx = in_idx + 1;
    end else begin
        SD = 8'h00;
    end
end
endtask

task automatic drive_cycle(
    input logic sel_w1,
    input logic sel_w2,
    input logic sel_w3
);
begin
    W1 = sel_w1;
    W2 = sel_w2;
    W3 = sel_w3;

    T1 = 1'b1; T2 = 1'b0; T3 = 1'b0; #10;
    T1 = 1'b0; T2 = 1'b1; T3 = 1'b0; #10;
    T1 = 1'b0; T2 = 1'b0; T3 = 1'b1; #10;
    T1 = 1'b0; T2 = 1'b0; T3 = 1'b0; #1;
end
endtask

task automatic execute_current_instruction;
begin
    prepare_sd_for_instruction();
    drive_cycle(1'b1, 1'b0, 1'b0);

    if (IR_FULL[7:4] == `OP_STP) begin
        SD = 8'h00;
    end else if (IR_FULL[7:4] == `OP_LD || IR_FULL[7:4] == `OP_ST) begin
        SD = 8'h00;
        drive_cycle(1'b0, 1'b1, 1'b0);
        drive_cycle(1'b0, 1'b0, 1'b1);
    end else begin
        SD = 8'h00;
        drive_cycle(1'b0, 1'b1, 1'b0);
    end
end
endtask

task automatic run_program_until_halt(
    input int max_instrs
);
    int step;
begin
    for (step = 0; step < max_instrs; step = step + 1) begin
        execute_current_instruction();
        if (IR_FULL[7:4] == `OP_STP) begin
            return;
        end
    end

    if (IR_FULL[7:4] != `OP_STP) begin
        $display("FAIL: program did not halt within %0d instructions", max_instrs);
        $finish;
    end
end
endtask

task automatic manual_cycle_w1;
begin
    drive_cycle(1'b1, 1'b0, 1'b0);
end
endtask

task automatic manual_cycle_w2;
begin
    drive_cycle(1'b0, 1'b1, 1'b0);
end
endtask

task automatic manual_read_mem_cycle(
    input logic [7:0] expected_dbus,
    input logic [7:0] expected_ar_after
);
begin
    W1 = 1'b1;
    W2 = 1'b0;
    W3 = 1'b0;

    T1 = 1'b1; T2 = 1'b0; T3 = 1'b0; #10;
    T1 = 1'b0; T2 = 1'b1; T3 = 1'b0; #1;
    assert_eq8(DBUS_MON, expected_dbus, "manual read DBUS during T2");
    #9;
    T1 = 1'b0; T2 = 1'b0; T3 = 1'b1; #10;
    T1 = 1'b0; T2 = 1'b0; T3 = 1'b0; #1;
    assert_eq8(AR, expected_ar_after, "manual read AR post increment");
end
endtask

task automatic load_program_case_one;
begin
    sys.poke_mem(8'h00, instr(`OP_IN,  2'b10, 2'b00));
    sys.poke_mem(8'h01, instr(`OP_IN,  2'b00, 2'b00));
    sys.poke_mem(8'h02, instr(`OP_ST,  2'b10, 2'b00));
    sys.poke_mem(8'h03, instr(`OP_LD,  2'b01, 2'b10));
    sys.poke_mem(8'h04, instr(`OP_CMP, 2'b01, 2'b00));
    sys.poke_mem(8'h05, {`OP_JZ, 4'h1});
    sys.poke_mem(8'h06, instr(`OP_IN,  2'b11, 2'b00));
    sys.poke_mem(8'h07, instr(`OP_NOT, 2'b01, 2'b00));
    sys.poke_mem(8'h08, instr(`OP_MOV, 2'b11, 2'b01));
    sys.poke_mem(8'h09, {`OP_STP, 4'h0});

    prog_inputs[0] = 8'h20;
    prog_inputs[1] = 8'hA5;
    prog_inputs[2] = 8'hFF;
end
endtask

task automatic load_program_case_two;
begin
    sys.poke_mem(8'h00, instr(`OP_IN,  2'b00, 2'b00));
    sys.poke_mem(8'h01, instr(`OP_INC, 2'b00, 2'b00));
    sys.poke_mem(8'h02, instr(`OP_IN,  2'b01, 2'b00));
    sys.poke_mem(8'h03, instr(`OP_ADD, 2'b00, 2'b01));
    sys.poke_mem(8'h04, {`OP_JC, 4'h2});
    sys.poke_mem(8'h05, instr(`OP_IN,  2'b10, 2'b00));
    sys.poke_mem(8'h06, {`OP_STP, 4'h0});
    sys.poke_mem(8'h07, instr(`OP_IN,  2'b11, 2'b00));
    sys.poke_mem(8'h08, instr(`OP_JMP, 2'b11, 2'b00));
    sys.poke_mem(8'h09, {`OP_STP, 4'h0});
    sys.poke_mem(8'h0A, instr(`OP_SUB, 2'b01, 2'b00));
    sys.poke_mem(8'h0B, instr(`OP_AND, 2'b00, 2'b01));
    sys.poke_mem(8'h0C, {`OP_STP, 4'h0});

    prog_inputs[0] = 8'hFE;
    prog_inputs[1] = 8'h02;
    prog_inputs[2] = 8'h0A;
end
endtask

initial begin
    $dumpfile("tb_system.vcd");
    $dumpvars(0, tb_system);

    // Program flow case 1: IN/ST/LD/CMP/JZ/NOT/MOV.
    reset_system();
    load_program_case_one();
    assert_eq8(sys.peek_mem(8'h00), instr(`OP_IN,  2'b10, 2'b00), "case1 mem[0] preload");
    prime_first_instruction();
    run_program_until_halt(32);

    assert_eq8(R2, 8'h20, "case1 R2 address source");
    assert_eq8(R0, 8'hA5, "case1 R0 input data");
    assert_eq8(R1, 8'h5A, "case1 R1 not result");
    assert_eq8(R3, 8'h5A, "case1 R3 mov result");
    assert_eq8(sys.peek_mem(8'h20), 8'hA5, "case1 stored memory value");
    assert_eq1(FLAG_C, 1'b1, "case1 CMP carry flag");
    assert_eq1(FLAG_Z, 1'b1, "case1 CMP zero flag");

    // Program flow case 2: INC/ADD/JC/JMP/SUB/AND.
    reset_system();
    load_program_case_two();
    prime_first_instruction();
    run_program_until_halt(40);

    assert_eq8(R0, 8'h01, "case2 AND result");
    assert_eq8(R1, 8'h01, "case2 SUB result");
    assert_eq8(R2, 8'h00, "case2 skipped IN");
    assert_eq8(R3, 8'h0A, "case2 jump target register");
    assert_eq1(FLAG_C, 1'b1, "case2 carry after SUB");
    assert_eq1(FLAG_Z, 1'b0, "case2 zero after SUB");

    // Manual write-register mode writes R0/R1/R2/R3 in four steps.
    reset_system();
    SWA = 1'b0;
    SWB = 1'b0;
    SWC = 1'b1;

    SD = 8'h11; manual_cycle_w2();
    SD = 8'h22; manual_cycle_w1();
    SD = 8'h33; manual_cycle_w2();
    SD = 8'h44; manual_cycle_w1();

    assert_eq8(R0, 8'h11, "manual write_reg R0");
    assert_eq8(R1, 8'h22, "manual write_reg R1");
    assert_eq8(R2, 8'h33, "manual write_reg R2");
    assert_eq8(R3, 8'h44, "manual write_reg R3");

    // Manual write/read memory mode.
    reset_system();
    SWA = 1'b1;
    SWB = 1'b0;
    SWC = 1'b0;

    SD = 8'h30; manual_cycle_w1();
    assert_eq8(AR, 8'h30, "manual write_mem address load");

    SD = 8'hBE; manual_cycle_w1();
    assert_eq8(sys.peek_mem(8'h30), 8'hBE, "manual write_mem first store");
    assert_eq8(AR, 8'h31, "manual write_mem AR increment");

    SD = 8'hEF; manual_cycle_w1();
    assert_eq8(sys.peek_mem(8'h31), 8'hEF, "manual write_mem second store");
    assert_eq8(AR, 8'h32, "manual write_mem second increment");

    reset_system();
    sys.poke_mem(8'h30, 8'hBE);
    sys.poke_mem(8'h31, 8'hEF);
    SWA = 1'b0;
    SWB = 1'b1;
    SWC = 1'b0;
    SD = 8'h30; manual_cycle_w1();
    assert_eq8(AR, 8'h30, "manual read_mem address load");
    manual_read_mem_cycle(8'hBE, 8'h31);
    manual_read_mem_cycle(8'hEF, 8'h32);

    $display("PASS: full datapath mock and controller integration behave as expected");
    $finish;
end

endmodule
