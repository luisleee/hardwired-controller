`timescale 1ns/1ps
`include "alu_mock.svh"

module tb_alu;

logic [3:0] A;
logic [3:0] B;
logic       ABUS;
logic       M;
logic [3:0] S;
logic       CIN;
logic [3:0] F;
logic       C;
logic       Z;

alu dut (
    .A(A),
    .B(B),
    .ABUS(ABUS),
    .M(M),
    .S(S),
    .CIN(CIN),
    .F(F),
    .C(C),
    .Z(Z)
);

task automatic expect_alu(
    input logic [3:0] exp_f,
    input logic       exp_c,
    input logic       exp_z,
    input string      tag
);
begin
    #1;
    if (F !== exp_f || C !== exp_c || Z !== exp_z) begin
        $display(
            "FAIL: %s F=%b C=%b Z=%b expected F=%b C=%b Z=%b",
            tag, F, C, Z, exp_f, exp_c, exp_z
        );
        $finish;
    end
end
endtask

initial begin
    $dumpfile("tb_alu.vcd");
    $dumpvars(0, tb_alu);

    A = 4'h0;
    B = 4'h0;
    ABUS = 1'b1;
    M = 1'b1;
    S = 4'h0;
    CIN = 1'b1;

    A = 4'hA;
    B = 4'hC;
    M = 1'b1;
    S = 4'b1110;
    expect_alu(4'hE, 1'b0, 1'b0, "logic OR");

    S = 4'b0110;
    expect_alu(4'h6, 1'b0, 1'b0, "logic XOR");

    S = 4'b0011;
    expect_alu(4'h0, 1'b0, 1'b1, "logic zero");

    A = 4'h5;
    B = 4'h3;
    M = 1'b0;
    S = 4'b1001;
    CIN = 1'b1;
    expect_alu(4'h8, 1'b0, 1'b0, "add no carry-in");

    CIN = 1'b0;
    expect_alu(4'h9, 1'b0, 1'b0, "add with active-low carry-in");

    A = 4'hF;
    B = 4'h1;
    CIN = 1'b1;
    expect_alu(4'h0, 1'b1, 1'b1, "add carry-out");

    A = 4'h5;
    B = 4'h3;
    S = 4'b0110;
    CIN = 1'b0;
    expect_alu(4'h2, 1'b1, 1'b0, "subtract");

    A = 4'h3;
    B = 4'h5;
    CIN = 1'b0;
    expect_alu(4'hE, 1'b0, 1'b0, "subtract negative wraps");

    A = 4'h7;
    B = 4'h0;
    S = 4'b1111;
    CIN = 1'b1;
    expect_alu(4'h6, 1'b1, 1'b0, "decrement");

    CIN = 1'b0;
    expect_alu(4'h7, 1'b1, 1'b0, "pass A with carry applied");

    A = 4'h9;
    B = 4'h6;
    M = 1'b0;
    S = 4'b1100;
    CIN = 1'b1;
    expect_alu(4'h2, 1'b1, 1'b0, "double A");

    ABUS = 1'b0;
    #1;
    if (F !== 4'bzzzz) begin
        $display("FAIL: ABUS disable should tri-state F, got %b", F);
        $finish;
    end
    if (C !== 1'b1 || Z !== 1'b0) begin
        $display("FAIL: flags should remain driven when F is tri-stated");
        $finish;
    end

    $display("PASS: alu mock behaves as expected");
    $finish;
end

endmodule
