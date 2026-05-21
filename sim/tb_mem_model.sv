`timescale 1ns/1ps

module tb_mem_model;

logic       t2;
logic [3:0] pc;
logic [3:0] ar;
logic [7:0] sbus_data;
logic       mbus;
logic       memw;
logic [7:0] ir;
logic [7:0] mbus_data;

sim_vn_mem #(
    .ADDR_W(4),
    .DATA_W(8)
) dut (
    .t2(t2),
    .pc(pc),
    .ir(ir),
    .ar(ar),
    .sbus_data(sbus_data),
    .mbus(mbus),
    .memw(memw),
    .mbus_data(mbus_data)
);

always #5 t2 = ~t2;

initial begin
    $dumpfile("tb_mem_model.vcd");
    $dumpvars(0, tb_mem_model);

    t2 = 1'b0;
    pc = 4'h0;
    ar = 4'h0;
    sbus_data = 8'h00;
    mbus = 1'b0;
    memw = 1'b0;

    dut.poke(4'h0, 8'h61);
    dut.poke(4'h3, 8'hAA);

    #1;
    if (ir !== 8'h00) begin
        $display("FAIL: instruction port should be idle outside T2, ir=%02h", ir);
        $finish;
    end

    #5;
    if (ir !== 8'h61) begin
        $display("FAIL: instruction port read mismatch, ir=%02h", ir);
        $finish;
    end

    ar = 4'h3;
    mbus = 1'b1;
    #1;
    if (mbus_data !== 8'hAA) begin
        $display("FAIL: data port read mismatch, mbus_data=%02h", mbus_data);
        $finish;
    end

    #4;
    if (mbus_data !== 8'h00) begin
        $display("FAIL: data port should be idle outside T2, mbus_data=%02h", mbus_data);
        $finish;
    end

    ar = 4'h4;
    sbus_data = 8'h55;
    mbus = 1'b0;
    memw = 1'b1;
    #10;
    memw = 1'b0;

    mbus = 1'b1;
    #5;
    if (mbus_data !== 8'h55) begin
        $display("FAIL: data port write/read mismatch, mbus_data=%02h", mbus_data);
        $finish;
    end

    pc = 4'h4;
    #1;
    if (ir !== 8'h55) begin
        $display("FAIL: instruction port did not observe updated memory, ir=%02h", ir);
        $finish;
    end

    $display("PASS: dual-port von Neumann memory model behaves as expected");
    $finish;
end

endmodule
