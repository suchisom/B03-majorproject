`timescale 1ns / 1ps

module pipeline_tb;

    reg clk, rst;

    // Instantiate the CPU exactly as defined in Pipeline_Top.v [cite: 25]
    Pipeline_top dut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    // --- STRICT SPY MODE: ALIGNED TO PIPELINE_TOP.V ---
    always @(posedge clk) begin
        if (rst) begin
            // 1. Monitor Register Writes (WB Stage)
            // Uses RegWriteW [cite: 25], RDW [cite: 26], ResultW [cite: 26], and PCPlus4W [cite: 27]
            if (dut.RegWriteW && dut.RDW != 0) begin
                $display("Time: %5t | [WB]  PC: %h | Reg x%0d <- %d (0x%h)", 
                         $time, dut.PCPlus4W - 4, dut.RDW, dut.ResultW, dut.ResultW);
            end

            // 2. Monitor Memory Writes / Stores (MEM Stage)
            // Uses MemWriteM [cite: 25], ALU_ResultM [cite: 26], and WriteDataM [cite: 26]
            if (dut.MemWriteM) begin
                $display("Time: %5t | [MEM] STORE  | Addr: 0x%h | Data: %d", 
                         $time, dut.ALU_ResultM, dut.WriteDataM);
                
                // End of test condition
                if (dut.ALU_ResultM === 32'h100) begin
                    $display("------------------------------------------------");
                    if (dut.WriteDataM === 32'd1) 
                        $display(" *** SUCCESS: All tests passed! Wrote 1 to 0x100 ***");
                    else 
                        $display(" *** FAILURE: Wrote %d to 0x100 ***", dut.WriteDataM);
                    $display("------------------------------------------------");
                    $finish;
                end
            end

            // 3. Monitor Control Flow / Branches & Jumps (EX Stage)
            // Uses PCSrcE [cite: 25] and PCTargetE [cite: 26]
            if (dut.PCSrcE) begin
                 $display("Time: %5t | [EX]  BRANCH/JUMP TAKEN | Target PC: %h", 
                          $time, dut.PCTargetE);
            end
        end
    end

    initial begin
        $dumpfile("riscv_core.vcd");
        $dumpvars(0, pipeline_tb);

        clk = 0;
        rst = 0; 
        
        #20 rst = 1; // Release Reset
        
        #50000;
        $display("------------------------------------------------");
        $display("TIMEOUT: CPU stuck in loop or too slow.");
        $display("------------------------------------------------");
        $finish;
    end

endmodule