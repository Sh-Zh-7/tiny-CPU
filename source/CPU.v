`include "../include/ctrl_encode_def.v"
`include "../include/instruction_def.v"

// NPC�����ã��ѵ�ǰָ��͸�PC
module mips( clk, rst );
	// ʱ�����
	input   clk;						// ʱ���ź�
	input   rst;						// ��λ�ź�
   
	// �����ź����
	wire[1:0] RegDst;
    wire[1:0] Jump;						// ��ת������
    wire[1:0] Branch;					// ��֧������
    wire[1:0] RegSrc;					// ���������Դ
    wire[3:0] ALUOp;  					// ALU����ѡ��
    wire[1:0] MemOp;					// �ڴ������
    wire MemEXT;						// �����ڴ���չ����
    wire MemWrite;						// �����ڴ�д�ź�
    wire ALUSrcA;						// ALU������1
    wire ALUSrcB;						// ALU������2
    wire RegWrite;						// RF��д�ź�

	// �����������
	wire zero;  
	wire [31:0] Alu_Result;

   // ָ���ַ���
	wire [31:0] PC;						// ��ǰָ��ĵ�ַ
	wire [31:0] NPC;					// ��һ��ָ���
	wire [9:0] PCAddr;
	wire [1:0] NPCOp;
	assign PCAddr = PC[11:2];

	// ָ���
	wire [31:0] AnInstruction;
	// ���ָ��
	wire [5:0] Op;
	wire [5:0] Funct;
	wire [4:0] rs;
	wire [4:0] rt;
	wire [4:0] rd;
	wire [15:0] Imm16;
	wire [25:0] IMM;
	assign Op = AnInstruction[31:26];
	assign Funct = AnInstruction[5:0];
	assign rs = AnInstruction[25:21];
	assign rt = AnInstruction[20:16];
	assign rd = AnInstruction[15:11];
	assign shamt = AnInstruction[10:6];
	assign Imm16 = AnInstruction[15:0];
	assign IMM = AnInstruction[25:0];

	// �Ĵ������
	wire [4:0] RF_rd;

	// ������չ���
	wire [31:0] shamt32;
	wire [31:0] Imm32;

	// �����ڴ����
	wire [31:0] DM_Out;
	wire [11:2] DM_Addr;
	assign DM_Addr = Alu_Result[11:2];

	// �Ĵ������
	wire [31:0] RD1;
	wire [31:0] RD2;
	wire [31:0] RF_WD;
	// ��Щ�����mux��ѡ��
	// assign RF_WD = (Mem2Reg == 1) ? DM_Out : Alu_Result;

	// �����������
	wire [31:0] op1, op2;
	wire [31:0] AluMux_Result;
	// ��Щ�����mux��ѡ��
	// assign AluMux_Result = (AluSrc == 0) ? RD2 : Imm32;

	
	//----------------------------------------------------------
	// ָ�������ģ��
	PC U_PC (.clk(clk), .rst(rst), .NPC(NPC), .PC(PC)); 
    
	// ָ��ģ��
	im_4k U_IM (.addr(PCAddr) , .dout(AnInstruction));
	
		// �źſ���ģ��
	Ctrl U_Ctrl(
		.OpCode(Op),
		.funct(Funct),
        .RegDst(RegDst), 
        .Jump(Jump), 
        .Branch(Branch), 
        .RegSrc(RegSrc), 
        .ALUOp(ALUOp), 
        .MemOp(MemOp),
        .MemEXT(MemEXT),
        .MemWrite(MemWrite),
        .ALUSrcA(ALUSrcA), 
        .ALUSrcB(ALUSrcB), 
        .RegWrite(RegWrite)
	);
	
	mux4 #(5) SelWriteReg(
		.d0(rt), 
		.d1(rd),
		.d2(5'd31),
		.d3(5'bz),
        .s(RegDst),
        .y(RF_rd)
	);

	// �Ĵ���ģ��   
	RF U_RF (
		.A1(rs), .A2(rt), .A3(RF_rd), .WD(RF_WD), .clk(clk), 
		.RFWr(RegWrite), .RD1(RD1), .RD2(RD2)
	);

	// ������չģ��
	EXT_16_32 U_SIGNEDEXT1 (.Imm16(Imm16), .EXTOp(`EXT_SIGNED), .Imm32(Imm32));
	EXT_5_32 U_SIGNEDEXT2 (.shamt(shamt), .EXTOp(`EXT_ZERO), .out32(shamt32));
	
	
	mux2 #(32) SelOperand1(
		.d0(RD1),
		.d1(shamt32),
        .s(ALUSrcA),
        .y(op1)
	);
		
    mux2 #(32) SelOperand2(
		.d0(RD2),
		.d1(imm32), 
        .s(ALUSrcB),
        .y(op2)
	);  
	
	// ��������ģ��
	alu U_ALU (
		.A(RD1), 
		.B(AluMux_Result),
		.ALUOp(ALUOp), 
		.C(Alu_Result),
		.Zero(zero)
	);

	// �����ڴ�ģ��
	DataMem U_DM (
		.MemOp(MemOp),
		.MemEXT(MemEXT),
		.address(DM_Addr), 
		.din(RD2),
		.DMWr(MemWrite),
		.clk(clk), 
		.dout(DM_Out)
	);
	
	
    mux4 #(32) selRFWriteData(
		.d0(Alu_Result),
		.d1(DM_Out),
		// ���ﻹ��һ������
		.d2(PC + 32'd4),
		.d3(32'bz),
        .s(RegSrc),
        .y(RF_WD)
	);
	
	// ȷ����һ��ָ��ĵ�ַ
	PCSrc U_PCSrc(.Jump(Jump), .Branch(Branch), .Zero(Zero), .NPCOp(NPCOp));
	NPC U_NPC (.PC(PC), .NPCOp(NPCOp), .IMM(Imm32), .addr(RD1), .NPC(NPC));

endmodule