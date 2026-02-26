module fetch_cycle(
    input clk, rst, PCSrcE, StallF, FlushD, StallD,
    input [31:0] PCTargetE,
    output [31:0] InstrD, PCD, PCPlus4D
);

    wire [31:0] PC_F, PCF, PCPlus4F;
    wire [31:0] InstrF;
    reg [31:0] InstrD_reg, PCD_reg, PCPlus4D_reg;

    // PC Mux
    Mux PC_Mux (
        .a(PCPlus4F),
        .b(PCTargetE),
        .s(PCSrcE),
        .c(PC_F)
    );

    PC_Module PC (
        .clk(clk),
        .rst(rst),
        .StallF(StallF),
        .PC_Next(PC_F),
        .PC(PCF)
    );

    Instruction_Memory IM (
        .rst(rst),
        .A(PCF),
        .RD(InstrF)
    );

    PC_Adder PC_Add (
        .a(PCF),
        .b(32'd4),
        .c(PCPlus4F)
    );

    // FETCH -> DECODE Pipeline Register
    always @(posedge clk or negedge rst) begin
        if (rst == 0) begin
            InstrD_reg   <= 0;
            PCD_reg      <= 0;
            PCPlus4D_reg <= 0;
        end
        else if (FlushD) begin
            InstrD_reg   <= 0;
            PCD_reg      <= 0;
            PCPlus4D_reg <= 0;
        end
        else if (StallD == 0) begin
            InstrD_reg   <= InstrF;
            PCD_reg      <= PCF;
            PCPlus4D_reg <= PCPlus4F;
        end
    end

    assign InstrD = InstrD_reg;
    assign PCD = PCD_reg;
    assign PCPlus4D = PCPlus4D_reg;

endmodule