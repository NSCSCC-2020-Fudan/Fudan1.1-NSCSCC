`include "mips.svh"
module execute (
    decode_ereg_exec.exec in,
    exec_mreg_memory.exec out
);
    decode_data_t dataD;
    exec_data_t dataE;
    wrmux wrmux0(.rt(decoded_instr.rt), .rd(decoded_instr.rd), .jump(decoded_instr.jump), .regdst(decoded_instr.regdst), .writereg(writereg));
    srcamux srcamux();
    wdmux wdmux();
    srcbmux srcbmux();
    alu alu(srca, srcb, dataD.decoded_instr.ctl.alufunc, dataE.aluout, dataE.exception_of);
    mult multdiv(.a(srca), .b(srcb), .op(dataD.decoded_instr.op), .hi(dataE.hi), .lo(dataE.lo));

    assign dataE.
endmodule