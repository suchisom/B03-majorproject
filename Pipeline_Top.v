module Pipeline_top(clk, rst);
    input clk, rst;
    
    wire PCSrcE, RegWriteW, RegWriteE, ALUSrcE, MemWriteE, ResultSrcE, BranchE, RegWriteM, MemWriteM, ResultSrcM, ResultSrcW;
    wire [3:0] ALUControlE;
    wire [4:0] RD_E, RD_M, RDW;
    wire [31:0] PCTargetE, InstrD, PCD, PCPlus4D, ResultW, RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E, PCPlus4M, WriteDataM, ALU_ResultM;
    wire [31:0] PCPlus4W, ALU_ResultW, ReadDataW;
    wire [4:0] RS1_E, RS2_E, Rs1_D, Rs2_D;
    wire [1:0] ForwardBE, ForwardAE;
    wire JumpE;
    
    // NEW: Wires for C code compatibility
    wire JalrE;
    wire [2:0] funct3E;
    wire [2:0] funct3M;
    
    // Hazard Wires
    wire StallF, StallD, FlushD, FlushE; 

    fetch_cycle Fetch (
                        .clk(clk),
                        .rst(rst),
                        .PCSrcE(PCSrcE),
                        .PCTargetE(PCTargetE),
                        .StallF(StallF),
                        .FlushD(FlushD),
                        .StallD(StallD),
                        .InstrD(InstrD),
                        .PCD(PCD),
                        .PCPlus4D(PCPlus4D)
                    );

    decode_cycle Decode1 (
                        .clk(clk),
                        .rst(rst),
                        .InstrD(InstrD),
                        .PCD(PCD),
                        .PCPlus4D(PCPlus4D),
                        .RegWriteW(RegWriteW),
                        .RDW(RDW),
                        .ResultW(ResultW),
                        .RegWriteE(RegWriteE),
                        .ALUSrcE(ALUSrcE),
                        .MemWriteE(MemWriteE),
                        .ResultSrcE(ResultSrcE),
                        .BranchE(BranchE),
                        .ALUControlE(ALUControlE),
                        .RD1_E(RD1_E),
                        .RD2_E(RD2_E),
                        .Imm_Ext_E(Imm_Ext_E),
                        .RD_E(RD_E),
                        .PCE(PCE),
                        .PCPlus4E(PCPlus4E),
                        .RS1_E(RS1_E),
                        .RS2_E(RS2_E),
                        .Rs1_D(Rs1_D),
                        .Rs2_D(Rs2_D),
                        .FlushE(FlushE),
                        .JumpE(JumpE),
                        .JalrE(JalrE),       // NEW: Connect Jalr
                        .funct3E(funct3E),   // NEW: Connect funct3
                        .StallD(StallD) 
                    );

    execute_cycle Execute (
                        .clk(clk),
                        .rst(rst),
                        .RegWriteE(RegWriteE),
                        .ALUSrcE(ALUSrcE),
                        .MemWriteE(MemWriteE),
                        .ResultSrcE(ResultSrcE),
                        .BranchE(BranchE),
                        .ALUControlE(ALUControlE),
                        .RD1_E(RD1_E),
                        .RD2_E(RD2_E),
                        .Imm_Ext_E(Imm_Ext_E),
                        .RD_E(RD_E),
                        .PCE(PCE),
                        .PCPlus4E(PCPlus4E),
                        .PCSrcE(PCSrcE),
                        .PCTargetE(PCTargetE),
                        .RegWriteM(RegWriteM),
                        .MemWriteM(MemWriteM),
                        .ResultSrcM(ResultSrcM),
                        .RD_M(RD_M),
                        .PCPlus4M(PCPlus4M),
                        .WriteDataM(WriteDataM),
                        .ALU_ResultM_out(ALU_ResultM), 
                        .ALU_ResultM(ALU_ResultM),     
                        .ResultW(ResultW),
                        .ForwardA_E(ForwardAE),
                        .ForwardB_E(ForwardBE),
                        .JumpE(JumpE),
                        .JalrE(JalrE),       // NEW: Input Jalr
                        .funct3E(funct3E),   // NEW: Input funct3
                        .funct3M(funct3M)    // NEW: Output funct3 to Memory stage
                    );

    memory_cycle Memory (
                        .clk(clk),
                        .rst(rst),
                        .RegWriteM(RegWriteM),
                        .MemWriteM(MemWriteM),
                        .ResultSrcM(ResultSrcM),
                        .RD_M(RD_M),
                        .funct3M(funct3M),   // NEW: Input funct3 to handle sb/sh/lb/lh
                        .PCPlus4M(PCPlus4M),
                        .WriteDataM(WriteDataM),
                        .ALU_ResultM(ALU_ResultM),
                        .RegWriteW(RegWriteW),
                        .ResultSrcW(ResultSrcW),
                        .RD_W(RDW),
                        .PCPlus4W(PCPlus4W),
                        .ALU_ResultW(ALU_ResultW),
                        .ReadDataW(ReadDataW)
                    );

    writeback_cycle WriteBack (
                        .clk(clk),
                        .rst(rst),
                        .ResultSrcW(ResultSrcW),
                        .PCPlus4W(PCPlus4W),
                        .ALU_ResultW(ALU_ResultW),
                        .ReadDataW(ReadDataW),
                        .ResultW(ResultW)
                    );

    hazard_unit Forwarding_block (
        .rst(rst),
        .PCSrcE(PCSrcE),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .ResultSrcE(ResultSrcE),
        .RegWriteE(RegWriteE),
        .RD_M(RD_M),
        .RD_W(RDW),
        .RD_E(RD_E),
        .Rs1_D(Rs1_D),
        .Rs2_D(Rs2_D),
        .Rs1_E(RS1_E),
        .Rs2_E(RS2_E),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE)
    );
endmodule