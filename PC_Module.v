module PC_Module(
    input clk,
    input rst,
    input StallF, // ADDED: Stall functionality
    input [31:0] PC_Next,
    output reg [31:0] PC
);

    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            PC <= 32'h00000000;
        end
        else if (StallF == 1'b0) begin 
            // Only update PC if StallF is 0 (Active Low Stall or Enable)
            // Based on Hazard Unit: StallF=1 means FREEZE.
            PC <= PC_Next;
        end
        // If StallF == 1, PC holds its value (Loop/Stall)
    end
endmodule