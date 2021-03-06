`include "mips.svh"

module datacommit(
		input logic clk, reset, stall, 
		input exec_data_t [1: 0] in,
		output exec_data_t [1: 0] out,
		//to pipeline
		output pc_data_t fetch,
		//to fetch
		output word_t pc_commitC,
        output logic predict_wen,
        output bpb_result_t destpc_commitC,
        //to bpb
        input logic exception_valid,
        input exception_t exception_data_in,
        output exception_t exception_data_out,
        //from exception
        output bypass_upd_t bypass,
        //to bypass
        input logic dmem_en,
        input logic [1: 0] dmem_size,
        input word_t dmem_addr,
        input word_t dmem_rd,
        input logic dmem_data_ok,
        output logic finish_cdata
        //from mem
    );

    
    assign exception_data_out = exception_data_in;
    //to exception
    
    assign fetch.exception_valid = exception_valid;
    assign fetch.is_eret = (in[1].instr.op == ERET) | (in[0].instr.op == ERET); 
    assign fetch.pcexception = `EXC_ENTRY; 
    assign fetch.epc = (in[1].instr.op == ERET) ? (in[1].cp0_epc) : (in[0].cp0_epc);
    assign fetch.branch = (in[1].instr.ctl.branch) & (in[1].taken != in[1].pred.taken);
    assign fetch.jump = 1'b0;//(in[1].instr.ctl.jump) & (~in[1].pred.taken);  
    assign fetch.jr = in[1].instr.ctl.jr & (~in[1].pred.taken || in[1].pred.destpc != in[1].srca);
    assign fetch.pcbranch = (in[1].pred.taken) ? (in[0].pcplus4) : (in[1].instr.pcbranch);
    assign fetch.pcjr = in[1].srca;
    assign fetch.pcjump = in[1].instr.pcjump;
    //to fetch
    
    assign bypass.destreg = {in[1].destreg, in[0].destreg};
    assign bypass.result = {out[1].result, out[0].result};
    assign bypass.hiwrite = {in[1].instr.ctl.hiwrite, in[0].instr.ctl.hiwrite};
    assign bypass.lowrite = {in[1].instr.ctl.lowrite, in[0].instr.ctl.lowrite};
    assign bypass.hidata = {in[1].hiresult, in[0].hiresult};
    assign bypass.lodata = {in[1].loresult, in[0].loresult};
    assign bypass.memtoreg = {in[1].instr.ctl.memtoreg, in[0].instr.ctl.memtoreg};
    assign bypass.cp0_addr = {in[1].cp0_addr, in[0].cp0_addr};
    assign bypass.wen = {in[1].instr.ctl.regwrite, in[0].instr.ctl.regwrite};
    assign bypass.cp0_wen = {in[1].instr.ctl.cp0write, in[0].instr.ctl.cp0write};
    //to bypass net
    
    assign pc_commitC = in[1].pcplus4 - 'd4;
    assign predict_wen = in[1].instr.ctl.branch; //|| ((in[1].instr.ctl.jump) && (~in[1].instr.ctl.jr));
    assign destpc_commitC = {in[1].taken, // || (in[1].instr.ctl.jump & ~in[1].instr.ctl.jr), 
                             (in[1].instr.ctl.jump) ? (in[1].instr.pcjump) : (in[1].instr.pcbranch)};
	//to bpb    
	
	m_q_t mem;
	word_t dmem_rd_h, rd;
	assign rd = (dmem_data_ok) ? (dmem_rd) : (dmem_rd_h);
	decoded_op_t op;
	assign op = (in[1].instr.ctl.memwrite | in[1].instr.ctl.memtoreg) ? (in[1].instr.op) : (in[0].instr.op);
	assign mem.size = dmem_size;
	assign mem.addr = dmem_addr;
	readdata_format readdata_format (._rd(rd), .rd(mem.rd), .addr(mem.addr[1: 0]), .op(op));
	mem_to_reg mem_to_reg1(in[1], mem, out[1]);
    mem_to_reg mem_to_reg0(in[0], mem, out[0]);
    
    
    logic data_ok_h;
    always_ff @(posedge clk)
    	begin
    		if (~reset | ~stall)
    			begin
    				data_ok_h <= 1'b0;
    				dmem_rd_h <= '0;
				end    				
    		else
    			if (stall)
    				begin
    					data_ok_h <= data_ok_h | dmem_data_ok;
    					dmem_rd_h <= (dmem_data_ok) ? dmem_rd : (dmem_rd_h);	
    				end 
    	end
    assign finish_cdata = ~dmem_en | (dmem_data_ok | data_ok_h);	                            
    
endmodule
