module hazard_unit(
    input rst, PCSrcE, RegWriteM, RegWriteW, ResultSrcE, RegWriteE,
    input [4:0] RD_M, RD_W, RD_E, Rs1_D, Rs2_D, Rs1_E, Rs2_E,
    output [1:0] ForwardAE, ForwardBE,
    output StallF, StallD, FlushD, FlushE // ADDED StallD
);

    wire lwStall;

    // Forwarding Logic
    assign ForwardAE = (rst == 1'b0) ? 2'b00 :
                       (RegWriteM && (RD_M != 0) && (RD_M == Rs1_E)) ? 2'b10 :
                       (RegWriteW && (RD_W != 0) && (RD_W == Rs1_E)) ? 2'b01 : 2'b00;

    assign ForwardBE = (rst == 1'b0) ? 2'b00 :
                       (RegWriteM && (RD_M != 0) && (RD_M == Rs2_E)) ? 2'b10 :
                       (RegWriteW && (RD_W != 0) && (RD_W == Rs2_E)) ? 2'b01 : 2'b00;

    // Load-Use Hazard Detection
    // If Execute stage has a Load (ResultSrcE=1) and destination matches Decode source...
    assign lwStall = ResultSrcE & ((RD_E == Rs1_D) | (RD_E == Rs2_D));

    // STALLS AND FLUSHES
    // ------------------
    // StallF: Freeze PC if Load Hazard
    assign StallF = (rst == 1'b0) ? 1'b0 : lwStall;
    
    // StallD: Freeze Decode if Load Hazard (Keep instruction in D) -- NEW
    assign StallD = (rst == 1'b0) ? 1'b0 : lwStall;

    // FlushD: Only flush Decode on Branch Misprediction (PCSrcE)
    // REMOVED lwStall from here!
    assign FlushD = (rst == 1'b0) ? 1'b0 : PCSrcE;

    // FlushE: Flush Execute on Load Hazard OR Branch Misprediction
    assign FlushE = (rst == 1'b0) ? 1'b0 : (lwStall | PCSrcE);

endmodule