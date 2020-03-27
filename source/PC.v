`include "../include/ctrl_encode_def.v"

module PC(clk, rst, NPC, PC);
  input              clk;
  input              rst;
  input       [31:0] NPC;
  output reg  [31:0] PC;

  always @(posedge clk, posedge rst)
    if (rst) 
      PC <= 32'h0000_0000;
      //PC <= 32'h0000_3000;
    else
      PC <= NPC;   
endmodule

module PCSrc(Jump, Branch, Zero, NPCOp);
    input[1:0] Jump;
    input[1:0] Branch;
    input Zero;
    output reg[1:0] NPCOp;
    always @(*) 
    begin
        if (Jump == 2'd1) 
            NPCOp = `NPC_JUMP_IMM;
        else if (Jump == 2'd2)
            NPCOp = `NPC_JUMP_REG;
        else if (Branch == 2'd1 && Zero || Branch == 2'd2 && !Zero) 
            NPCOp = `NPC_BRANCH;
        else
            NPCOp = `NPC_PLUS4;
    end
endmodule 

module NPC(PC, NPCOp, IMM, addr, NPC);  
   input  [31:0] PC;        
   input  [1:0]  NPCOp;     
   input  [31:0] IMM;       
   input  [31:0] addr;
   output reg [31:0] NPC;   
   
   wire [31:0] PCPLUS4;
   
   assign PCPLUS4 = PC + 4; 
   
   always @(*) begin
      case (NPCOp)
		   `NPC_PLUS4:  NPC = PCPLUS4;
		   // Branch专属
		   // PC+4+sign_extend(offset||0^2)
		   `NPC_BRANCH: NPC = PCPLUS4 + {{14{IMM[15]}}, IMM[15:0], 2'b00};
		   // Jump到立即数
		   // PC的高四位，立即数左移两位拼接
		   `NPC_JUMP_IMM:   NPC = {PCPLUS4[31:28], IMM[25:0], 2'b00};
		   // Jump到寄存器中的地址
		   `NPC_JUMP_REG:   NPC = addr;
         default:     NPC = PCPLUS4;
      endcase
   end
endmodule

