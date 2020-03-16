`include "../include/ctrl_encode_def.v"
module alu (A, B, ALUOp, C, Zero);
           
   input  [31:0] A, B;
   input  [3:0]  ALUOp;
   output reg[31:0] C;
   output        Zero;
   
       
   always @( A or B or ALUOp ) begin
      case (ALUOp)
          `ALU_NOP: C = A;// NOP
          `ALU_ADD: C = A + B;// ADD
          `ALU_SUB: C = A - B;// SUB
          `ALU_AND: C = A & B;// AND/ANDI
          `ALU_OR: C = A | B;// OR/ORI
          `ALU_SLT: C = (A < B) ? 32'd1 : 32'd0;// SLT/SLTI
          `ALU_SLTU: C = ({1'b0, A} < {1'b0, B}) ? 32'd1 : 32'd0;// SLTU
          `ALU_SLL: C = B << A[4:0];// SLL/SLLV
          `ALU_SRL: C = B >> A[4:0];// SRL/SRLV
          `ALU_SRA: C = B >>> A[4:0];// SRA/SRAV
          `ALU_XOR: C = A ^ B;// XOR
          `ALU_NOR: C = ~(A | B);// NOR
          `ALU_LUI: C = {B[15:0], 16'b0};// LUI
          default: C = A;// Undefined
      endcase
	  $display("ALU: A=%8X B=%8X C=%8X ALUOp=%2b",A,B,C,ALUOp);
   end // end always;
   
   assign Zero = (C == 32'b0);

endmodule