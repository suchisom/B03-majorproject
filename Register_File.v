module Register_File(clk,rst,WE3,WD3,A1,A2,A3,RD1,RD2);

    input clk,rst,WE3;
    input [4:0]A1,A2,A3;
    input [31:0]WD3;
    output [31:0]RD1,RD2;

    reg [31:0] Register [31:0];
    integer i; // Required for the loop

    // Write Logic
    always @ (posedge clk)
    begin
        // Write only if WE3 is high AND we are not writing to x0
        if(WE3 & (A3 != 5'h00))
            Register[A3] <= WD3;
    end //

    // Read Logic - FIXED WITH INTERNAL FORWARDING
    // 1. If Address is 0, ALWAYS return 0 (Hardwired x0)
    // 2. If writing to the same register we are reading from, forward WD3
    // 3. Otherwise, read from the Register array
    assign RD1 = (A1 == 5'd0) ? 32'd0 : 
                 (WE3 && (A1 == A3)) ? WD3 : 
                 Register[A1];
                 
    assign RD2 = (A2 == 5'd0) ? 32'd0 : 
                 (WE3 && (A2 == A3)) ? WD3 : 
                 Register[A2];

    // Initialization - FIXED
    initial begin
        // Initialize ALL 32 registers to 0 to prevent "X" propagation
        for (i = 0; i < 32; i = i + 1) begin
            Register[i] = 32'h00000000;
        end //
    end

endmodule