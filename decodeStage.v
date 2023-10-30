module decodeStage #(

    parameter width = 32
    
) (
    
    input clk, reset, stall_D, flush_DF, 
    input [1:0] for_A_D, for_B_D,
    input [width-1:0] rfOut_1D, rfOut_2D, out_M1, out_M2,
    input [65:0] buffIn_D,
    output branch_D, regWrite_D, memToReg_D,
    output hit_D, predBJ_D, isBJ_D, realBJ_D,
    output mult_D,
    output [1:0] outSel_D,
    output [4:0] rs_D, rt_D, writeReg_D, 
    output [4:0] addr_1D, addr_2D,
    output [width-1:0] pc_D, targetPC_D,
    output [188:0] buffIn_E

);

wire [65:0] buffOut_D;
wire [width-1:0] instr_D;
assign {hit_D, predBJ_D, pc_D, instr_D} = buffOut_D;
assign addr_1D = instr_D[25:21];
assign addr_2D = instr_D[20:16];

pipeBuffer#(66) decodeBuffer(.clk(clk), .reset(reset), .stall(stall_D), .flush(flush_DF), .buffIn(buffIn_D), .buffOut(buffOut_D));
  
wire seZE_D, eqNE_D, jump_D;
wire memRead_D, memWrite_D, regDst_D;
wire aluSrc_D, multSign_D;
wire [3:0] aluOp_D;

controlUnit control(.op(instr_D[31:26]), .func(instr_D[5:0]),
                   .seZE(seZE_D), .eqNE(eqNE_D), .branch(branch_D), .jump(jump_D),
                   .memRead(memRead_D), .memWrite(memWrite_D), .regWrite(regWrite_D), .memToReg(memToReg_D), .regDst(regDst_D), 
                   .aluSrc(aluSrc_D), .startMult(mult_D), .multSign(multSign_D), .outSel(outSel_D), .aluOp(aluOp_D));

branchJump bJ(.eqNE_D(eqNE_D), .branch_D(branch_D), .jump_D(jump_D), 
              .for_A_D(for_A_D), .for_B_D(for_B_D),
              .rfOut_1D(rfOut_1D), .rfOut_2D(rfOut_2D), .out_M1(out_M1), .out_M2(out_M2), .pc_D(pc_D), .instr_D(instr_D),
              .isBJ_D(isBJ_D), .realBJ_D(realBJ_D), .targetPC_D(targetPC_D));
  
wire [width-1:0] shImm_D, seImm_D, zeImm_D, extImm_D;

shifter#(.width(32), .shiftAmt(16)) ls16(.shiftIn(instr_D[15:0]), .shiftOut(shImm_D));
szExt#(.width(32), .sz(0)) sE(.szIn(instr_D[15:0]), .szOut(seImm_D));
szExt#(.width(32), .sz(1)) zE(.szIn(instr_D[15:0]), .szOut(zeImm_D));

mux2#(32) extMux_D(.I0(zeImm_D), .I1(seImm_D), .S0(seZE_D), .muxOut(extImm_D));

wire [4:0] rd_D;
assign rs_D = instr_D[25:21];
assign rt_D = instr_D[20:16];
assign rd_D = instr_D[15:11];

mux2#(5) regDst_Mux(.I0(rt_D), .I1(rd_D), .S0(regDst_D), .muxOut(writeReg_D));

assign buffIn_E = { memRead_D, memWrite_D, regWrite_D, memToReg_D, regDst_D, 
                    aluSrc_D, aluOp_D, outSel_D, mult_D, multSign_D, 
                    rfOut_1D, rfOut_2D, rs_D, rt_D, rd_D, shImm_D, extImm_D, instr_D};

endmodule