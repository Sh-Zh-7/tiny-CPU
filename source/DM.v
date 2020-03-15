module dm_4k( addr, din, DMWr, clk, dout,rst );
   
   input  [9:0] addr;//��ַ
   input  [31:0] din;//���������
   input         DMWr;//дʹ�ܶ�
   input         rst;//�����
   input         clk;//ʱ��
   output [31:0] dout;//���������
     
   reg [31:0] dmem[1023:0];//�洢����
   integer i;
   always @(posedge clk or posedge rst)
		begin
			if (rst)
				begin   
					for (i=0;i<1024;i=i+1)
						dmem[i] <= 32'h0000_0000;
				end
			if (DMWr)
				dmem[addr] <= din;
 // end always
			$display("addr=%8X din=%8X",addr,din);//addr and data to DM
			$display("Mem[00-07]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X",dmem[0],dmem[1],dmem[2],dmem[3],dmem[4],dmem[5],dmem[6],dmem[7]);
		end
	assign dout = dmem[addr];
endmodule    