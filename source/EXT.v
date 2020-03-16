`include "../include/ctrl_encode_def.v"

module EXT_16_32(Imm16, EXTOp, Imm32);
	input [15:0]  Imm16;
	input EXTOp;
	output [31:0] Imm32;
	
	assign Imm32 = (EXTOp == `EXT_SIGNED)?
					{{16{Imm16[15]}}, Imm16} :
					{16'd0, Imm16};
endmodule


// 把5位的shamt转化为32位的
module EXT_5_32(shamt, EXTOp, out32);
    
   input [4:0] shamt;//5bit shamt
   input EXTOp;//0: zero extension; 1: signed-extension
   output [31:0] out32;//32bit operand for ALU
   
   assign out32 = (EXTOp == `EXT_SIGNED) 
                ? {{27{shamt[4]}}, shamt} //signed-extension
                : {27'd0, shamt}; //zero extension
       
endmodule

module EXT_8_32(in8, EXTOp, out32 );
    
   input[7:0] in8;
   input EXTOp;//0: zero extension; 1: signed-extension
   output[31:0] out32;
   
   assign out32 = (EXTOp == `EXT_SIGNED) 
                  ? {{24{in8[7]}}, in8} //signed-extension
                  : {24'd0, in8}; //zero extension
       
endmodule