module bru 
    import common::*;
    import decode_pkg::*;(
    input word_t src1, src2,
    input word_t pcplus4, imm,
    input branch_t branch_type,
    output logic branch_taken
    output word_t pcbranch
);
    assign pcbranch = pcplus4 + {imm[29:0], 2'b00};
    always_comb begin
        case (branch_type)
            T_BEQ: branch_taken = src1 == src2;
            T_BNE: branch_taken = src1 != src2;
            T_BGEZ: branch_taken = ~src1[31];
            T_BLTZ: branch_taken = src1[31];
            T_BGTZ: branch_taken = (src1 != 0) && src1[31];
            T_BLEZ: branch_taken = (src1 == 0) || src1[31];
            default: begin
                branch_taken = 1'b0;
            end
        endcase
    end
endmodule