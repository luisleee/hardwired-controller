`timescale 1ns/1ps

module sim_vn_mem #(
    parameter int ADDR_W = 4,
    parameter int DATA_W = 8,
    parameter string INIT_FILE = ""
) (
    input  logic              t2,
    input  logic [ADDR_W-1:0] pc,
    output logic [DATA_W-1:0] ir,
    input  logic [ADDR_W-1:0] ar,
    input  logic [DATA_W-1:0] sbus_data,
    input  logic              mbus,
    input  logic              memw,
    output logic [DATA_W-1:0] mbus_data
);

localparam int DEPTH = 1 << ADDR_W;

logic [DATA_W-1:0] mem [0:DEPTH-1];

initial begin
    if (INIT_FILE != "") begin
        $readmemh(INIT_FILE, mem);
    end
end

assign ir = t2 ? mem[pc] : '0;
assign mbus_data = (t2 && mbus && !memw) ? mem[ar] : '0;

// 读写都约束在 T2 周期内；写在 T2 下降沿提交，便于先稳定 AR/SBUS/MEMW。
always_ff @(negedge t2) begin
    if (memw) begin
        mem[ar] <= sbus_data;
    end
end

task automatic poke(
    input logic [ADDR_W-1:0] addr,
    input logic [DATA_W-1:0] data
);
begin
    mem[addr] = data;
end
endtask

function automatic logic [DATA_W-1:0] peek(
    input logic [ADDR_W-1:0] addr
);
begin
    peek = mem[addr];
end
endfunction

endmodule
