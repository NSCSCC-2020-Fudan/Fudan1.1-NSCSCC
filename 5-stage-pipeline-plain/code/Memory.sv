`include "MIPS.h"

/*
    HILOWriteEn: HI/LO register write enable
    
*/

module Memory(
        input logic HIWriteEn, LOWriteEn,
        output logic HIWriteEnOut, LOWriteEnOut,
        input logic PrivilegeWrite,
		input logic [4: 0] CP0RegWrite,
		input logic [2: 0] CP0SelWrite,
        output logic PrivilegeWriteOut,
		output logic [4: 0] CP0RegWriteOut,
		output logic [2: 0] CP0SelWriteOut,
 
        input logic [31: 0] RegRd1,
        input logic [4: 0] Memory,

        input logic [31: 0] ALUOut,
        input logic [31: 0] ALUOutHI, ALUOutLO,
        output logic [31: 0] ALUOutHIOut, ALUOutLOOut,

        output logic MemoryEn,
        output logic [1: 0] Mode,
        output logic [31: 0] Addr,
        output logic MemWriteEn,
        output logic [31: 0] MemoryWrite,
        input logic [31: 0] MemoryRead,

        output logic [31: 0] Result
    );

    assign MemoryEn = Memory[4];
    assign Mode = Memory[2: 1];
    assign Addr = ALUOut;
    assign MemWriteEn = Memory[3];
    assign MemoryWrite = RegRd1;

    logic [31: 0] Data8, Data16, Data32, MemoryData;
    Extend Extend8 (MemoryRead[7: 0], MemoryExtend, Data8);
    Extend Extend16 (MemoryRead[15: 0], MemoryExtend, Data16);
    assign Data32 = MemoryRead;
    always @(*)
        begin
            case (Mode)
                2'b00: Data = Data8;
                2'b01: Data = Data16;
                2'b11: Data = Data32;
                default: Data = 32'b0;
            endcase
        end

    assign ALUOutHIOut = ALUOutHI;
    assign ALUOutLOOut = ALUOutLO;
    assign Result = (Memory[4]) ? (Data) : (ALUOut);

    assign HIWriteEnOut = HIWriteEn;
    assign LOWriteEnOut = LOWriteEn;
    assign PrivilegeWriteOut = PrivilegeWrite;
    assign CP0SelWriteOut = CP0SelWrite; 
    assign CP0RegWriteOut = CP0RegWrite; 
endmodule
