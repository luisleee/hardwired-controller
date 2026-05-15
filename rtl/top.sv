`include "macro.sv"

module top (
    input  logic CLR,

    input  logic CLK,
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

assign mode = {SWC, SWB, SWA};
assign opcode = IR[7:4];

assign write_reg_mode  = (mode == `MODE_WRITE_REG);
assign read_reg_mode   = (mode == `MODE_READ_REG);
assign read_mem_mode   = (mode == `MODE_READ_MEM);
assign write_mem_mode  = (mode == `MODE_WRITE_MEM);
assign fetch_exec_mode = (mode == `MODE_FETCH_EXEC);

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

    if (fetch_exec_mode) begin
        case (opcode)
            `OP_NOP: begin
                
            end

            `OP_ADD: begin
                
            end

            `OP_SUB: begin
                
            end

            `OP_AND: begin
                
            end

            `OP_OR: begin
                
            end

            `OP_NOT: begin
                
            end

            `OP_INC: begin
                
            end

            `OP_LD: begin
                
            end

            `OP_ST: begin
                
            end

            `OP_JC: begin
                
            end

            `OP_JZ: begin
                
            end

            `OP_JMP: begin
                
            end

            `OP_OUTA: begin
                
            end

            `OP_MOV: begin
                
            end

            `OP_STP: begin
                
            end

            default: ;
        endcase
    end else if (write_mem_mode) begin
        
    end else if (read_mem_mode) begin
        
    end else if (read_reg_mode) begin
        
    end else if (write_reg_mode) begin
        
    end
end

always_ff @(posedge CLK or negedge CLR) begin
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
    end else begin
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
    end
end

endmodule
