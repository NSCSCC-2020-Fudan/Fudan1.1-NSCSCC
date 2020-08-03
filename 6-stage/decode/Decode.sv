`include "mips.svh"

module decode (
    // input word_t instr,
    // inout fetch_data_t dataF,
	// output dataD_t dataD,
	// output word_t pcbranch, pcjump,
	// output branch_taken,
	// input word_t srca0, srcb0
	fetch_dreg_decode.decode in,
	decode_ereg_exec.decode out,
	regfile_intf.decode regfile,
	hilo_intf.decode hilo,
	cp0_intf.decode cp0,
	hazard_intf.decode hazard,
	pcselect_intf.decode pcselect
);
	op_t op;
	func_t func;
	halfword_t imm;
	decode_data_t dataD;
	fetch_data_t dataF;
	logic ext;
	word_t pcbranch, pcjump;
	logic branch_taken;
	word_t hi, lo;
	word_t aluoutM, resultW;
	logic is_reserved;
	forward_t forwardAD, forwardBD;
    assign op = dataF.instr_[31:26];
	assign func = dataF.instr_[5:0];
	assign imm = dataF.instr_[15:0];
	assign dataD.instr.rs = dataF.instr_[25:21];
	assign dataD.instr.rt = dataF.instr_[20:16];
	assign dataD.instr.rd = dataF.instr_[15:11];
	assign dataD.instr.shamt = dataF.instr_[10:6];
	extend ext1(imm, dataD.instr.ctl.zeroext, dataD.instr.extended_imm);
	maindec mainde(dataF.instr_, dataD.instr.op, dataD.exception_ri, dataD.instr.ctl);
	// aludec alude(dataD.instr.op, dataD.instr.ctl.alufunc);
	assign is_reserved = dataD.instr.op == RESERVED;
	assign pcbranch = dataF.pcplus4 + {dataD.instr.extended_imm[29:0], 2'b00};
	assign pcjump = {dataF.pcplus4[31:28], dataF.instr_[25:0], 2'b00};
	branch_controller branch_controller(.srca(dataD.srca), .srcb(dataD.srcb), .branch_type(dataD.instr.ctl.branch_type), .branch_taken(branch_taken));

	assign dataD.pcplus4 = dataF.pcplus4;
	assign dataD.exception_instr = dataF.exception_instr;

	srcadmux srcadmux(.regfile(regfile.src1),.m(hazard.aluoutM),.w(hazard.resultW),.alusrcaE(hazard.alusrcaE),
					  .forward(hazard.forwardAD), .ctl(dataD.instr.ctl), 
					  .hiD(hilo.hi), .loD(hilo.lo), .cp0D(cp0.rd),
					  .srca(dataD.srca));
	srcbdmux srcbdmux(.regfile(regfile.src2),.m(hazard.aluoutM),.w(hazard.resultW),.alusrcaE(hazard.alusrcaE),
					  .forward(hazard.forwardBD), .srcb(dataD.srcb));

	assign dataD.in_delay_slot = dataF.in_delay_slot;
    always_comb begin
        dataD.cp0_cause = cp0.cp0_data.cause;
		dataD.cp0_status = cp0.cp0_data.status;
		if (hazard.dataE.instr.ctl.cp0write && hazard.dataE.instr.rd == 5'd13) begin
			dataD.cp0_cause.IP[1:0] = hazard.dataE.aluout[9:8];
		end else if (hazard.dataM.instr.ctl.cp0write && hazard.dataM.instr.rd == 5'd13) begin
			dataD.cp0_cause.IP[1:0] = hazard.dataM.aluout[9:8];
		end else if (cp0.cwrite.wen && cp0.cwrite.addr == 5'd13) begin
            dataD.cp0_cause.IP[1:0] = cp0.cwrite.wd[9:8];
		end
		if (hazard.dataE.instr.ctl.cp0write && hazard.dataE.instr.rd == 5'd12) begin
			dataD.cp0_status.IM = hazard.dataE.aluout[15:8];
            dataD.cp0_status.EXL = hazard.dataE.aluout[1];
            dataD.cp0_status.IE = hazard.dataE.aluout[0];
		end else if (hazard.dataM.instr.ctl.cp0write && hazard.dataM.instr.rd == 5'd12) begin
			dataD.cp0_status.IM = hazard.dataM.aluout[15:8];
            dataD.cp0_status.EXL = hazard.dataM.aluout[1];
            dataD.cp0_status.IE = hazard.dataM.aluout[0];
		end else if (cp0.cwrite.wen && cp0.cwrite.addr == 5'd12) begin
            dataD.cp0_status.IM = cp0.cwrite.wd[15:8];
            dataD.cp0_status.EXL = cp0.cwrite.wd[1];
            dataD.cp0_status.IE = cp0.cwrite.wd[0];
        end
    end
	// ports
	// 	fetch_dreg_decode.decode in
	assign dataF = in.dataF;
	assign in.in_delay_slot = dataD.instr.ctl.branch | dataD.instr.ctl.jump;
	// decode_ereg_exec.decode out
	assign out.dataD_new = dataD;

	// regfile_intf.decode regfile
	assign regfile.ra1 = dataD.instr.rs;
	assign regfile.ra2 = dataD.instr.rt;

	// hilo_intf.decode hilo
	assign hi = hilo.hi;
	assign lo = hilo.lo;

	// cp0_intf.decode cp0
	assign cp0.ra = dataD.instr.rd;
	// hazard_intf.decode hazard
	assign hazard.dataD = dataD;
	assign forwardAD = hazard.forwardAD;
	assign forwardBD = hazard.forwardBD;
	assign aluoutM = hazard.aluoutM;
	assign resultW = hazard.resultW;

	// pcselect_intf.decode pcselect
	assign pcselect.pcbranchD = pcbranch;
	assign pcselect.pcjumpD = pcjump;
	assign pcselect.pcjrD = dataD.srca;
	assign pcselect.branch_taken = branch_taken & dataD.instr.ctl.branch;
	assign pcselect.jr = dataD.instr.ctl.jr;
	assign pcselect.jump = dataD.instr.ctl.jump;
endmodule