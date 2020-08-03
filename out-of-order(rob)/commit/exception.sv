`include "interface.svh"
module exception
    import common::*;
    import exception_pkg::*;
    import cp0_pkg::*;(
    input logic clk, resetn, flush,
    input logic[5:0] ext_int,
    exception_intf.excep self,
    pcselect_intf.exception pcselect,
    hazard_intf.exception hazard
);
    // assign pcselect.exception_valid = 1'b0;
    
    // input logic reset,
    // logic exception_instr, exception_ri, exception_of, exception_load, exception_bp, exception_sys;
    interrupt_info_t interrupt_info;
    logic exception_valid;
    exception_info_t exc_info;
    exc_code_t exccode;
    // word_t vaddr;
    // logic in_delay_slot;
    word_t pc;
    exception_t exception;
    cp0_status_t cp0_status;
    // interrupt
    logic interrupt_valid;
    logic interrupt_valid_new;
    // assign interrupt_valid = 1'b0;
    assign interrupt_info = ({ext_int, 2'b00} | self.cp0_cause.IP | {self.timer_interrupt, 7'b0}) & self.cp0_status.IM;
    assign interrupt_valid_new = (interrupt_info != 0) // request
                           & (self.cp0_status.IE)
                        //    & (~cp0.debug.DM)
                           & (~self.cp0_status.EXL)
                           & (~self.cp0_status.ERL);
//    assign interrupt_valid = '0;

    always_ff @(posedge clk) begin
        if (~resetn | flush) begin
            interrupt_valid <= 1'b0;
        end else if (~interrupt_valid) begin
            interrupt_valid <= interrupt_valid_new;
        end
    end
    always_comb begin
        priority case (1'b1)
            interrupt_valid: begin
                exception_valid = 1'b1;
                exccode = CODE_INT;
            end
            exc_info.instr : begin
                exception_valid = 1'b1;
                exccode = CODE_ADEL;
            end
            exc_info.ri: begin
                exception_valid = 1'b1;
                exccode = CODE_RI;
            end
            exc_info.of: begin
                exception_valid = 1'b1;
                exccode = CODE_OV;
            end
            exc_info.sys: begin
                exception_valid = 1'b1;
                exccode = CODE_SYS;
            end
            exc_info.bp: begin
                exception_valid = 1'b1;
                exccode = CODE_BP;
            end
            exc_info.load: begin
                exception_valid = 1'b1;
                exccode = CODE_ADEL;
            end
            exc_info.save: begin
                exception_valid = 1'b1;
                exccode = CODE_ADES;
            end
            default: begin
                exception_valid = 1'b0;
                exccode = '0;
            end
        endcase
    end
        
    //     if (interrupt_valid) begin
    //         exception_valid = 1'b1;
    //         exccode = CODE_INT;
    //     end else if (exception_instr) begin
    //         exception_valid = 1'b1;
    //         exccode = CODE_ADEL;
    //     end else if (exception_ri) begin
    //         exception_valid = 1'b1;
    //         exccode = CODE_RI;
    //     end else if (exception_of) begin
    //         exception_valid = 1'b1;
    //         exccode = CODE_OV;
    //     end else if (exception_sys) begin
    //         exception_valid = 1'b1;
    //         exccode = CODE_SYS;
    //     end else if (exception_bp) begin
    //         exception_valid = 1'b1;
    //         exccode = CODE_BP;
    //     end else if (exception_load) begin
    //         exception_valid = 1'b1;
    //         exccode = CODE_ADEL;
    //     end else if (exception_save) begin
    //         exception_valid = 1'b1;
    //         exccode = CODE_ADES;
    //     end else begin
    //         exception_valid = 1'b0;
    //         exccode = '0;
    //     end
    // end
    // exception_offset_t offset;
    // always_comb begin
    //     if (cp0.status.EXL) begin
    //         offset = 12'h180;
    //     end else begin
    //         if (exccode == CODE_TLBL || exccode == CODE_TLBS) begin
    //             offset = 12'h000;
    //         end else begin
    //             if (cp0.status.BEV) begin
    //                 offset = 12'h200;
    //             end else begin
    //                 offset = 12'h180;
    //             end
    //         end
    //     end
    // end
    // assign exception.location = EXC_BASE + offset;
    assign exc_info = self.exc_info;
    assign exception.location = EXC_ENTRY;
    assign exception.valid = (interrupt_valid | exception_valid) & resetn;
    assign exception.code = (interrupt_valid) ? (CODE_INT) : (exccode);
    assign exception.pcplus8 = self.pcplus8;
    assign exception.in_delay_slot = self.in_delay_slot;
    assign exception.badvaddr = self.badvaddr;

    assign pcselect.exception_valid = exception_valid;
    assign pcselect.pcexception = EXC_ENTRY;
    assign hazard.exception_valid = exception_valid;
    assign self.exception = exception;
    assign self.interrupt_valid = interrupt_valid;
    // assign interrupt_info = self.interrupt_info;
    // assign cp0_status = self.cp0_status;
    
endmodule