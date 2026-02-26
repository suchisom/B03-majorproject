module Data_Memory(
    input clk, rst, 
    input [3:0] WE,      // CHANGED: 4-bit Write Enable (Byte Mask)
    input [31:0] A, WD,
    output [31:0] RD
);
    // Expanded to 4096 Words (16KB)
    reg [31:0] mem [0:4095]; 
    integer i;

    initial begin
        for(i=0; i<4096; i=i+1) mem[i] = 32'd0;
    end

    // Synchronous Write with Byte Enables
    always @(posedge clk) begin
        // Uses A[13:2] to safely index the 4096 word array
        if(WE[0]) mem[A[13:2]][7:0]   <= WD[7:0];
        if(WE[1]) mem[A[13:2]][15:8]  <= WD[15:8];
        if(WE[2]) mem[A[13:2]][23:16] <= WD[23:16];
        if(WE[3]) mem[A[13:2]][31:24] <= WD[31:24];
    end

    // Asynchronous Read 
    assign RD = (~rst) ? 32'd0 : mem[A[13:2]];

endmodule