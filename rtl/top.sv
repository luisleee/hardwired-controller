`include "macro.sv"

module top (
    input  logic CLR,

    input  logic T3,
    input  logic SWA,
    input  logic SWB,
    input  logic SWC,
    input  logic [7:4] IR,
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

logic [2:0] mode;
logic       write_reg_mode;
logic       read_reg_mode;
logic       read_mem_mode;
logic       write_mem_mode;
logic       fetch_exec_mode;
logic [3:0] opcode;

// D触发器输入端信号 (Next State Logic)
logic       DRW_d;
logic       PCINC_d;
logic       LPC_d;
logic       LAR_d;
logic       PCADD_d;
logic       ARINC_d;
logic       SELCTL_d;
logic       MEMW_d;
logic       STOP_d;
logic       LIR_d;
logic       LDZ_d;
logic       LDC_d;
logic       CIN_d;
logic [3:0] S_d;
logic       M_d;
logic       ABUS_d;
logic       SBUS_d;
logic       MBUS_d;
logic       SHORT_d;
logic       LONG_d;
logic [3:0] SEL_d;

logic ST0;
logic SST0;
logic ST0_d;

assign mode = {SWC, SWB, SWA};
assign opcode = IR[7:4];

assign write_reg_mode  = (mode == `MODE_WRITE_REG);
assign read_reg_mode   = (mode == `MODE_READ_REG);
assign read_mem_mode   = (mode == `MODE_READ_MEM);
assign write_mem_mode  = (mode == `MODE_WRITE_MEM);
assign fetch_exec_mode = (mode == `MODE_FETCH_EXEC);

// ==========================================
// 核心修正区：节拍信号的边沿检测 (Edge Detection)
// 无论外部按键按多久，内部只产生 1 个时钟周期的干净脉冲
// ==========================================
logic W1_delay, W2_delay, W3_delay;
logic preW1, preW2, preW3;

always_ff @(posedge T3 or negedge CLR) begin
    if (!CLR) begin
        W1_delay <= 1'b0;
        W2_delay <= 1'b0;
        W3_delay <= 1'b0;
    end else begin
        W1_delay <= W1;
        W2_delay <= W2;
        W3_delay <= W3;
    end
end

// 只有在上升沿(0变1)的那个周期，preW 才是 1
assign preW1 = W1 & ~W1_delay; 
assign preW2 = W2 & ~W2_delay;
assign preW3 = W3 & ~W3_delay;

