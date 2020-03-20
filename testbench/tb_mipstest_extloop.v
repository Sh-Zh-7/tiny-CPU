//for "mipstest_extloop.asm"

//TEXT_BASE_ADDRESS 32'h0000_3000
//DATA_BASE_ADDRESS 32'h0000_0000

//add sub and or slt addi lw sw beq j

`timescale 1ns/1ns
module tb_mipstest_extloop();
    reg clk, rst;

    mips cpu(.clk(clk), .rst(rst));
    integer i = 0;
    integer cnt = 0;

    initial
    begin
        //$readmemh("dat_mipstestloopjal_sim.txt", cpu.insMem.insMem);
        $readmemh("C:/Users/24312/Desktop/tiny-CPU/dat/mipstest_extloop.dat", cpu.U_IM.imem);

        //$monitor("PC = 0x%8h, instruction = 0x%8h", cpu.PC, cpu.inst);
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
			$display("shamt = 0x%8h, shamt32 = 0x%8h", cpu.shamt, cpu.shamt32);
			$display("");
            //$display("rfWriteData = %d, RegSrc = %d", cpu.rfWriteData, cpu.RegSrc);
            cnt = cnt + 1;
        end
        
        if(cnt == 40)
        begin
            printregFile;
            $display("m[0x%2X] = %d", 80, cpu.U_DM.dataMem[80/4]);
            $display("m[0x%2X] = %d", 84, cpu.U_DM.dataMem[84/4]);
            $stop();
        end
    end

    task printregFile;
        begin
            $display("R[00-07]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X", 0, cpu.U_RF.rf[1], cpu.U_RF.rf[2], cpu.U_RF.rf[3], cpu.U_RF.rf[4], cpu.U_RF.rf[5], cpu.U_RF.rf[6], cpu.U_RF.rf[7]);
            $display("R[08-15]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X", cpu.U_RF.rf[8], cpu.U_RF.rf[9], cpu.U_RF.rf[10], cpu.U_RF.rf[11], cpu.U_RF.rf[12], cpu.U_RF.rf[13], cpu.U_RF.rf[14], cpu.U_RF.rf[15]);
            $display("R[16-23]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X", cpu.U_RF.rf[16], cpu.U_RF.rf[17], cpu.U_RF.rf[18], cpu.U_RF.rf[19], cpu.U_RF.rf[20], cpu.U_RF.rf[21], cpu.U_RF.rf[22], cpu.U_RF.rf[23]);
            $display("R[24-31]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X", cpu.U_RF.rf[24], cpu.U_RF.rf[25], cpu.U_RF.rf[26], cpu.U_RF.rf[27], cpu.U_RF.rf[28], cpu.U_RF.rf[29], cpu.U_RF.rf[30], cpu.U_RF.rf[31]);
        end
    endtask
endmodule // tb_mipstest_extloop