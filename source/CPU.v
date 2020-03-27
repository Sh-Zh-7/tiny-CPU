`include "../include/ctrl_encode_def.v"
`include "../include/instruction_def.v"

module MIPS( clk, rst );
	// 时钟相关
	input clk;						
	input rst;						
   
	// 控制信号相关
	wire[1:0] RegDst;
  wire[1:0] Jump;				
  wire[1:0] Branch;			
  wire[1:0] RegSrc;		
  wire[3:0] ALUOp;  		
  wire[1:0] MemOp;			
  wire MemEXT;					
  wire MemWrite;				
  wire ALUSrcA;				  
  wire ALUSrcB;					
  wire RegWrite;				

  // 指令地址相关
	wire [31:0] PC;			
	wire [31:0] NPC;		
	wire [9:0] PCAddr;
	wire [1:0] NPCOp;
	assign PCAddr = PC[11:2];

	// 指令本体
	wire [31:0] AnInstruction;
	// 拆分指令
	wire [5:0] op;
	wire [5:0] funct;
	wire [4:0] rs;
	wire [4:0] rt;
	wire [4:0] rd;
	wire [4:0] shamt;
	wire [15:0] Imm16;
	wire [25:0] Imm26;
	assign op = AnInstruction[31:26];
	assign funct = AnInstruction[5:0];
	assign rs = AnInstruction[25:21];
	assign rt = AnInstruction[20:16];
	assign rd = AnInstruction[15:11];
	assign shamt = AnInstruction[10:6];
	assign Imm16 = AnInstruction[15:0];
	assign Imm26 = AnInstruction[25:0];

	// 从寄存器中读取的数据
	wire [31:0] register_data1;
	wire [31:0] register_data2;
	// 写回哪个寄存器和写回寄存器的数据
	wire [4:0] RF_back;
	wire [31:0] RF_write_data;

		// 符号扩展的结果
	wire [31:0] shamt32;
	wire [31:0] Imm32;

	// 最终参与ALU的两个操作数
	wire [31:0] op1, op2;
	// ALU相关
	wire Zero;  
	wire [31:0] ALUResult;

	// DM模块的输出
	wire [31:0] DMOut;
	
	//----------------------------------------------------------
	PC pc (.clk(clk), .rst(rst), .NPC(NPC), .PC(PC)); 
    
	IM im (.addr(PCAddr) , .dout(AnInstruction));
	
	CTRL ctrl(
		.OpCode(op),
		.funct(funct),
    .RegDst(RegDst), 
    .Jump(Jump), 
    .Branch(Branch), 
  	.RegSrc(RegSrc), 
    .ALUOp(ALUOp), 
    .MemOp(MemOp),
    .MemExt(MemEXT),
    .MemWrite(MemWrite),
    .ALUSrcA(ALUSrcA), 
    .ALUSrcB(ALUSrcB), 
    .RegWrite(RegWrite)
	);
	
	MUX4 #(5) selecet_write_register(
		.d0(rt), 
		.d1(rd),
		.d2(5'd31),
		.d3(5'bz),
    .s(RegDst),
  	.y(RF_back)
	);

	RF rf (
		.A1(rs), 
		.A2(rt), 
		.A3(RF_back),
		.WD(RF_write_data),
		.clk(clk), 
		.RFWr(RegWrite),
		.RD1(register_data1),
		.RD2(register_data2)
	);

	EXT_16_32 signed_ext (.in16(Imm16), .EXTOp(`EXT_SIGNED), .out32(Imm32));
	EXT_5_32 zero_ext (.in5(shamt), .EXTOp(`EXT_ZERO), .out32(shamt32));
	
	
	MUX2 #(32) select_operand1(
		.d0(register_data1),
		.d1(shamt32),
    .s(ALUSrcA),
    .y(op1)
	);
		
  MUX2 #(32) select_operand2(
		.d0(register_data2),
		.d1(Imm32), 
    .s(ALUSrcB),
    .y(op2)
	);  
	
	ALU alu (
		.A(op1), 
		.B(op2),
		.ALUOp(ALUOp), 
		.C(ALUResult),
		.Zero(Zero)
	);

	DM dm (
		.MemOp(MemOp),
		.MemEXT(MemEXT),
		.address(ALUResult), 
		.din(register_data2),
		.DMWr(MemWrite),
		.clk(clk), 
		.dout(DMOut)
	);
	
  MUX4 #(32) select_write_data(
		.d0(ALUResult),
		.d1(DMOut),
		.d2(PC + 32'd4),
		.d3(32'bz),
    .s(RegSrc),
  	.y(RF_write_data)
	);
	
	PCSrc pc_src(.Jump(Jump), .Branch(Branch), .Zero(Zero), .NPCOp(NPCOp));
	NPC npc(.PC(PC), .NPCOp(NPCOp), .IMM(Imm32), .addr(register_data1), .NPC(NPC));
endmodule