// ==========================================
// 控制信号组合逻辑：计算下一状态 (_d 信号)
// ==========================================
always_comb begin
    // 默认全0
    DRW_d    = 1'b0; PCINC_d  = 1'b0; LPC_d    = 1'b0;
    LAR_d    = 1'b0; PCADD_d  = 1'b0; ARINC_d  = 1'b0;
    SELCTL_d = 1'b0; MEMW_d   = 1'b0; STOP_d   = 1'b0;
    LIR_d    = 1'b0; LDZ_d    = 1'b0; LDC_d    = 1'b0;
    CIN_d    = 1'b0; S_d      = 4'b0000; M_d   = 1'b0;
    ABUS_d   = 1'b0; SBUS_d   = 1'b0; MBUS_d   = 1'b0;
    SHORT_d  = 1'b0; LONG_d   = 1'b0; SEL_d    = 4'b0000;
    
    SST0     = 1'b0;

    if (fetch_exec_mode) begin
        if (preW1) begin
            LIR_d   = 1'b1;
            PCINC_d = 1'b1;
        end

        if (preW2) begin
            case (opcode)
                `OP_ADD: begin S_d = 4'b1001; CIN_d = 1'b1; ABUS_d = 1'b1; DRW_d = 1'b1; LDC_d = 1'b1; LDZ_d = 1'b1; end
                `OP_SUB: begin S_d = 4'b0110; ABUS_d = 1'b1; DRW_d = 1'b1; LDC_d = 1'b1; LDZ_d = 1'b1; end
                `OP_AND: begin M_d = 1'b1; S_d = 4'b1011; ABUS_d = 1'b1; DRW_d = 1'b1; end
                `OP_INC: begin S_d = 4'b0000; ABUS_d = 1'b1; DRW_d = 1'b1; LDC_d = 1'b1; LDZ_d = 1'b1; end
                `OP_LD:  begin M_d = 1'b1; S_d = 4'b1010; ABUS_d = 1'b1; LAR_d = 1'b1; LONG_d = 1'b1; end
                `OP_ST:  begin M_d = 1'b1; S_d = 4'b1111; ABUS_d = 1'b1; LAR_d = 1'b1; LONG_d = 1'b1; end
                `OP_JC:  begin if (C) PCADD_d = 1'b1; end
                `OP_JZ:  begin if (Z) PCADD_d = 1'b1; end
                `OP_OUT: begin S_d = 4'b1111; ABUS_d = 1'b1; M_d = 1'b1; end
                `OP_JMP: begin M_d = 1'b1; S_d = 4'b1111; ABUS_d = 1'b1; LPC_d = 1'b1; end
                `OP_STP: begin STOP_d = 1'b1; end
                default: ;
            endcase
        end

        if (preW3) begin
            case (opcode)
                `OP_LD: begin DRW_d = 1'b1; MBUS_d = 1'b1; end
                `OP_ST: begin S_d = 4'b1010; M_d = 1'b1; ABUS_d = 1'b1; MEMW_d = 1'b1; end
                default: ;
            endcase
        end

    end else if (write_mem_mode) begin
        if (preW1) begin // 因为有了边沿检测，按一次只触发一次！
            if (!ST0) begin
                SBUS_d = 1'b1; LAR_d = 1'b1; STOP_d = 1'b1; SST0 = 1'b1; SHORT_d = 1'b1; SELCTL_d = 1'b1;
            end else begin
                SBUS_d = 1'b1; MEMW_d = 1'b1; ARINC_d = 1'b1; STOP_d = 1'b1; SHORT_d = 1'b1; SELCTL_d = 1'b1;
            end
        end
    end else if (read_mem_mode) begin
        if (preW1) begin
            if (!ST0) begin
                SBUS_d = 1'b1; LAR_d = 1'b1; STOP_d = 1'b1; SST0 = 1'b1; SHORT_d = 1'b1; SELCTL_d = 1'b1;
            end else begin
                MBUS_d = 1'b1; ARINC_d = 1'b1; STOP_d = 1'b1; SHORT_d = 1'b1; SELCTL_d = 1'b1;
            end
        end
    end else if (read_reg_mode) begin
        if (preW1) begin SEL_d = 4'b0001; SELCTL_d = 1'b1; STOP_d = 1'b1; end
        if (preW2) begin SEL_d = 4'b1011; SELCTL_d = 1'b1; STOP_d = 1'b1; end
    end else if (write_reg_mode) begin
        if (!ST0) begin
            if (preW1) begin SBUS_d = 1'b1; SEL_d = 4'b0011; SELCTL_d = 1'b1; DRW_d = 1'b1; STOP_d = 1'b1; end
            if (preW2) begin SBUS_d = 1'b1; SEL_d = 4'b0100; SELCTL_d = 1'b1; DRW_d = 1'b1; STOP_d = 1'b1; SST0 = 1'b1; end
        end else begin
            if (preW1) begin SBUS_d = 1'b1; SEL_d = 4'b1001; SELCTL_d = 1'b1; DRW_d = 1'b1; STOP_d = 1'b1; end
            if (preW2) begin SBUS_d = 1'b1; SEL_d = 4'b1110; SELCTL_d = 1'b1; DRW_d = 1'b1; STOP_d = 1'b1; end
        end
    end

    // ST0 状态机切换逻辑
    if (SST0) begin
        ST0_d = 1'b1;
    end else if (write_reg_mode && preW2 && ST0) begin
        ST0_d = 1'b0;
    end else begin
        ST0_d = ST0;
    end
end

// ==========================================
// 时序逻辑：完美锁存，彻底告别毛刺！
// ==========================================
always_ff @(posedge T3 or negedge CLR) begin
    if (!CLR) begin
        DRW <= 1'b0; PCINC <= 1'b0; LPC <= 1'b0; LAR <= 1'b0;
        PCADD <= 1'b0; ARINC <= 1'b0; SELCTL <= 1'b0; MEMW <= 1'b0;
        STOP <= 1'b0; LIR <= 1'b0; LDZ <= 1'b0; LDC <= 1'b0;
        CIN <= 1'b0; S <= 4'b0000; M <= 1'b0; ABUS <= 1'b0;
        SBUS <= 1'b0; MBUS <= 1'b0; SHORT <= 1'b0; LONG <= 1'b0;
        SEL <= 4'b0000;
        ST0 <= 1'b0;
    end else begin
        DRW <= DRW_d; PCINC <= PCINC_d; LPC <= LPC_d; LAR <= LAR_d;
        PCADD <= PCADD_d; ARINC <= ARINC_d; SELCTL <= SELCTL_d; MEMW <= MEMW_d;
        STOP <= STOP_d; LIR <= LIR_d; LDZ <= LDZ_d; LDC <= LDC_d;
        CIN <= CIN_d; S <= S_d; M <= M_d; ABUS <= ABUS_d;
        SBUS <= SBUS_d; MBUS <= MBUS_d; SHORT <= SHORT_d; LONG <= LONG_d;
        SEL <= SEL_d;
        ST0 <= ST0_d;
    end
end

endmodule