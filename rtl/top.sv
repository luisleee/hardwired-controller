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
    output logic [3:0] SEL,
);

logic [2:0] mode;
logic       write_reg_mode;
logic       read_reg_mode;
logic       read_mem_mode;
logic       write_mem_mode;
logic       fetch_exec_mode;
logic [3:0] opcode;

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

logic [1:0] count;
logic preW1;
logic preW2;
logic preW3;

always_comb begin
    preW1 = 1'b0;
    preW2 = 1'b0;
    preW3 = 1'b0;

    if (write_reg_mode || read_reg_mode) begin
        if ((!W1 && !W2) || W2) begin
            preW1 = 1'b1;
        end
    end else if (read_mem_mode || write_mem_mode) begin
        if ((!W1 && !W2) || W1) begin
            preW1 = 1'b1;
        end
    end else if (fetch_exec_mode) begin
        if (count[1]) begin
            if (IR == `OP_LD || IR == `OP_ST) begin
                if ((!W1 && !W2 && !W3) || W3) begin
                    preW1 = 1'b1;
                end
            end else begin
                if ((!W1 && !W2 && !W3) || W2) begin
                    preW1 = 1'b1;
                end
            end
        end else if (!count[1]) begin
            preW1 = 1'b1;
        end
    end

    if (write_reg_mode || read_reg_mode || (fetch_exec_mode && (count[1]))) begin
        if (W1) begin
            preW2 = 1'b1;
        end
    end

    if (fetch_exec_mode && (count[1]) && (IR == `OP_LD || IR == `OP_ST)) begin
        if (W2) begin
            preW3 = 1'b1;
        end
    end
end

always_comb begin
    DRW_d    = 1'b0;
    PCINC_d  = 1'b0;
    LPC_d    = 1'b0;
    LAR_d    = 1'b0;
    PCADD_d  = 1'b0;
    ARINC_d  = 1'b0;
    SELCTL_d = 1'b0;
    MEMW_d   = 1'b0;
    STOP_d   = 1'b0;
    LIR_d    = 1'b0;
    LDZ_d    = 1'b0;
    LDC_d    = 1'b0;
    CIN_d    = 1'b0;
    S_d      = 4'b0000;
    M_d      = 1'b0;
    ABUS_d   = 1'b0;
    SBUS_d   = 1'b0;
    MBUS_d   = 1'b0;
    SHORT_d  = 1'b0;
    LONG_d   = 1'b0;
    SEL_d    = 4'b0000;
    ST0_d    = 1'b0;

    SST0   = 1'b0;

    if (fetch_exec_mode) begin
        if (preW1) begin
            LIR_d   = 1'b1;
            PCINC_d = 1'b1;
        end

        case (opcode)
            `OP_NOP: ;
            `OP_ADD: begin
                if (preW2) begin
                    S_d = 4'b1001;
                    CIN_d = 1'b1;
                    ABUS_d = 1'b1;
                    DRW_d  = 1'b1;
                    LDC_d  = 1'b1;
                    LDZ_d  = 1'b1;
                end
            end
            `OP_SUB: begin
                if (preW2) begin
                    S_d = 4'b0110;
                    ABUS_d = 1'b1;
                    DRW_d  = 1'b1;
                    LDC_d  = 1'b1;
                    LDZ_d  = 1'b1;
                end
            end
            `OP_AND: begin
                if (preW2) begin
                    M_d = 1'b1;
                    S_d = 4'b1011;
                    ABUS_d = 1'b1;
                    DRW_d  = 1'b1;
                end
            end
            `OP_INC: begin
                if (preW2) begin
                    S_d    = 4'b0000;
                    ABUS_d = 1'b1;
                    DRW_d  = 1'b1;
                    LDC_d  = 1'b1;
                    LDZ_d  = 1'b1;
                end
            end

            `OP_LD: begin
                if (preW2) begin
                    M_d = 1'b1;
                    S_d = 4'b1010;
                    ABUS_d = 1'b1;
                    LAR_d = 1'b1;
                    LONG_d = 1'b1;
                end

                if (preW3) begin
                    DRW_d = 1'b1;
                    MBUS_d = 1'b1;
                end
            end
            `OP_ST: begin
                if (preW2) begin
                    M_d = 1'b1;
                    S_d = 4'b1111;
                    ABUS_d = 1'b1;
                    LAR_d = 1'b1;
                    LONG_d = 1'b1;
                end

                if (preW3) begin
                    S_d = 4'b1010;
                    M_d = 1'b1;
                    ABUS_d = 1'b1;
                    MEMW_d = 1'b1;
                end
            end

            `OP_JC: begin
                if (preW2) begin
                    if (C) begin
                        PCADD_d = 1'b1;
                    end
                end
            end

            `OP_JZ: begin
                if (preW2) begin
                    if (Z) begin
                        PCADD_d = 1'b1;
                    end
                end
            end

            `OP_OUT: begin
                if (preW2) begin
                    S_d = 4'b1111;
                    ABUS_d = 1'b1;
                    M_d = 1'b1;
                end
            end

            `OP_JMP: begin
                if (preW2) begin
                    M_d = 1'b1;
                    S_d = 4'b1111;
                    ABUS_d = 1'b1;
                    LPC_d = 1'b1;
                end
            end

            `OP_STP: begin
                if (preW2) begin
                    STOP_d = 1'b1;
                end
            end

            default: ;
        endcase
    end else if (write_mem_mode) begin
        if (preW1) begin
            if (!ST0) begin
                SBUS_d = 1'b1;
                LAR_d = 1'b1;
                STOP_d = 1'b1;
                SST0 = 1'b1;
                SHORT_d = 1'b1;
                SELCTL_d = 1'b1;
            end else begin
                SBUS_d = 1'b1;
                MEMW_d = 1'b1;
                ARINC_d = 1'b1;
                STOP_d = 1'b1;
                SHORT_d = 1'b1;
                SELCTL_d = 1'b1;
            end
        end
    end else if (read_mem_mode) begin
        if (preW1) begin
            if (!ST0) begin
                SBUS_d = 1'b1;
                LAR_d = 1'b1;
                STOP_d = 1'b1;
                SST0 = 1'b1;
                SHORT_d = 1'b1;
                SELCTL_d = 1'b1;
            end else begin
                MBUS_d = 1'b1;
                ARINC_d = 1'b1;
                STOP_d = 1'b1;
                SHORT_d = 1'b1;
                SELCTL_d = 1'b1;
            end
        end
    end else if (read_reg_mode) begin
        if (preW1) begin
            SEL_d = 4'b0001;
            SELCTL_d = 1'b1;
            STOP_d = 1'b1;
        end

        if (preW2) begin
            SEL_d = 4'b1011;
            SELCTL_d = 1'b1;
            STOP_d = 1'b1;
        end
    end else if (write_reg_mode) begin
        if (!ST0) begin
            if (preW1) begin
                SBUS_d = 1'b1;
                SEL_d = 4'b0011;
                SELCTL_d = 1'b1;
                DRW_d = 1'b1;
                STOP_d = 1'b1;
            end

            if (preW2) begin
                SBUS_d = 1'b1;
                SEL_d = 4'b0100;
                SELCTL_d = 1'b1;
                DRW_d = 1'b1;
                STOP_d = 1'b1;

                SST0 = 1'b1;
            end
        end else begin
            if (preW1) begin
                SBUS_d = 1'b1;
                SEL_d = 4'b1001;
                SELCTL_d = 1'b1;
                DRW_d = 1'b1;
                STOP_d = 1'b1;
            end

            if (preW2) begin
                SBUS_d = 1'b1;
                SEL_d = 4'b1110;
                SELCTL_d = 1'b1;
                DRW_d = 1'b1;
                STOP_d = 1'b1;
            end
        end
    end

    if (SST0) begin
        ST0_d = 1'b1;
    end else if (write_reg_mode && preW2 && ST0) begin
        ST0_d = 1'b0;
    end else begin
        ST0_d = ST0;
    end
    
