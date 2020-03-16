// instruction opcode
`define OPCODE_ADDI 6'h8 // addi
`define OPCODE_ORI 6'hD // ori
`define OPCODE_LW 6'h23 // lw
`define OPCODE_LB 6'h20 // lb
`define OPCODE_LH 6'h21 // lh
`define OPCODE_LBU 6'h24 // lbu
`define OPCODE_LHU 6'h25 // lhu
`define OPCODE_SW 6'h2B // sw
`define OPCODE_SB 6'h28 //sb
`define OPCODE_SH 6'h29 //sh
`define OPCODE_BEQ 6'h4 // beq
`define OPCODE_BNE 6'h5 // bne
`define OPCODE_J 6'h2 // j
`define OPCODE_JAL 6'h3 // jal
`define OPCODE_R_JR_JALR 6'h0 // R-R instruction, jr, jalr
`define OPCODE_SLTI 6'hA // slti
`define OPCODE_ANDI 6'hC // andi
`define OPCODE_LUI 6'hF // lui

//instruction funct
`define FUNCT_ADD 6'h20 // add
`define FUNCT_SUB 6'h22 // sub
`define FUNCT_AND 6'h24 // and
`define FUNCT_OR 6'h25 // or
`define FUNCT_SLT 6'h2A // slt
`define FUNCT_SLTU 6'h2B // sltu
`define FUNCT_ADDU 6'h21 // addu
`define FUNCT_SUBU 6'h23 // subu
`define FUNCT_JR 6'h8 // jr
`define FUNCT_JALR 6'h9 // jalr
`define FUNCT_SLL 6'h0 // sll
`define FUNCT_SRL 6'h2 // srl
`define FUNCT_SRA 6'h3 // sra
`define FUNCT_SLLV 6'h4 // sllv
`define FUNCT_SRLV 6'h6 // srlv
`define FUNCT_SRAV 6'h7 // srav
`define FUNCT_XOR 6'h26 // xor
`define FUNCT_NOR 6'h27 // nor