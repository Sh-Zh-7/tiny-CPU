`include "../include/ctrl_encode_def.v"

// 把5位数根据EXTOp转成32位数
// 这个专门用于shamt
module EXT_5_32(in5, EXTOp, out32);
   input [4:0] in5;
   input EXTOp;        
   output [31:0] out32;
   
   assign out32 = (EXTOp == `EXT_SIGNED)? {{27{in5[4]}}, in5} : {27'd0, in5}; 
endmodule

// 把8位数根据EXTOp转成32位数
module EXT_8_32(in8, EXTOp, out32 );
   input[7:0] in8;
   input EXTOp;
   output[31:0] out32;
   
   assign out32 = (EXTOp == `EXT_SIGNED)? {{24{in8[7]}}, in8} : {24'd0, in8};   
endmodule

// 把16位数根据EXTOp转成32位数
// 这个专门用于RI指令中的imm
module EXT_16_32(in16, EXTOp, out32);
	input [15:0]  in16;
	input EXTOp;
	output [31:0] out32;
	
	assign out32 = (EXTOp == `EXT_SIGNED)? {{16{in16[15]}}, in16} : {16'd0, in16};
endmodule
