`include "../include/ctrl_encode_def.v"
`include "../include/instruction_def.v"

module mips( clk, rst );

   // ʱ�����
   input   clk;
   input   rst;
   
   // �����ź����
	wire jump;						//ָ����ת
	wire RegDst;						
	wire Branch;					//��֧
	wire MemR;						//���洢��
	wire Mem2R;						//���ݴ洢�����Ĵ�����
	wire MemW;						//д���ݴ洢��
	wire RegW;						//�Ĵ�����д������
	wire AluSrc;					//������������ѡ��
	wire [1:0] NPCOp;				// NPCѡ��
	wire [1:0] ExtOp;				//λ��չ/������չѡ��
	wire [1:0] ALUOp;	   	   		//Alu����ѡ��

   // �����������
   wire zero;  
   wire [31:0] Alu_Result;

   // ָ���ַ���
	wire [31:0] PC;
	wire [31:0] NPC;
   wire [9:0] PCAddr;
   assign PCAddr = PC[11:2];
   assign PcSel = ( ( Branch && zero ) == 1 ) ? 1 : 0 ;

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
   assign Imm16 = AnInstruction[15:0];
   assign IMM = AnInstruction[25:0];

   // �Ĵ������
   wire [4:0] RF_rd;
   assign RF_rd = (RegDst === 0) ? rd : rt ;

   // ������չ���
   wire [31:0] Imm32;

   // �����ڴ����
   wire [31:0] DM_Out;
   wire [11:2] DM_Addr;
   assign DM_Addr = Alu_Result[11:2];

   // �Ĵ������
   wire [31:0] RD1;
   wire [31:0] RD2;
   wire [31:0] RF_WD;
   assign RF_WD = (Mem2R == 1) ? DM_Out : Alu_Result;

   // �����������
   wire [31:0] AluMux_Result;
   assign AluMux_Result = (AluSrc === 0) ? RD2 : Imm32;

   // ָ�������ģ��
   NPC U_NPC (.PC(PC), .NPCOp(NPCOp), .IMM(Imm32), .NPC(NPC))
   PC U_PC (.clk(clk), .rst(rst), .NPC(NPC), .PC(PC)); 
   
   
   // ָ��ģ��
   im_4k U_IM (.addr(PCAddr) , .dout(AnInstruction));

   // �Ĵ���ģ��   
   RF U_RF (
      .A1(rs), .A2(rt), .A3(RF_rd), .WD(RF_WD), .clk(clk), 
      .RFWr(RegW), .RD1(RD1), .RD2(RD2)
   );

   // ������չģ��
   EXT U_SIGNEDEXT (.Imm16(Imm16), .EXTOp(ExtOp), .Imm32(Imm32));

   // ��������ģ��
   alu U_ALU (
      .A(RD1), .B(AluMux_Result), .ALUOp(ALUOp), .C(Alu_Result), .Zero(zero)
   );

   // �����ڴ�ģ��
   dm_4k U_DM (
      .addr(DM_Addr), .din(RD2), .DMWr(MemW), .clk(clk), .dout(DM_Out), .rst(rst)
   );

   // �źſ���ģ��
   Ctrl U_Ctrl(
      .jump(jump),
      .RegDst(RegDst),
      .Branch(Branch),
      .MemR(MemR),
      .Mem2R(Mem2R),
      .MemW(MemW),
      .RegW(RegW),
      .Alusrc(AluSrc),
      .ExtOp(ExtOp),
      .Aluctrl(ALUOp),
      .OpCode(Op),
      .funct(Funct)
   );

endmodule