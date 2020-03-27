module IM(addr, dout);    
    input [11:2] addr;
    output [31:0] dout;
    reg [31:0] instruction_memory[1023:0];
    assign dout = instruction_memory[addr];
endmodule    