module Instruction_Memory(rst, A, RD);
    input rst;
    input [31:0] A;
    output [31:0] RD;

    reg [31:0] mem [0:1023]; 
    integer i; 

    // Reset Logic
    assign RD = (rst == 1'b0) ? 32'd0 : mem[A[31:2]];

    initial begin
        // 1. Initialize to 0
        for(i=0; i<1024; i=i+1) begin
            mem[i] = 32'h00000000;
        end

        // 2. Load File
        $readmemh("memfile.hex", mem); 
    end
endmodule