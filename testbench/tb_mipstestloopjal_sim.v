//for "mipstestloopjal_sim.asm"

//TEXT_BASE_ADDRESS 32'h0000_3000
//DATA_BASE_ADDRESS 32'h0000_0000

//add, sub, and, or, slt, addi, lw, sw, beq, j, jal

`timescale 1ns/1ns
module tb_mipstestloopjal_sim();
    reg clk, rst;

    MIPS cpu(.clk(clk), .rst(rst));
    integer i = 0;
    integer cnt = 0;

    initial
    begin
        $readmemh("C:/Users/24312/Desktop/tiny-CPU/dat/mipstestloopjal_sim.dat", cpu.im.instruction_memory);
    end

    initial
        clk = 0;

    initial
    begin
        rst = 0;
        #5
        rst = 1;
        #5
        rst = 0;
    end

    always
    begin
        #5 clk = ~clk;
        if (clk)
        begin
            $display("PC = 0x%8h, instruction = 0x%8h", cpu.PC, cpu.AnInstruction);
			$display("");
            cnt = cnt + 1;
        end
        
        if(cnt == 30)
        begin
            printregFile;
            $display("m[0x%2X] = %d", 80, cpu.dm.dataMem[80/4]);
            $display("m[0x%2X] = %d", 84, cpu.dm.dataMem[84/4]);
            $stop();
        end
    end

    task printregFile;
        begin
            $display("R[00-07]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X", 0, cpu.rf.rf[1], cpu.rf.rf[2], cpu.rf.rf[3], cpu.rf.rf[4], cpu.rf.rf[5], cpu.rf.rf[6], cpu.rf.rf[7]);
            $display("R[08-15]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X", cpu.rf.rf[8], cpu.rf.rf[9], cpu.rf.rf[10], cpu.rf.rf[11], cpu.rf.rf[12], cpu.rf.rf[13], cpu.rf.rf[14], cpu.rf.rf[15]);
            $display("R[16-23]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X", cpu.rf.rf[16], cpu.rf.rf[17], cpu.rf.rf[18], cpu.rf.rf[19], cpu.rf.rf[20], cpu.rf.rf[21], cpu.rf.rf[22], cpu.rf.rf[23]);
            $display("R[24-31]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X", cpu.rf.rf[24], cpu.rf.rf[25], cpu.rf.rf[26], cpu.rf.rf[27], cpu.rf.rf[28], cpu.rf.rf[29], cpu.rf.rf[30], cpu.rf.rf[31]);
        end
    endtask
endmodule // tb_mipstestloopjal_sim