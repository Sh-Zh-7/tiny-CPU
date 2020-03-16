`include "../include/ctrl_encode_def.v"
`include "../include/instruction_def.v"

// NPC的作用：把当前指令传送给PC
module mips( clk, rst );
	// 时钟相关
	input   clk;						// 时钟信号
	input   rst;						// 复位信号
   
	// 控制信号相关
	wire[1:0] RegDst;
    wire[1:0] Jump;						// 跳转的种类
    wire[1:0] Branch;					// 分支的种类
    wire[1:0] RegSrc;					// 最后结果的来源
    wire[3:0] ALUOp;  					// ALU运算选择
    wire[1:0] MemOp;					// 内存操作符
    wire MemEXT;						// 数据内存扩展种类
    wire MemWrite;						// 数据内存写信号
    wire ALUSrcA;						// ALU操作数1
    wire ALUSrcB;						// ALU操作数2
    wire RegWrite;						// RF的写信号

	// 算数运算相关
	wire zero;  
	wire [31:0] Alu_Result;

   // 指令地址相关
	wire [31:0] PC;						// 当前指令的地址
	wire [31:0] NPC;					// 下一条指令的
	wire [9:0] PCAddr;
	wire [1:0] NPCOp;
	assign PCAddr = PC[11:2];

	// 指令本体
	wire [31:0] AnInstruction;
	// 拆分指令
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

	// 寄存器相关
	wire [4:0] RF_rd;

	// 符号扩展相关
	wire [31:0] shamt32;
	wire [31:0] Imm32;

	// 数据内存相关
	wire [31:0] DM_Out;
	wire [11:2] DM_Addr;
	assign DM_Addr = Alu_Result[11:2];

	// 寄存器相关
	wire [31:0] RD1;
	wire [31:0] RD2;
	wire [31:0] RF_WD;
	// 这些最后都有mux来选择
	// assign RF_WD = (Mem2Reg == 1) ? DM_Out : Alu_Result;

	// 算数运算相关
	wire [31:0] op1, op2;
	wire [31:0] AluMux_Result;
	// 这些最后都有mux来选择
	// assign AluMux_Result = (AluSrc == 0) ? RD2 : Imm32;

	
	//----------------------------------------------------------
	// 指令计数器模块
	PC U_PC (.clk(clk), .rst(rst), .NPC(NPC), .PC(PC)); 
    
	// 指令模块
	im_4k U_IM (.addr(PCAddr) , .dout(AnInstruction));
	
		// 信号控制模块
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

	// 寄存器模块   
	RF U_RF (
		.A1(rs), .A2(rt), .A3(RF_rd), .WD(RF_WD), .clk(clk), 
		.RFWr(RegWrite), .RD1(RD1), .RD2(RD2)
	);

	// 符号扩展模块
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
	
	// 算术运算模块
	alu U_ALU (
		.A(RD1), 
		.B(AluMux_Result),
		.ALUOp(ALUOp), 
		.C(Alu_Result),
		.Zero(zero)
	);

	// 数据内存模块
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
		// 这里还有一点疑问
		.d2(PC + 32'd4),
		.d3(32'bz),
        .s(RegSrc),
        .y(RF_WD)
	);
	
	// 确定下一个指令的地址
	PCSrc U_PCSrc(.Jump(Jump), .Branch(Branch), .Zero(Zero), .NPCOp(NPCOp));
	NPC U_NPC (.PC(PC), .NPCOp(NPCOp), .IMM(Imm32), .addr(RD1), .NPC(NPC));

endmodule