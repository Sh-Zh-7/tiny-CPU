`include "../include/ctrl_encode_def.v"
`include "../include/instruction_def.v"

module Ctrl(
	input [5:0] OpCode,			//指令操作码字段
	input [5:0]	funct,			//指令功能字段
	//--------------------------------------------------------------------
	// 选择一个寄存器来存储最后的结果
	// 0: rt寄存器
	// 1: rd寄存器
	// 2：$31寄存器(jal专属)
	output reg[1:0] RegDst,
	
	// 最后结果的来源
	// 0: ALU计算的结果
	// 1: DM的dout
	// 2: PC+4(jal和jalr)
	output reg[1:0] RegSrc,
	
	//--------------------------------------------------------------------
	// Jump的类型
	// 0: 不跳转
	// 1: 使用imm26进行跳转
	// 2: 使用寄存器中的地址进行跳转
	output reg[1:0] Jump,
	
	// Branch的类型
	// 0: 不分支
	// 1: beq
	// 2：bne
	output reg[1:0] Branch,
	
	//----------------------------------------------------------------------
	// 就是ALU的不同种类的操作
	output reg[3:0] ALUOp,
	
	// 对应一个字节，半个字长和一个字长的内存操作
	output reg[1:0] MemOp,
	
	// 对应指令中内存数字的扩展形式
	// 0: 无符号扩展
	// 1: 有符号扩展
	output reg MemExt,
	
	// DataMem的写信号
	output reg MemWrite,
	
	// ALU运算对象的来源
	// 0: RD
	// 1: 5位的shamt
	output reg ALUSrcA,
	// 0: RD
	// 1: 经过扩展的Imm32
	output reg ALUSrcB,
	
	// 寄存器文件的写信号
	output reg RegWrite
);


