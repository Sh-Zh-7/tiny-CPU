module Ctrl(jump,RegDst,Branch,Mem2R,MemW,RegW,Alusrc,ExtOp,Aluctrl,OpCode,funct);
	
	input [5:0]		OpCode;				//ָ��������ֶ�
	input [5:0]		funct;				//ָ����ֶ�

	output jump;						//ָ����ת
	output RegDst;						
	output Branch;						//��֧
	// output MemR;						//���洢��
	output Mem2R;						//���ݴ洢�����Ĵ�����
	output MemW;						//д���ݴ洢��
	output RegW;						//�Ĵ�����д������
	output Alusrc;						//������������ѡ��
	output [1:0] ExtOp;						//λ��չ/������չѡ��
	output reg[1:0] Aluctrl;						//Alu����ѡ��
	
	
	assign jump = 1;
	assign RegDst = OpCode[0];
	assign Branch = !(OpCode[0]||OpCode[1])&&OpCode[2];
	// assign MemR = (OpCode[0]&&OpCode[1]&&OpCode[5])&&(!OpCode[3]);
	assign Mem2R = (OpCode[0]&&OpCode[1]&&OpCode[5])&&(!OpCode[3]);
	assign MemW = OpCode[1]&&OpCode[0]&&OpCode[3]&&OpCode[5];
	assign RegW = (OpCode[2]&&OpCode[3])||(!OpCode[2]&&!OpCode[3]);
	assign Alusrc = OpCode[0]||OpCode[1];
	assign ExtOp = {1'b0, !(OpCode[2]&&OpCode[3])};//�޸���չ�ź�
	
	
	always@(OpCode or funct)
	begin
		Aluctrl[1] = ExtOp[0];
		if((OpCode[1]||OpCode[2]) == 0)
			Aluctrl[0] = funct[1];
		else
			Aluctrl[0] = !(OpCode[1]||OpCode[0]);
	end
endmodule