//for "extendedtest.asm"

//TEXT_BASE_ADDRESS 32'h0000_3000
//DATA_BASE_ADDRESS 32'h0000_0000

//lui ori subu addu add sub nor or and slt stlu addi
//sll srl sra sllv srlv srav
//sw sh sb
//lw lh lhu lb lbu

`timescale 1ns/1ns
module tb_extendedtest();
    reg clk, rst;

    mips cpu(.clk(clk), .rst(rst));
    integer i = 0;
    integer cnt = 0;

    initial
    begin
        //$readmemh("dat_extendedtest.txt", cpu.insMem.insMem);
        $readmemh("C:/Users/24312/Desktop/tiny-CPU/dat/extendedtest.dat", cpu.U_IM.imem);

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
			$display("");
            //$display("A = 0x%8h, B = 0x%8h", cpu.operand1, cpu.operand2);
            //$display("rfWriteData = %d, RegSrc = %d", cpu.rfWriteData, cpu.RegSrc);
            cnt = cnt + 1;
        end
        
        if(cnt == 45)
        begin
            printRegFile;
            printDataMem;
        end
    end

    task printRegFile;
        begin
            $display("R[00-07]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X", 0, cpu.U_RF.rf[1], cpu.U_RF.rf[2], cpu.U_RF.rf[3], cpu.U_RF.rf[4], cpu.U_RF.rf[5], cpu.U_RF.rf[6], cpu.U_RF.rf[7]);
            $display("R[08-15]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X", cpu.U_RF.rf[8], cpu.U_RF.rf[9], cpu.U_RF.rf[10], cpu.U_RF.rf[11], cpu.U_RF.rf[12], cpu.U_RF.rf[13], cpu.U_RF.rf[14], cpu.U_RF.rf[15]);
            $display("R[16-23]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X", cpu.U_RF.rf[16], cpu.U_RF.rf[17], cpu.U_RF.rf[18], cpu.U_RF.rf[19], cpu.U_RF.rf[20], cpu.U_RF.rf[21], cpu.U_RF.rf[22], cpu.U_RF.rf[23]);
            $display("R[24-31]=0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X, 0x%8X", cpu.U_RF.rf[24], cpu.U_RF.rf[25], cpu.U_RF.rf[26], cpu.U_RF.rf[27], cpu.U_RF.rf[28], cpu.U_RF.rf[29], cpu.U_RF.rf[30], cpu.U_RF.rf[31]);
        end
    endtask

    task printDataMem;
        begin
            $display("m[0] = 0x%8h", cpu.U_DM.dataMem[0/4]);
            $display("m[4] = 0x%8h", cpu.U_DM.dataMem[4/4]);
            $display("m[8] = 0x%8h", cpu.U_DM.dataMem[8/4]);
            $display("m[0xc] = 0x%8h", cpu.U_DM.dataMem[32'hc/4]);
            $display("m[0x10] = 0x%8h", cpu.U_DM.dataMem[32'h10/4]);
            $display("m[0x14] = 0x%8h", cpu.U_DM.dataMem[32'h14/4]);
            $display("m[0x18] = 0x%8h", cpu.U_DM.dataMem[32'h18/4]);
            $display("m[0x1c] = 0x%8h", cpu.U_DM.dataMem[32'h1c/4]);
            $display("m[0x20] = 0x%8h", cpu.U_DM.dataMem[32'h20/4]);
            $stop();
        end
    endtask
endmodule // tb_extendedtest