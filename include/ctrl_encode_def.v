// Base address settings
`define TEXT_BASE_ADDRESS 32'h0000_3000 //text base address 32'h0000_0000 32'h0000_3000
`define DATA_BASE_ADDRESS 32'h0000_0000 //data base address 32'h0000_2000 32'h0000_0000

// NPC control signal(NPCOp)
`define NPC_PLUS4 2'b00
`define NPC_BRANCH 2'b01
`define NPC_JUMP_IMM 2'b10
`define NPC_JUMP_REG 2'b11

// ALU control signal(ALUOp)
`define ALU_NOP 4'd0 
`define ALU_ADD 4'd1
`define ALU_SUB 4'd2 
`define ALU_AND 4'd3
`define ALU_OR 4'd4
`define ALU_SLT 4'd5
`define ALU_SLTU 4'd6
`define ALU_SLL 4'd7
`define ALU_SRL 4'd8
`define ALU_SRA 4'd9
`define ALU_XOR 4'd10
`define ALU_NOR 4'd11
`define ALU_LUI 4'd12

// EXTOp
`define EXT_ZERO 1'b0
`define EXT_SIGNED 1'b1

//MemOp
`define MEM_BYTE 2'd0
`define MEM_HALF 2'd1
`define MEM_WORD 2'd2
