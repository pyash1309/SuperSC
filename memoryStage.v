module memoryStage #(
    parameter width = 32
) (
    
    input clk, reset, stall_M, flush_M,
    input [width-1:0] readData_M,
    input [104:0] buffIn_M,
    output memWrite_M, memToReg_M, regWrite_M,
    output [4:0] writeReg_M,
    output [width-1:0] out_M, writeData_M,
    output [102:0] buffIn_W

);

wire [104:0] buffOut_M;
wire  memRead_M;
wire [width-1:0] instr_M; 

assign {memRead_M, memWrite_M, regWrite_M, memToReg_M, out_M, writeData_M, writeReg_M, instr_M} = buffOut_M;

pipeBuffer#(105) memoryBuffer(.clk(clk), .reset(reset), .stall(stall_M), .flush(flush_M), .buffIn(buffIn_M), .buffOut(buffOut_M));

assign buffIn_W = {regWrite_M, memToReg_M, readData_M, out_M, writeReg_M, instr_M};

endmodule