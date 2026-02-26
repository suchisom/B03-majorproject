module Sign_Extend(
    input [31:0] In,
    input [2:0] ImmSrc,  // CHANGED: Now 3 bits
    output reg [31:0] Imm_Ext
);

    always @(*) begin
        case(ImmSrc)
            3'b000: Imm_Ext = {{20{In[31]}}, In[31:20]}; // I-Type
            3'b001: Imm_Ext = {{20{In[31]}}, In[31:25], In[11:7]}; // S-Type
            3'b010: Imm_Ext = {{20{In[31]}}, In[7], In[30:25], In[11:8], 1'b0}; // B-Type
            3'b011: Imm_Ext = {{12{In[31]}}, In[19:12], In[20], In[30:21], 1'b0}; // J-Type
            3'b100: Imm_Ext = {In[31:12], 12'b0}; // U-Type (LUI / AUIPC)
            default: Imm_Ext = 32'b0;
        endcase
    end

endmodule