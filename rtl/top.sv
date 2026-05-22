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

// 只有状态机标志 ST0 需要跨越时钟周期记忆，其他全改为组合逻辑输出
logic ST0;
logic ST0_d;
logic SST0;

assign mode = {SWC, SWB, SWA};
assign opcode = IR[7:4];

// 这里假设你的 macro.sv 中已经按照流程图定义好了宏：
// `MODE_WRITE_REG = 3'b100, `MODE_READ_REG = 3'b011, `MODE_FETCH_EXEC = 3'b000
// `MODE_READ_MEM = 3'b010,  `MODE_WRITE_MEM = 3'b001
assign write_reg_mode  = (mode == `MODE_WRITE_REG);
assign read_reg_mode   = (mode == `MODE_READ_REG);
assign read_mem_mode   = (mode == `MODE_READ_MEM);
assign write_mem_mode  = (mode == `MODE_WRITE_MEM);
assign fetch_exec_mode = (mode == `MODE_FETCH_EXEC);

// ==========================================
// 组合逻辑部分：根据当前模式和节拍(W1/W2/W3)立即输出控制信号
// ==========================================
always_comb begin
    // 1. 默认所有控制信号为 0，防止生成锁存器 (Latch)
    DRW    = 1'b0;
    PCINC  = 1'b0;
    LPC    = 1'b0;
    LAR    = 1'b0;
    PCADD  = 1'b0;
    ARINC  = 1'b0;
    SELCTL = 1'b0;
    MEMW   = 1'b0;
    STOP   = 1'b0;
    LIR    = 1'b0;
    LDZ    = 1'b0;
    LDC    = 1'b0;
    CIN    = 1'b0;
    S      = 4'b0000;
    M      = 1'b0;
    ABUS   = 1'b0;
    SBUS   = 1'b0;
    MBUS   = 1'b0;
    SHORT  = 1'b0;
    LONG   = 1'b0;
    SEL    = 4'b0000;

    SST0   = 1'b0;
    ST0_d  = ST0; // 默认保持当前 ST0 状态

    // 2. 指令译码与执行控制
    if (fetch_exec_mode) begin
        // 取指周期：W1
        if (W1) begin
            LIR   = 1'b1;
            PCINC = 1'b1;
        end

        // 执行周期1：W2
        if (W2) begin
            case (opcode)
                `OP_ADD: begin S = 4'b1001; CIN = 1'b1; ABUS = 1'b1; DRW = 1'b1; LDC = 1'b1; LDZ = 1'b1; end
                `OP_SUB: begin S = 4'b0110; ABUS = 1'b1; DRW = 1'b1; LDC = 1'b1; LDZ = 1'b1; end
                `OP_AND: begin M = 1'b1; S = 4'b1011; ABUS = 1'b1; DRW = 1'b1; end
                `OP_INC: begin S = 4'b0000; ABUS = 1'b1; DRW = 1'b1; LDC = 1'b1; LDZ = 1'b1; end
                
                `OP_LD:  begin M = 1'b1; S = 4'b1010; ABUS = 1'b1; LAR = 1'b1; LONG = 1'b1; end
                `OP_ST:  begin M = 1'b1; S = 4'b1111; ABUS = 1'b1; LAR = 1'b1; LONG = 1'b1; end
                
                `OP_JC:  begin if (C) PCADD = 1'b1; end
                `OP_JZ:  begin if (Z) PCADD = 1'b1; end
                `OP_JMP: begin M = 1'b1; S = 4'b1111; ABUS = 1'b1; LPC = 1'b1; end
                `OP_STP: begin STOP = 1'b1; end
                
                `OP_OUT: begin S = 4'b1111; ABUS = 1'b1; M = 1'b1; end // 保留你的自定义指令
                default: ;
            endcase
        end

        // 执行周期2（访存）：W3
        if (W3) begin
            case (opcode)
                `OP_LD: begin DRW = 1'b1; MBUS = 1'b1; end
                `OP_ST: begin S = 4'b1010; M = 1'b1; ABUS = 1'b1; MEMW = 1'b1; end
                default: ;
            endcase
        end

    end else if (write_mem_mode) begin
        // 写存储器
        if (W1) begin
            if (!ST0) begin
                SBUS = 1'b1; LAR = 1'b1; STOP = 1'b1; SST0 = 1'b1; SHORT = 1'b1; SELCTL = 1'b1;
            end else begin
                SBUS = 1'b1; MEMW = 1'b1; ARINC = 1'b1; STOP = 1'b1; SHORT = 1'b1; SELCTL = 1'b1;
            end
        end

    end else if (read_mem_mode) begin
        // 读存储器
        if (W1) begin
            if (!ST0) begin
                SBUS = 1'b1; LAR = 1'b1; STOP = 1'b1; SST0 = 1'b1; SHORT = 1'b1; SELCTL = 1'b1;
            end else begin
                MBUS = 1'b1; ARINC = 1'b1; STOP = 1'b1; SHORT = 1'b1; SELCTL = 1'b1;
            end
        end

    end else if (read_reg_mode) begin
        // 读寄存器
        if (W1) begin SEL = 4'b0001; SELCTL = 1'b1; STOP = 1'b1; end
        if (W2) begin SEL = 4'b1011; SELCTL = 1'b1; STOP = 1'b1; end

    end else if (write_reg_mode) begin
        // 写寄存器
        if (!ST0) begin
            if (W1) begin SBUS = 1'b1; SEL = 4'b0011; SELCTL = 1'b1; DRW = 1'b1; STOP = 1'b1; end
            if (W2) begin SBUS = 1'b1; SEL = 4'b0100; SELCTL = 1'b1; DRW = 1'b1; STOP = 1'b1; SST0 = 1'b1; end
        end else begin
            if (W1) begin SBUS = 1'b1; SEL = 4'b1001; SELCTL = 1'b1; DRW = 1'b1; STOP = 1'b1; end
            if (W2) begin SBUS = 1'b1; SEL = 4'b1110; SELCTL = 1'b1; DRW = 1'b1; STOP = 1'b1; end
        end
    end

    // ==========================================
    // ST0 状态机切换逻辑
    // ==========================================
    if (SST0) begin
        ST0_d = 1'b1; 
    end else if (write_reg_mode && W2 && ST0) begin
        ST0_d = 1'b0; // 写寄存器模式下，完成第二波写入后复位 ST0
    end 
    // 注：读写存储器时，一旦置1就保持1，这样你按执行键就能依靠 ARINC 一直连续写入下一地址。
    // 如果要写新的地址，通过板子上的 CLR (Reset) 按钮让系统回 0。
end

// ==========================================
// 时序逻辑部分：只负责维护 ST0 状态和响应复位
// ==========================================
always_ff @(posedge T3 or negedge CLR) begin
    if (!CLR) begin
        ST0 <= 1'b0;
    end else begin
        ST0 <= ST0_d;
    end
end

endmodule