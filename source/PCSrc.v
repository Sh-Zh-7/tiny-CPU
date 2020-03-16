`include "../include/ctrl_encode_def.v"
// 生成NPCOp的信号
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

endmodule // PCSrc