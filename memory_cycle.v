module memory_cycle(
    input clk, rst, RegWriteM, MemWriteM, ResultSrcM,
    input [4:0] RD_M,
    input [2:0] funct3M, // NEW
    input [31:0] PCPlus4M, WriteDataM, ALU_ResultM,
    output RegWriteW, ResultSrcW, 
    output [4:0] RD_W,
    output [31:0] PCPlus4W, ALU_ResultW, ReadDataW
);

    wire [31:0] ReadDataM;
    reg [31:0] FormattedReadDataM;
    reg [3:0] WE_Mask;
    wire [1:0] byte_offset = ALU_ResultM[1:0];

    // 1. Generate 4-bit Write Mask for Stores (sb, sh, sw)
    always @(*) begin
        if (MemWriteM) begin
            case (funct3M)
                3'b010: WE_Mask = 4'b1111; // SW: Store Word
                3'b001: WE_Mask = (byte_offset[1]) ? 4'b1100 : 4'b0011; // SH: Store Half
                3'b000: WE_Mask = (byte_offset == 2'b11) ? 4'b1000 : 
                                  (byte_offset == 2'b10) ? 4'b0100 : 
                                  (byte_offset == 2'b01) ? 4'b0010 : 4'b0001; // SB: Store Byte
                default: WE_Mask = 4'b0000;
            endcase
        end else begin
            WE_Mask = 4'b0000;
        end
    end

    // Use the updated Data_Memory (with 4-bit WE) we created earlier
    Data_Memory dmem (
        .clk(clk), .rst(rst), .WE(WE_Mask),
        .WD(WriteDataM), .A(ALU_ResultM), .RD(ReadDataM)
    );

    // 2. Format Read Data for Loads (lb, lh, lw, lbu, lhu)
    always @(*) begin
        case (funct3M)
            3'b000: begin // LB: Load Byte (Sign Extended)
                if (byte_offset == 2'b11) FormattedReadDataM = {{24{ReadDataM[31]}}, ReadDataM[31:24]};
                else if (byte_offset == 2'b10) FormattedReadDataM = {{24{ReadDataM[23]}}, ReadDataM[23:16]};
                else if (byte_offset == 2'b01) FormattedReadDataM = {{24{ReadDataM[15]}}, ReadDataM[15:8]};
                else FormattedReadDataM = {{24{ReadDataM[7]}}, ReadDataM[7:0]};
            end
            3'b001: begin // LH: Load Half (Sign Extended)
                if (byte_offset[1]) FormattedReadDataM = {{16{ReadDataM[31]}}, ReadDataM[31:16]};
                else FormattedReadDataM = {{16{ReadDataM[15]}}, ReadDataM[15:0]};
            end
            3'b100: begin // LBU: Load Byte Unsigned
                if (byte_offset == 2'b11) FormattedReadDataM = {24'd0, ReadDataM[31:24]};
                else if (byte_offset == 2'b10) FormattedReadDataM = {24'd0, ReadDataM[23:16]};
                else if (byte_offset == 2'b01) FormattedReadDataM = {24'd0, ReadDataM[15:8]};
                else FormattedReadDataM = {24'd0, ReadDataM[7:0]};
            end
            3'b101: begin // LHU: Load Half Unsigned
                if (byte_offset[1]) FormattedReadDataM = {16'd0, ReadDataM[31:16]};
                else FormattedReadDataM = {16'd0, ReadDataM[15:0]};
            end
            default: FormattedReadDataM = ReadDataM; // LW: Load Word
        endcase
    end

    // Interim Registers
    reg RegWriteM_r, ResultSrcM_r;
    reg [4:0] RD_M_r;
    reg [31:0] PCPlus4M_r, ALU_ResultM_r, ReadDataM_r;

    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            RegWriteM_r <= 0; ResultSrcM_r <= 0; RD_M_r <= 0;
            PCPlus4M_r <= 0; ALU_ResultM_r <= 0; ReadDataM_r <= 0;
        end else begin
            RegWriteM_r <= RegWriteM; ResultSrcM_r <= ResultSrcM; RD_M_r <= RD_M;
            PCPlus4M_r <= PCPlus4M; ALU_ResultM_r <= ALU_ResultM; 
            ReadDataM_r <= FormattedReadDataM; // Use Formatted Data
        end
    end 

    assign RegWriteW = RegWriteM_r;
    assign ResultSrcW = ResultSrcM_r;
    assign RD_W = RD_M_r;
    assign PCPlus4W = PCPlus4M_r;
    assign ALU_ResultW = ALU_ResultM_r;
    assign ReadDataW = ReadDataM_r;

endmodule