end

always_ff @(posedge T3 or negedge CLR) begin
    if (!CLR) begin
        DRW    <= 1'b0;
        PCINC  <= 1'b0;
        LPC    <= 1'b0;
        LAR    <= 1'b0;
        PCADD  <= 1'b0;
        ARINC  <= 1'b0;
        SELCTL <= 1'b0;
        MEMW   <= 1'b0;
        STOP   <= 1'b0;
        LIR    <= 1'b0;
        LDZ    <= 1'b0;
        LDC    <= 1'b0;
        CIN    <= 1'b0;
        S      <= 4'b0000;
        M      <= 1'b0;
        ABUS   <= 1'b0;
        SBUS   <= 1'b0;
        MBUS   <= 1'b0;
        SHORT  <= 1'b0;
        LONG   <= 1'b0;
        SEL    <= 4'b0000;

        ST0    <= 1'b0;

        count  <= 2'b00;
    end else begin
        if (!count[1]) begin
            count <= count + 2'b01;
        end

        DRW    <= DRW_d;
        PCINC  <= PCINC_d;
        LPC    <= LPC_d;
        LAR    <= LAR_d;
        PCADD  <= PCADD_d;
        ARINC  <= ARINC_d;
        SELCTL <= SELCTL_d;
        MEMW   <= MEMW_d;
        STOP   <= STOP_d;
        LIR    <= LIR_d;
        LDZ    <= LDZ_d;
        LDC    <= LDC_d;
        CIN    <= CIN_d;
        S      <= S_d;
        M      <= M_d;
        ABUS   <= ABUS_d;
        SBUS   <= SBUS_d;
        MBUS   <= MBUS_d;
        SHORT  <= SHORT_d;
        LONG   <= LONG_d;
        SEL    <= SEL_d;
        ST0    <= ST0_d;
    end
end

endmodule
