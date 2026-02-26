module execute_cycle(
    input clk, rst,
    input RegWriteE, ALUSrcE, MemWriteE, ResultSrcE, BranchE, JumpE, JalrE,
    input [3:0] ALUControlE, 
    input [31:0] RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E,
    input [4:0] RD_E,
    input [2:0] funct3E,     
    input [1:0] ForwardA_E, ForwardB_E,
    input [31:0] ResultW, ALU_ResultM,
    
    output reg RegWriteM, MemWriteM, ResultSrcM,
    output reg [4:0] RD_M,
    output reg [2:0] funct3M, 
    output reg [31:0] PCPlus4M, WriteDataM, ALU_ResultM_out,
    output [31:0] PCTargetE,
    output PCSrcE
);

    wire [31:0] SrcA, SrcB_Forwarded, SrcB;
    wire [31:0] ALUResult;
    wire Zero, Negative; 

    assign SrcA = (ForwardA_E == 2'b10) ? ALU_ResultM :
                  (ForwardA_E == 2'b01) ? ResultW : RD1_E;

    assign SrcB_Forwarded = (ForwardB_E == 2'b10) ? ALU_ResultM :
                            (ForwardB_E == 2'b01) ? ResultW : RD2_E;

    assign SrcB = (ALUSrcE) ? Imm_Ext_E : SrcB_Forwarded;

    ALU ALU_Unit (
        .A(SrcA), .B(SrcB), .ALUControl(ALUControlE),
        .Result(ALUResult), .Zero(Zero), .Negative(Negative) 
    );

    wire TakeBranch;
    assign TakeBranch = (funct3E == 3'b000) ? Zero :           // BEQ
                        (funct3E == 3'b001) ? ~Zero :          // BNE
                        (funct3E == 3'b100) ? Negative :       // BLT 
                        (funct3E == 3'b101) ? ~Negative :      // BGE 
                        1'b0;

    assign PCSrcE = (BranchE & TakeBranch) | JumpE | JalrE;
    
    assign PCTargetE = JalrE ? ((SrcA + Imm_Ext_E) & 32'hFFFFFFFE) : (PCE + Imm_Ext_E);

    // FIXED: Changed to negedge rst for proper active-low reset
    always @(posedge clk or negedge rst) begin
        if (rst == 0) begin 
            RegWriteM <= 0; MemWriteM <= 0; ResultSrcM <= 0;
            RD_M <= 0; PCPlus4M <= 0; WriteDataM <= 0; 
            ALU_ResultM_out <= 0; funct3M <= 0;
        end
        else begin
            RegWriteM <= RegWriteE; MemWriteM <= MemWriteE; ResultSrcM <= ResultSrcE;
            RD_M <= RD_E; PCPlus4M <= PCPlus4E; WriteDataM <= SrcB_Forwarded;
            
            // THE CURE FOR AMNESIA & AUIPC:
            // 1. Jumps: Inject PC+4 into the ALU path for function returns
            // 2. AUIPC (ALUControl == 1110): Inject PCTargetE (which perfectly contains PCE + Imm)
            ALU_ResultM_out <= (JumpE | JalrE) ? PCPlus4E : 
                               (ALUControlE == 4'b1110) ? PCTargetE : 
                               ALUResult; 
            
            funct3M <= funct3E;
        end
    end
endmodule