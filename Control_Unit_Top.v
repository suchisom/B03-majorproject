module Control_Unit_Top(
    input [6:0] Op, funct7,
    input [2:0] funct3,
    output RegWrite, ALUSrc, MemWrite, ResultSrc, Branch, Jump, Jalr,
    output [2:0] ImmSrc,    // CHANGED: 3 bits
    output [3:0] ALUControl // CHANGED: 4 bits
); 

    wire [1:0] ALUOp;

    Main_Decoder Main_Decoder1(
        .Op(Op),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp),
        .Jump(Jump),
        .Jalr(Jalr) // NEW
    );

    ALU_Decoder ALU_Decoder2(
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .op(Op),
        .ALUControl(ALUControl)
    );

endmodule