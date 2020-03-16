`include "../include/ctrl_encode_def.v"
`include "../include/instruction_def.v"

module Ctrl(
	input [5:0] OpCode,			//ָ��������ֶ�
	input [5:0]	funct,			//ָ����ֶ�
	//--------------------------------------------------------------------
	// ѡ��һ���Ĵ������洢���Ľ��
	// 0: rt�Ĵ���
	// 1: rd�Ĵ���
	// 2��$31�Ĵ���(jalר��)
	output reg[1:0] RegDst,
	
	// ���������Դ
	// 0: ALU����Ľ��
	// 1: DM��dout
	// 2: PC+4(jal��jalr)
	output reg[1:0] RegSrc,
	
	//--------------------------------------------------------------------
	// Jump������
	// 0: ����ת
	// 1: ʹ��imm26������ת
	// 2: ʹ�üĴ����еĵ�ַ������ת
	output reg[1:0] Jump,
	
	// Branch������
	// 0: ����֧
	// 1: beq
	// 2��bne
	output reg[1:0] Branch,
	
	//----------------------------------------------------------------------
	// ����ALU�Ĳ�ͬ����Ĳ���
	output reg[3:0] ALUOp,
	
	// ��Ӧһ���ֽڣ�����ֳ���һ���ֳ����ڴ����
	output reg[1:0] MemOp,
	
	// ��Ӧָ�����ڴ����ֵ���չ��ʽ
	// 0: �޷�����չ
	// 1: �з�����չ
	output reg MemExt,
	
	// DataMem��д�ź�
	output reg MemWrite,
	
	// ALU����������Դ
	// 0: RD
	// 1: 5λ��shamt
	output reg ALUSrcA,
	// 0: RD
	// 1: ������չ��Imm32
	output reg ALUSrcB,
	
	// �Ĵ����ļ���д�ź�
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