always @(*)
begin 
	// RegDst
	if (
		(OpCode == `OPCODE_ADDI) ||
		(OpCode == `OPCODE_ORI)  ||
		(OpCode == `OPCODE_SLTI) ||
		(OpCode == `OPCODE_ANDI)	||
		(OpCode == `OPCODE_LUI)  ||
		(OpCode == `OPCODE_LW)	||
		(OpCode == `OPCODE_LB)	||
		(OpCode == `OPCODE_LH)	||
		(OpCode == `OPCODE_LBU)	||
		(OpCode == `OPCODE_LHU)
	) 
		RegDst = 0;
	else if (	
		(OpCode == 0 && funct == `FUNCT_ADD) ||
		(OpCode == 0 && funct == `FUNCT_SUB) ||
		(OpCode == 0 && funct == `FUNCT_AND) ||
		(OpCode == 0 && funct == `FUNCT_OR)  ||
		(OpCode == 0 && funct == `FUNCT_SLT) ||
		(OpCode == 0 && funct == `FUNCT_SLTU)||
		(OpCode == 0 && funct == `FUNCT_ADDU)||
		(OpCode == 0 && funct == `FUNCT_SUBU)||
		(OpCode == 0 && funct == `FUNCT_SLL) ||
		(OpCode == 0 && funct == `FUNCT_SRL) ||
		(OpCode == 0 && funct == `FUNCT_SRA) ||
		(OpCode == 0 && funct == `FUNCT_SLLV)||
		(OpCode == 0 && funct == `FUNCT_SRLV)||
		(OpCode == 0 && funct == `FUNCT_SRAV)||
		(OpCode == 0 && funct == `FUNCT_XOR) ||
		(OpCode == 0 && funct == `FUNCT_NOR)	||
		(OpCode == 0 && funct == `FUNCT_JALR)
	)
		RegDst = 1;
	else if (
		(OpCode == `OPCODE_JAL)
	)
		RegDst = 2;
		
	// RegSrc
	if (
		(OpCode == 0 && funct == `FUNCT_ADD) ||
		(OpCode == 0 && funct == `FUNCT_SUB) ||
		(OpCode == 0 && funct == `FUNCT_AND) ||
		(OpCode == 0 && funct == `FUNCT_OR)	||
		(OpCode == 0 && funct == `FUNCT_SLT) ||
		(OpCode == 0 && funct == `FUNCT_SLTU)||
		(OpCode == 0 && funct == `FUNCT_ADDU)||
		(OpCode == 0 && funct == `FUNCT_SUBU)||
		(OpCode == 0 && funct == `FUNCT_SLL) ||
		(OpCode == 0 && funct == `FUNCT_SRL) ||
		(OpCode == 0 && funct == `FUNCT_SRA) ||
		(OpCode == 0 && funct == `FUNCT_SLLV)||
		(OpCode == 0 && funct == `FUNCT_SRLV)||
		(OpCode == 0 && funct == `FUNCT_SRAV)||
		(OpCode == 0 && funct == `FUNCT_XOR) ||
		(OpCode == 0 && funct == `FUNCT_NOR) ||
		(OpCode == `OPCODE_ADDI)				||
		(OpCode == `OPCODE_ORI)				||
		(OpCode == `OPCODE_SLTI)				||
		(OpCode == `OPCODE_ANDI)				||
		(OpCode == `OPCODE_LUI)
	)
		RegSrc = 0;
	else if (
		(OpCode == `OPCODE_LW) ||
		(OpCode == `OPCODE_LB) ||
		(OpCode == `OPCODE_LH) ||
		(OpCode == `OPCODE_LBU)||
		(OpCode == `OPCODE_LHU)
	)
		RegSrc = 1;
	else if (
		(OpCode == `OPCODE_JAL) ||
		(OpCode == 0 && funct == `FUNCT_JALR)
	)
		RegSrc = 2;
	
	
	// Branch
	if (
		(OpCode == `OPCODE_BEQ)
	)
		Branch = 1;
	else if (
		(OpCode == `OPCODE_BNE)
	)
		Branch = 2;
	else 
		Branch = 0;
	
	// Jump
	if (
		(OpCode == `OPCODE_J) ||
		(OpCode == `OPCODE_JAL)
	)
		Jump = 1;
	else if (
		(OpCode == 0 && funct == `FUNCT_JR) ||
		(OpCode == 0 && funct == `FUNCT_JALR)
	)
		Jump = 2;
	else 
		Jump = 0;
	
	
	
	// ----------------------------------------------
	// ALUOp	
	if (
		(OpCode == 0 && funct == `FUNCT_ADD) ||
		(OpCode == 0 && funct == `FUNCT_ADDU)||
		(OpCode == `OPCODE_ADDI)				||
		(OpCode == `OPCODE_LW)				||
		(OpCode == `OPCODE_LB)				||
		(OpCode == `OPCODE_LH)				||
		(OpCode == `OPCODE_LBU)				||
		(OpCode == `OPCODE_LHU)				||
		(OpCode == `OPCODE_SW)				||
		(OpCode == `OPCODE_SB)				||
		(OpCode == `OPCODE_SH)
	)
		ALUOp = `ALU_ADD;
	else if (
		(OpCode == 0 && funct == `FUNCT_SUB) ||
		(OpCode == 0 && funct == `FUNCT_SUBU)||
		(OpCode == `OPCODE_BEQ)				||
		(OpCode == `OPCODE_BNE)
	)
		ALUOp = `ALU_SUB;
	else if (
		(OpCode == 0 && funct == `FUNCT_AND)||
		(OpCode == `OPCODE_ANDI)
	)
		ALUOp = `ALU_AND;
	else if (
		(OpCode == 0 && funct == `FUNCT_OR) ||
		(OpCode == `OPCODE_ORI)
	)
		ALUOp = `ALU_OR;
	else if (
		(OpCode == 0 && funct == `FUNCT_SLT)||
		(OpCode == `OPCODE_SLTI)
	)
		ALUOp = `ALU_SLT;
	else if (
		(OpCode == 0 && funct == `FUNCT_SLTU)
	)
		ALUOp = `ALU_SLTU;
	else if (
		(OpCode == 0 && funct == `FUNCT_SLL) ||
		(OpCode == 0 && funct == `FUNCT_SLLV)
	)
		ALUOp = `ALU_SLL;
	else if (
		(OpCode == 0 && funct == `FUNCT_SRL) ||
		(OpCode == 0 && funct == `FUNCT_SRLV)
	)
		ALUOp = `ALU_SRL;
	else if (
		(OpCode == 0 && funct == `FUNCT_SRA) ||
		(OpCode == 0 && funct == `FUNCT_SRAV)
	)
		ALUOp = `ALU_SRA;
	else if (
		(OpCode == 0 && funct == `FUNCT_XOR)
	)
		ALUOp = `ALU_XOR;
	else if (
		(OpCode == 0 && funct == `FUNCT_NOR)
	)
		ALUOp = `ALU_NOR;
	else if (
		(OpCode == `OPCODE_LUI)
	)
		ALUOp = `ALU_LUI;
		
	//---------------------------------------------
	// MemWrite
	if (
		(OpCode == `OPCODE_BEQ) ||
		(OpCode == `OPCODE_BNE)
	)
		MemWrite = 0;
	else if (
		(OpCode == `OPCODE_SW) ||
		(OpCode == `OPCODE_SB) ||
		(OpCode == `OPCODE_SH)
	)
		MemWrite = 1;
	else 
		MemWrite = 0;
	
	// MemOp
	if (
		(OpCode == `OPCODE_LW) ||
		(OpCode == `OPCODE_SW)
	)
		MemOp = `MEM_WORD;
	else if (
		(OpCode == `OPCODE_LB) ||
		(OpCode == `OPCODE_LBU)||
		(OpCode == `OPCODE_SB)
	)
		MemOp = `MEM_BYTE;
	else if (
		(OpCode == `OPCODE_LH) ||
		(OpCode == `OPCODE_LHU)||
		(OpCode == `OPCODE_SH)
	)
		MemOp = `MEM_HALF;
	
		
		
	// MemExt
	if ( 
		(OpCode == `OPCODE_LBU) ||
		(OpCode == `OPCODE_LHU)
	)
		MemExt = 0;
	else if (
		(OpCode == `OPCODE_LW) ||
		(OpCode == `OPCODE_LB) ||
		(OpCode == `OPCODE_LH)
	)
		MemExt = 1;
	else 
		MemExt = 0;
		
		
	// -----------------------------------------------------	
	// ALUSrcA
	if (
		(OpCode == 0 && funct == `FUNCT_ADD) ||
		(OpCode == 0 && funct == `FUNCT_SUB) ||
		(OpCode == 0 && funct == `FUNCT_AND) ||
		(OpCode == 0 && funct == `FUNCT_OR)  ||
		(OpCode == 0 && funct == `FUNCT_SLT) ||
		(OpCode == 0 && funct == `FUNCT_SLTU)||
		(OpCode == 0 && funct == `FUNCT_ADDU)||
		(OpCode == 0 && funct == `FUNCT_SUBU)||
		(OpCode == 0 && funct == `FUNCT_SLLV)||
		(OpCode == 0 && funct == `FUNCT_SRLV)||
		(OpCode == 0 && funct == `FUNCT_SRAV)||
		(OpCode == 0 && funct == `FUNCT_XOR) ||
		(OpCode == 0 && funct == `FUNCT_NOR) ||
		(OpCode == `OPCODE_ADDI)				||
		(OpCode == `OPCODE_ORI)				||
		(OpCode == `OPCODE_SLTI)				||
		(OpCode == `OPCODE_ANDI)				||
		(OpCode == `OPCODE_LUI)				||
		(OpCode == `OPCODE_LW)				||
		(OpCode == `OPCODE_LB)				||
		(OpCode == `OPCODE_LH)				||
		(OpCode == `OPCODE_LBU)				||
		(OpCode == `OPCODE_LHU)				||
		(OpCode == `OPCODE_SW)				||
		(OpCode == `OPCODE_SB)				||
		(OpCode == `OPCODE_SH)				||
		(OpCode == `OPCODE_BEQ)				||
		(OpCode == `OPCODE_BNE)
	)
		ALUSrcA = 0;
	else if (
		(OpCode == 0 && funct == `FUNCT_SLL) ||
		(OpCode == 0 && funct == `FUNCT_SRL) ||
		(OpCode == 0 && funct == `FUNCT_SRA)
	)
		ALUSrcA = 1;
		
	// ALUSrcB
	if (
		(OpCode == 0 && funct == `FUNCT_ADD) ||
		(OpCode == 0 && funct == `FUNCT_SUB) ||
		(OpCode == 0 && funct == `FUNCT_AND) ||
		(OpCode == 0 && funct == `FUNCT_OR)  ||
		(OpCode == 0 && funct == `FUNCT_SLT) ||
		(OpCode == 0 && funct == `FUNCT_SLTU)||
		(OpCode == 0 && funct == `FUNCT_ADDU)||
		(OpCode == 0 && funct == `FUNCT_SUBU)||
		(OpCode == 0 && funct == `FUNCT_SLL) ||
		(OpCode == 0 && funct == `FUNCT_SRL) ||
		(OpCode == 0 && funct == `FUNCT_SRA) ||
		(OpCode == 0 && funct == `FUNCT_SLLV)||
		(OpCode == 0 && funct == `FUNCT_SRLV)||
		(OpCode == 0 && funct == `FUNCT_SRAV)||
		(OpCode == 0 && funct == `FUNCT_XOR) ||
		(OpCode == 0 && funct == `FUNCT_NOR) ||
		(OpCode == `OPCODE_BEQ)				||
		(OpCode == `OPCODE_BNE)
	)
		ALUSrcB = 0;
	else if (
		(OpCode == `OPCODE_ADDI) ||
		(OpCode == `OPCODE_ORI)  ||
		(OpCode == `OPCODE_SLTI)	||
		(OpCode == `OPCODE_ANDI)	||
		(OpCode == `OPCODE_LUI)	||
		(OpCode == `OPCODE_LW)	||
		(OpCode == `OPCODE_LB)	||
		(OpCode == `OPCODE_LH)	||
		(OpCode == `OPCODE_LBU)	||
		(OpCode == `OPCODE_LHU)	||
		(OpCode == `OPCODE_SW)	||
		(OpCode == `OPCODE_SB)	||
		(OpCode == `OPCODE_SH)
	)
		ALUSrcB = 1;

	// RW
	if (	
		(OpCode == `OPCODE_SW) ||
		(OpCode == `OPCODE_SB) ||
		(OpCode == `OPCODE_SH) ||
		(OpCode == `OPCODE_BEQ)||
		(OpCode == `OPCODE_BNE)||
		(OpCode == `OPCODE_J)  ||
		(OpCode == 0 && funct == `FUNCT_JR)
	)
		RegWrite = 0;
	else if (
		(OpCode == 0 && funct == `FUNCT_ADD) ||
		(OpCode == 0 && funct == `FUNCT_SUB) ||
		(OpCode == 0 && funct == `FUNCT_AND) ||
		(OpCode == 0 && funct == `FUNCT_OR)  ||
		(OpCode == 0 && funct == `FUNCT_SLT) ||
		(OpCode == 0 && funct == `FUNCT_SLTU)||
		(OpCode == 0 && funct == `FUNCT_ADDU)||
		(OpCode == 0 && funct == `FUNCT_SUBU)||
		(OpCode == 0 && funct == `FUNCT_SLL) ||
		(OpCode == 0 && funct == `FUNCT_SRL) ||
		(OpCode == 0 && funct == `FUNCT_SRA) ||
		(OpCode == 0 && funct == `FUNCT_SLLV)||
		(OpCode == 0 && funct == `FUNCT_SRLV)||
		(OpCode == 0 && funct == `FUNCT_SRAV)||
		(OpCode == 0 && funct == `FUNCT_XOR) ||
		(OpCode == 0 && funct == `FUNCT_NOR) ||
		(OpCode == `OPCODE_ADDI)				||
		(OpCode == `OPCODE_ORI)				||
		(OpCode == `OPCODE_SLTI)				||
		(OpCode == `OPCODE_ANDI)				||
		(OpCode == `OPCODE_LUI)				||
		(OpCode == `OPCODE_LW)				||
		(OpCode == `OPCODE_LB)				||
		(OpCode == `OPCODE_LH)				||
		(OpCode == `OPCODE_LBU)				||
		(OpCode == `OPCODE_LHU)				||
		(OpCode == `OPCODE_JAL)				||
		(OpCode == 0 && funct == `FUNCT_JALR)
	)
		RegWrite = 1;

end
	
endmodule