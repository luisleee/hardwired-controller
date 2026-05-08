// Testbench for alu.sv — compatible with Icarus Verilog (iverilog -g2012)
`timescale 1ns/1ps

module tb_alu;

// ---------- DUT signals ----------
logic [7:0] a, b;
logic [2:0] op;
logic [7:0] result;
logic       zero, carry_out;

// ---------- DUT ----------
alu dut (.*);

// ---------- Helpers ----------
int pass_cnt, fail_cnt;

task automatic check(
    input string   name,
    input [7:0]    exp_result,
    input logic    exp_zero,
    input logic    exp_carry
);
    #1; // let combinational settle
    if (result !== exp_result || zero !== exp_zero || carry_out !== exp_carry) begin
        $display("FAIL  %-8s  a=%02h b=%02h op=%0d | got result=%02h z=%b c=%b | exp result=%02h z=%b c=%b",
            name, a, b, op, result, zero, carry_out, exp_result, exp_zero, exp_carry);
        fail_cnt++;
    end else begin
        $display("PASS  %-8s  a=%02h b=%02h op=%0d → result=%02h z=%b c=%b",
            name, a, b, op, result, zero, carry_out);
        pass_cnt++;
    end
endtask

// ---------- Stimulus ----------
initial begin
    $dumpfile("tb_alu.vcd");
    $dumpvars(0, tb_alu);

    pass_cnt = 0;
    fail_cnt = 0;

    // ---- ADD ----
    a=8'h05; b=8'h03; op=3'd0; check("ADD",  8'h08, 0, 0);
    a=8'hFF; b=8'h01; op=3'd0; check("ADD_OF",8'h00, 1, 1); // overflow, zero, carry
    a=8'h00; b=8'h00; op=3'd0; check("ADD_0", 8'h00, 1, 0);

    // ---- SUB ----
    a=8'h08; b=8'h03; op=3'd1; check("SUB",   8'h05, 0, 0);
    a=8'h05; b=8'h05; op=3'd1; check("SUB_0", 8'h00, 1, 0);
    a=8'h00; b=8'h01; op=3'd1; check("SUB_UF",8'hFF, 0, 1); // underflow, carry=borrow

    // ---- AND ----
    a=8'hFF; b=8'h0F; op=3'd2; check("AND",   8'h0F, 0, 0);
    a=8'hAA; b=8'h55; op=3'd2; check("AND_0", 8'h00, 1, 0);

    // ---- OR ----
    a=8'hF0; b=8'h0F; op=3'd3; check("OR",    8'hFF, 0, 0);
    a=8'h00; b=8'h00; op=3'd3; check("OR_0",  8'h00, 1, 0);

    // ---- XOR ----
    a=8'hFF; b=8'hFF; op=3'd4; check("XOR_0", 8'h00, 1, 0);
    a=8'hA5; b=8'h5A; op=3'd4; check("XOR",   8'hFF, 0, 0);

    // ---- SHL ----
    a=8'h01; b=8'hxx; op=3'd5; check("SHL_1",  8'h02, 0, 0);
    a=8'h80; b=8'hxx; op=3'd5; check("SHL_C",  8'h00, 1, 1); // MSB shifts into carry

    // ---- SHR ----
    a=8'h80; b=8'hxx; op=3'd6; check("SHR_80", 8'h40, 0, 0);
    a=8'h01; b=8'hxx; op=3'd6; check("SHR_C",  8'h00, 1, 1); // LSB shifts into carry

    // ---- NOT ----
    a=8'h00; b=8'hxx; op=3'd7; check("NOT_FF", 8'hFF, 0, 0);
    a=8'hFF; b=8'hxx; op=3'd7; check("NOT_00", 8'h00, 1, 0);

    // ---------- Summary ----------
    $display("--------------------------------------------");
    $display("Result: %0d passed, %0d failed", pass_cnt, fail_cnt);
    if (fail_cnt == 0) $display("ALL TESTS PASSED");
    else               $display("SOME TESTS FAILED");

    $finish;
end

endmodule
