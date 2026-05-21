`ifndef TB_WCYCLES_SVH
`define TB_WCYCLES_SVH

localparam int W_STATE_HALT = 0;
localparam int W_STATE_1    = 1;
localparam int W_STATE_2    = 2;
localparam int W_STATE_3    = 3;

task automatic init_w_state(
    output int   w_state,
    output logic T1,
    output logic T2,
    output logic T3,
    output logic W1,
    output logic W2,
    output logic W3
);
begin
    w_state = W_STATE_1;
    T1 = 1'b0;
    T2 = 1'b0;
    T3 = 1'b0;
    W1 = 1'b1;
    W2 = 1'b0;
    W3 = 1'b0;
end
endtask

task automatic cpu_cycle(
    output logic T1,
    output logic T2,
    output logic T3,
    output logic W1,
    output logic W2,
    output logic W3,
    input  logic sel_w1,
    input  logic sel_w2,
    input  logic sel_w3
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

// 步进一个 CPU 周期，并按 SHORT/LONG/STOP 更新 w_state:
//   W1 结束: SHORT=1 → 留在W1; SHORT=0 → 进W2
//   W2 结束: LONG=1  → 进W3;  LONG=0  → 回W1
//   W3 结束: 无条件回W1
//   任意周期结束: STOP=1 → 进 W_STATE_HALT，后续调用为空操作
task automatic next_cycle(
    inout  int   w_state,
    output logic T1,
    output logic T2,
    output logic T3,
    output logic W1,
    output logic W2,
    output logic W3,
    input  logic SHORT,
    input  logic LONG,
    input  logic STOP
);
begin
    if (w_state == W_STATE_HALT) begin
        // 已停止，空操作
    end else begin
        case (w_state)
            W_STATE_1: begin
                cpu_cycle(T1, T2, T3, W1, W2, W3, 1'b1, 1'b0, 1'b0);
                if (STOP)
                    w_state = W_STATE_HALT;
                else if (SHORT)
                    w_state = W_STATE_1;
                else
                    w_state = W_STATE_2;
            end

            W_STATE_2: begin
                cpu_cycle(T1, T2, T3, W1, W2, W3, 1'b0, 1'b1, 1'b0);
                if (STOP)
                    w_state = W_STATE_HALT;
                else if (LONG)
                    w_state = W_STATE_3;
                else
                    w_state = W_STATE_1;
            end

            W_STATE_3: begin
                cpu_cycle(T1, T2, T3, W1, W2, W3, 1'b0, 1'b0, 1'b1);
                if (STOP)
                    w_state = W_STATE_HALT;
                else
                    w_state = W_STATE_1;
            end

            default: begin
                cpu_cycle(T1, T2, T3, W1, W2, W3, 1'b1, 1'b0, 1'b0);
                w_state = W_STATE_2;
            end
        endcase
    end
end
endtask

`endif
