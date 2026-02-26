module Main_Decoder(
    input [6:0] Op,
    output reg RegWrite,
    output reg [2:0] ImmSrc,
    output reg ALUSrc,
    output reg MemWrite,
    output reg ResultSrc,
    output reg Branch,
    output reg [1:0] ALUOp,
    output reg Jump,
    output reg Jalr
);

always @(*) begin
    // Defaults
    RegWrite = 0; ImmSrc = 3'b000; ALUSrc = 0; MemWrite = 0;
    ResultSrc = 0; Branch = 0; ALUOp = 2'b00; Jump = 0; Jalr = 0;

    case(Op)
        7'b0000011: begin // lw / Load
            RegWrite = 1; ImmSrc = 3'b000; ALUSrc = 1; MemWrite = 0;
            ResultSrc = 1; Branch = 0; ALUOp = 2'b00; Jump = 0; Jalr = 0;
        end
        7'b0100011: begin // sw / Store
            RegWrite = 0; ImmSrc = 3'b001; ALUSrc = 1; MemWrite = 1; 
            ResultSrc = 0; Branch = 0; ALUOp = 2'b00; Jump = 0; Jalr = 0;
        end
        7'b0110011: begin // R-Type
            RegWrite = 1; ImmSrc = 3'b000; ALUSrc = 0; MemWrite = 0;
            ResultSrc = 0; Branch = 0; ALUOp = 2'b10; Jump = 0; Jalr = 0;
        end
        7'b0010011: begin // I-Type ALU
            RegWrite = 1; ImmSrc = 3'b000; ALUSrc = 1; MemWrite = 0;
            ResultSrc = 0; Branch = 0; ALUOp = 2'b10; Jump = 0; Jalr = 0;
        end
        7'b1100011: begin // beq / Branches
            RegWrite = 0; ImmSrc = 3'b010; ALUSrc = 0; MemWrite = 0;
            ResultSrc = 0; Branch = 1; ALUOp = 2'b01; Jump = 0; Jalr = 0;
        end
        7'b1101111: begin // jal
            RegWrite = 1; ImmSrc = 3'b011; ALUSrc = 0; MemWrite = 0;
            ResultSrc = 0; Branch = 0; ALUOp = 2'b00; Jump = 1; Jalr = 0;
        end
        7'b1100111: begin // jalr
            RegWrite = 1; ImmSrc = 3'b000; ALUSrc = 1; MemWrite = 0;
            ResultSrc = 0; Branch = 0; ALUOp = 2'b00; Jump = 1; Jalr = 1;
        end
        7'b0110111: begin // lui
            RegWrite = 1; ImmSrc = 3'b100; ALUSrc = 1; MemWrite = 0;
            ResultSrc = 0; Branch = 0; ALUOp = 2'b11; Jump = 0; Jalr = 0;
        end
        7'b0010111: begin // auipc (NEW!)
            RegWrite = 1; ImmSrc = 3'b100; ALUSrc = 1; MemWrite = 0;
            ResultSrc = 0; Branch = 0; ALUOp = 2'b11; Jump = 0; Jalr = 0;
        end
    endcase
end
endmodule