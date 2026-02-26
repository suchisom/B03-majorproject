module ALU_Decoder(ALUOp, funct3, funct7, op, ALUControl);
    input [1:0] ALUOp;
    input [2:0] funct3;
    input [6:0] funct7, op;
    output reg [3:0] ALUControl;

    always @(*) begin
        if (ALUOp == 2'b00) 
            ALUControl = 4'b0000; // ADD (Loads/Stores)
        else if (ALUOp == 2'b01) 
            ALUControl = 4'b0001; // SUB (Branches)
        else if (ALUOp == 2'b11) begin
            if (op[5] == 1'b1) ALUControl = 4'b1111; // LUI (Pass Imm directly)
            else               ALUControl = 4'b1110; // AUIPC (Trigger PC + Imm routing)
        end
        else begin // ALUOp == 2'b10
            case (funct3)
                3'b000: begin
                    if ({op[5], funct7[5]} == 2'b11) ALUControl = 4'b0001; // SUB
                    else ALUControl = 4'b0000; // ADD
                end
                3'b001: ALUControl = 4'b0111; // SLL
                3'b010: ALUControl = 4'b0101; // SLT
                3'b011: ALUControl = 4'b0110; // SLTU
                3'b100: ALUControl = 4'b0100; // XOR
                3'b101: begin
                    if (funct7[5] == 1'b1) ALUControl = 4'b1001; // SRA
                    else ALUControl = 4'b1000; // SRL
                end
                3'b110: ALUControl = 4'b0011; // OR
                3'b111: ALUControl = 4'b0010; // AND
                default: ALUControl = 4'b0000;
            endcase
        end
    end
endmodule