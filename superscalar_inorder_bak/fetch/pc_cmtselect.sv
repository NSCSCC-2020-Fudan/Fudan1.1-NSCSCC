`include "mips.svh"

module pc_cmtselect(
        input logic clk, reset,
        input logic exception_valid, is_eret, branch, jump, jr, tlb_ex,
        input word_t pcexception, epc, pcbranch, pcjump, pcjr, pctlb,
        output word_t pc_new,
        output logic pc_upd
    );
    assign pc_upd = exception_valid | is_eret | branch | jr | jump | tlb_ex;
    assign pc_new = exception_valid      ? pcexception : (
                    is_eret              ? epc         : (
                    branch               ? pcbranch    : (
                    jr                   ? pcjr        : (
                    jump                 ? pcjump      : (
                    tlb_ex               ? pctlb       : (
                                                         32'hbfc00000))))));
                                               
endmodule