module decode_cycle(
    input clk, rst, StallD, FlushE,
    input [31:0] InstrD, PCD, PCPlus4D,
    input RegWriteW,
    input [4:0] RDW,
    input [31:0] ResultW,
    
    output reg RegWriteE, ALUSrcE, MemWriteE, ResultSrcE, BranchE, JumpE, JalrE,
    output reg [3:0] ALUControlE, // CHANGED: 4 bits
    output reg [31:0] RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E,
    output reg [4:0] RD_E, RS1_E, RS2_E,
    output reg [2:0] funct3E,     // NEW: Pass funct3 to Ex stage
    output [4:0] Rs1_D, Rs2_D
);

    wire RegWriteD, ALUSrcD, MemWriteD, ResultSrcD, BranchD, JumpD, JalrD;
    wire [2:0] ImmSrcD;           // CHANGED: 3 bits
    wire [3:0] ALUControlD;       // CHANGED: 4 bits
    wire [31:0] RD1_D, RD2_D, Imm_Ext_D;
    wire [2:0] funct3D = InstrD[14:12]; // Extract funct3

    assign Rs1_D = InstrD[19:15];
    assign Rs2_D = InstrD[24:20];

    Control_Unit_Top Control_Unit (
        .Op(InstrD[6:0]), .RegWrite(RegWriteD), .ImmSrc(ImmSrcD),
        .ALUSrc(ALUSrcD), .MemWrite(MemWriteD), .ResultSrc(ResultSrcD),
        .Branch(BranchD), .funct3(funct3D), .funct7(InstrD[31:25]),
        .ALUControl(ALUControlD), .Jump(JumpD), .Jalr(JalrD)
    );

    Register_File Reg_File (
        .clk(clk), .rst(rst), .A1(InstrD[19:15]), .A2(InstrD[24:20]),
        .A3(RDW), .WD3(ResultW), .WE3(RegWriteW), .RD1(RD1_D), .RD2(RD2_D)
    );

    Sign_Extend Sign_Ext (
        .In(InstrD), .ImmSrc(ImmSrcD), .Imm_Ext(Imm_Ext_D)
    );

    always @(posedge clk or negedge rst) begin
        if (rst == 0 || FlushE == 1) begin
            RegWriteE <= 0; ALUSrcE <= 0; MemWriteE <= 0; ResultSrcE <= 0;
            BranchE <= 0; ALUControlE <= 0; RD1_E <= 0; RD2_E <= 0;
            Imm_Ext_E <= 0; RD_E <= 0; PCE <= 0; PCPlus4E <= 0;
            RS1_E <= 0; RS2_E <= 0; JumpE <= 0; JalrE <= 0; funct3E <= 0;
        end
        else begin
            RegWriteE <= RegWriteD; ALUSrcE <= ALUSrcD; MemWriteE <= MemWriteD;
            ResultSrcE <= ResultSrcD; BranchE <= BranchD; ALUControlE <= ALUControlD;
            RD1_E <= RD1_D; RD2_E <= RD2_D; Imm_Ext_E <= Imm_Ext_D; RD_E <= InstrD[11:7];
            PCE <= PCD; PCPlus4E <= PCPlus4D; RS1_E <= Rs1_D; RS2_E <= Rs2_D;
            JumpE <= JumpD; JalrE <= JalrD; funct3E <= funct3D;
        end
    end
endmodule