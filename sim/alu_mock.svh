`ifndef ALU_MOCK_SVH
`define ALU_MOCK_SVH

`timescale 1ns/1ps

module alu #(
    parameter int WIDTH = 4
) (
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    input  logic             ABUS,
    input  logic             M,
    input  logic [3:0]       S,
    input  logic             CIN,
    output logic [WIDTH-1:0] F,
    output logic             C,
    output logic             Z
);

logic [WIDTH-1:0] f_int;
logic             c_int;
logic [WIDTH:0]   ext;
logic [WIDTH:0]   lhs_ext;
logic [WIDTH:0]   rhs_ext;
logic [WIDTH-1:0] term;

always_comb begin
    f_int = '0;
    c_int = 1'b0;
    ext = '0;
    lhs_ext = '0;
    rhs_ext = '0;
    term = '0;

    if (M) begin
        case (S)
            4'b0000: f_int = ~A;
            4'b0001: f_int = ~(A | B);
            4'b0010: f_int = (~A) & B;
            4'b0011: f_int = '0;
            4'b0100: f_int = ~(A & B);
            4'b0101: f_int = ~B;
            4'b0110: f_int = A ^ B;
            4'b0111: f_int = A & (~B);
            4'b1000: f_int = (~A) | B;
            4'b1001: f_int = ~(A ^ B);
            4'b1010: f_int = B;
            4'b1011: f_int = A & B;
            4'b1100: f_int = '1;
            4'b1101: f_int = A | (~B);
            4'b1110: f_int = A | B;
            4'b1111: f_int = A;
            default: f_int = '0;
        endcase
        c_int = 1'b0;
    end else begin
        case (S)
            4'b0000: begin
                ext = {1'b0, A} + {{WIDTH{1'b0}}, ~CIN};
                c_int = ext[WIDTH];
            end
            4'b0001: begin
                ext = {1'b0, (A | B)} + {{WIDTH{1'b0}}, ~CIN};
                c_int = ext[WIDTH];
            end
            4'b0010: begin
                ext = {1'b0, (A | (~B))} + {{WIDTH{1'b0}}, ~CIN};
                c_int = ext[WIDTH];
            end
            4'b0011: begin
                ext = {{WIDTH{1'b0}}, 1'b0} - {{WIDTH{1'b0}}, CIN};
                c_int = ~CIN;
            end
            4'b0100: begin
                ext = {1'b0, A} + {1'b0, (A & (~B))} + {{WIDTH{1'b0}}, ~CIN};
                c_int = ext[WIDTH];
            end
            4'b0101: begin
                ext = {1'b0, (A | B)} + {1'b0, (A & (~B))} + {{WIDTH{1'b0}}, ~CIN};
                c_int = ext[WIDTH];
            end
            4'b0110: begin
                lhs_ext = {1'b0, A};
                rhs_ext = {1'b0, B} + {{WIDTH{1'b0}}, CIN};
                ext = lhs_ext - rhs_ext;
                c_int = (lhs_ext >= rhs_ext);
            end
            4'b0111: begin
                term = A & (~B);
                lhs_ext = {1'b0, term};
                rhs_ext = {{WIDTH{1'b0}}, CIN};
                ext = lhs_ext - rhs_ext;
                c_int = (lhs_ext >= rhs_ext);
            end
            4'b1000: begin
                ext = {1'b0, A} + {1'b0, (A & B)} + {{WIDTH{1'b0}}, ~CIN};
                c_int = ext[WIDTH];
            end
            4'b1001: begin
                ext = {1'b0, A} + {1'b0, B} + {{WIDTH{1'b0}}, ~CIN};
                c_int = ext[WIDTH];
            end
            4'b1010: begin
                ext = {1'b0, (A | (~B))} + {1'b0, (A & B)} + {{WIDTH{1'b0}}, ~CIN};
                c_int = ext[WIDTH];
            end
            4'b1011: begin
                term = A & B;
                lhs_ext = {1'b0, term};
                rhs_ext = {{WIDTH{1'b0}}, CIN};
                ext = lhs_ext - rhs_ext;
                c_int = (lhs_ext >= rhs_ext);
            end
            4'b1100: begin
                ext = {1'b0, A} + {1'b0, A} + {{WIDTH{1'b0}}, ~CIN};
                c_int = ext[WIDTH];
            end
            4'b1101: begin
                ext = {1'b0, (A | B)} + {1'b0, A} + {{WIDTH{1'b0}}, ~CIN};
                c_int = ext[WIDTH];
            end
            4'b1110: begin
                ext = {1'b0, (A | (~B))} + {1'b0, A} + {{WIDTH{1'b0}}, ~CIN};
                c_int = ext[WIDTH];
            end
            4'b1111: begin
                lhs_ext = {1'b0, A};
                rhs_ext = {{WIDTH{1'b0}}, CIN};
                ext = lhs_ext - rhs_ext;
                c_int = (lhs_ext >= rhs_ext);
            end
            default: begin
                ext = '0;
                c_int = 1'b0;
            end
        endcase

        f_int = ext[WIDTH-1:0];
    end
end

assign F = ABUS ? f_int : {WIDTH{1'bz}};
assign C = c_int;
assign Z = (f_int == '0);

endmodule

`endif
