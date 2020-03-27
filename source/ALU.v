`include "../include/ctrl_encode_def.v"
module ALU (A, B, ALUOp, C, Zero);
           
   input [31:0] A, B;
   input [3:0] ALUOp;
   output reg[31:0] C;
   output Zero;
   
   // Convert to signed number
   wire signed [31:0] SignedA, SignedB;
   assign SignedA = A;
   assign SignedB = B;
   
       
   always @( A or B or ALUOp ) begin
      case (ALUOp)
          `ALU_NOP: C = A;                                        // nop
          `ALU_ADD: C = A + B;                                    // add
          `ALU_SUB: C = A - B;                                    // sub
          `ALU_AND: C = A & B;                                    // and/andi
          `ALU_OR: C = A | B;                                     // or/ori
          `ALU_SLT: C = (SignedA < SignedB);                     	// slt/sltu
          `ALU_SLTU:  C = ({1'b0, A} < {1'b0, B}) ? 32'd1 : 32'd0;// sltu
          `ALU_SLL: C = B << A[4:0];                              // sll/sllv
          `ALU_SRL: C = (B) >> A[4:0];                            // srl/srlv
          `ALU_SRA: C = ($signed(B)) >>> A[4:0];                  // sra/srav
          `ALU_XOR: C = A ^ B;                                    // xor
          `ALU_NOR: C = ~(A | B);                                 // nor
          `ALU_LUI: C = {B[15:0], 16'b0};                         // lui
          default: C = A;                                         // undefined
      endcase
	  $display("ALU: A=%8X B=%8X C=%8X ALUOp=%2b",A,B,C,ALUOp);
   end // end always;
   assign Zero = (C == 32'b0);

endmodule