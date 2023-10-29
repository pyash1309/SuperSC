module executionStage #(
    parameter width = 32
) (
    
    input clk, reset, stall_E, flush_E,
    input[2:0] for_A_E, for_B_E,
    input[width-1:0] out_M1, result_W1, out_M2, result_W2, lo_E_t, hi_E_t,
    input[188:0] buffIn_E,
	 
    output multStall_E, regWrite_E, memToReg_E,
    output[4:0] rs_E, rt_E, writeReg_E,
    output [width-1:0] lo_E, hi_E,
    output[104:0] buffIn_M

);

wire memRead_E, memWrite_E, regDst_E, aluSrc_E, mult_E, multSign_E;
wire [3:0] aluOp_E; 
wire [1:0] outSel_E;
wire [width-1:0] rd_1E, rd_2E; 
wire [4:0] rd_E; 

wire [width-1:0] shImm_E, extImm_E;
wire [width-1:0] srcA_E, srcB_E, aluOut_E, writeData_E, out_E;

wire [188:0] buffOut_E;
wire [width-1:0] instr_E;

assign {memRead_E, memWrite_E, regWrite_E, memToReg_E, regDst_E, 
        aluSrc_E, aluOp_E, outSel_E, mult_E, multSign_E, 
        rd_1E, rd_2E, rs_E, rt_E, rd_E, shImm_E, extImm_E, instr_E} = buffOut_E;
  
pipeBuffer#(189) executionBuffer(.clk(clk), .reset(reset), .stall(stall_E), .flush(flush_E), .buffIn(buffIn_E), .buffOut(buffOut_E));

mux5#(32) forwardMux_AE(.I0(rd_1E), .I1(out_M1), .I2(result_W1), .I3(out_M2), .I4(result_W2), .S(for_A_E), .muxOut(srcA_E));
mux5#(32) forwardMux_BE(.I0(rd_2E), .I1(out_M1), .I2(result_W1), .I3(out_M2), .I4(result_W2), .S(for_B_E), .muxOut(writeData_E));

mux2#(5) regDstMux(.I0(rt_E), .I1(rd_E), .S0(regDst_E), .muxOut(writeReg_E));
mux2#(32) aluSrcMux(.I0(writeData_E), .I1(extImm_E), .S0(aluSrc_E), .muxOut(srcB_E));

ALU aluUnit(.aluIn1(srcA_E), .aluIn2(srcB_E), .aluFunc(aluOp_E), .aluOut(aluOut_E));

multUnit mult(.clk(clk), .multBegin(mult_E), .isSigned(multSign_E), .multSrc1(srcA_E), .multSrc2(srcB_E), .multStall(multStall_E), .multOut({hi_E, lo_E}));

mux4#(32) outMux_E(.I0(aluOut_E), .I1(shImm_E), .I2(lo_E_t), .I3(hi_E_t), .S(outSel_E), .muxOut(out_E));

assign buffIn_M = {memRead_E, memWrite_E, regWrite_E, memToReg_E, out_E, writeData_E, writeReg_E, instr_E};

endmodule