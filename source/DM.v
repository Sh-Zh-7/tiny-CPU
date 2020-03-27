`include "../include/ctrl_encode_def.v"
//Data Memory
module DM(clk, DMWr, MemOp, MemEXT, address, din, dout);
    input clk;//clock signal
    input DMWr;//write signal; 1: write, 0: read only
    input[1:0] MemOp;//byte, half or word
    input MemEXT;//0: zero-extenstion, 1: signed-extension
    input[31:0] address;//read/write address, //only use 10bit address
    input[31:0] din;//write data input
    output reg[31:0] dout;//read data output


	// ���������������1024��32λ��һ���ֳ����Ĵ���ģ���ڴ�
    reg [31:0] dataMem [1023:0];
    wire[31:0] baseOffset;//offset from data base address(byte address)
    assign baseOffset = address - `DATA_BASE_ADDRESS;
    
	// ��Ϊֻ��1024��cells,����indexֻ��10λ�͹���
    wire[9:0] index;//index of the cell(word address)
	// ��Ϊƫ�����ĵ�λ��λ����������������������λ������ֽ�
    assign index = baseOffset[11:2];//only use 10bit address

    wire[31:0] indexData;//the word in dataMem[index]
    assign indexData = dataMem[index];
    
    reg[7:0] byteRead;
    reg[15:0] halfRead;
    wire[31:0] out_8_32, out_16_32;
    EXT_8_32 byteExt(.in8(byteRead), .EXTOp(MemEXT), .out32(out_8_32));
    EXT_16_32 halfExt(.in16(halfRead), .EXTOp(MemEXT), .out32(out_16_32));

    //write data
    always @(posedge clk) 
    begin
        if (DMWr)
        begin
            case (MemOp)
                `MEM_BYTE:
                begin
                    case (baseOffset[1:0])
						// ����൱��ֱ�Ӱ�din�����ݲ��뵽�ڴ��м���
                        2'd0: dataMem[index] = {indexData[31:8], din[7:0]}; 
                        2'd1: dataMem[index] = {indexData[31:16], din[7:0], indexData[7:0]};
                        2'd2: dataMem[index] = {indexData[31:24], din[7:0], indexData[15:0]};
                        2'd3: dataMem[index] = {din[7:0], indexData[23:0]};
                    endcase
                    $display("store byte, m[%d/4=%d] = 0x%8h", baseOffset, index, dataMem[index]);
                    $display("inner-address: %d, WD = 0x%2h", baseOffset[1:0], din[7:0]);
                end
                `MEM_HALF:
                begin
                    case (baseOffset[1:0])
                        2'd0: dataMem[index] = {indexData[31:16], din[15:0]};
                        2'd2: dataMem[index] = {din[15:0], indexData[15:0]};
                        default: $display("store half, wrong boundary!");
                    endcase  
                    $display("store half, m[%d/4=%d] = 0x%8h", baseOffset, index, dataMem[index]);
                    $display("inner-address: %d, WD = 0x%4h", baseOffset[1:0], din[15:0]);
                end
                `MEM_WORD: 
                begin
                    dataMem[index] = din;
                    $display("store word, m[%d/4=%d] = %d(0x%8h),", baseOffset, index, din, din);
                end
            endcase
        end
    end

    //read data
    always @(*) 
    begin
        case (MemOp)
			// ��ȡһ���ֽ�
            `MEM_BYTE:
            begin
                case (baseOffset[1:0])
					// ��ȷ������һ���Ĵ���������ȷ�����Ƕ��Ĵ�������һ��λ��
                    2'd0: byteRead = indexData[7:0];			// ��1���ֽڵ�λ��
                    2'd1: byteRead = indexData[15:8];			// ��2���ֽڵ�λ��
                    2'd2: byteRead = indexData[23:16];			// ��3���ֽڵ�λ��
                    2'd3: byteRead = indexData[31:24];			// ��4���ֽڵ�λ��
                endcase
                dout = out_8_32;
            end 
			// ��ȡ���ֳ�
            `MEM_HALF:
            begin
                case (baseOffset[1:0])
                    2'd0: halfRead = indexData[15:0];
                    2'd2: halfRead = indexData[31:16];
                    default: if (!DMWr) $display("read half, wrong boundary!");
                endcase
                dout = out_16_32;
            end
			// ��ȡһ���ֳ�
            `MEM_WORD: dout = indexData;
			
        endcase
    end
    
endmodule 