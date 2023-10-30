module supersc #(
	parameter width = 32
) (
	input clk, reset
);

// --------------------------------------------------------------------------------  Fetch Stage ---------- //

wire stall_F, flush_F;

wire flush_D1F, hit_D1, isBJ_D1, predBJ_D1, realBJ_D1;
wire [width-1:0] pc_D1, targetPC_D1;
wire [65:0] buffIn_D1;

wire flush_D2F, hit_D2, isBJ_D2, predBJ_D2, realBJ_D2;
wire [width-1:0] pc_D2, targetPC_D2;
wire [65:0] buffIn_D2;

fetchStage fetch( .clk(clk), .reset(reset), .stall_F(stall_F), .flush_F(flush_F),
             	  .hit_D1(hit_D1), .predBJ_D1(predBJ_D1), .isBJ_D1(isBJ_D1), .realBJ_D1(realBJ_D1),
             	  .hit_D2(hit_D2), .predBJ_D2(predBJ_D2), .isBJ_D2(isBJ_D2), .realBJ_D2(realBJ_D2),
              	  .pc_D1(pc_D1), .targetPC_D1(targetPC_D1),
             	  .pc_D2(pc_D2), .targetPC_D2(targetPC_D2),
             	  .flush_D1F(flush_D1F), .flush_D2F(flush_D2F),
             	  .buffIn_D1(buffIn_D1), .buffIn_D2(buffIn_D2));

// --------------------------------------------------------------------------------  Decode Stage D1 ---------- //

wire [width-1:0] out_M1, out_M2;
wire [4:0] addr_1D1, addr_2D1, addr_1D2, addr_2D2;
wire [width-1:0] rfOut_1D1, rfOut_2D1, rfOut_1D2, rfOut_2D2;
wire stall_D1, flush_D1, branch_D1, memToReg_D1, regWrite_D1, mult_D1;
wire [1:0] for_A_D1, for_B_D1, outSel_D1;
wire [4:0] rs_D1, rt_D1, writeReg_D1;
wire [188:0] buffIn_E1;

decodeStage decodeD1( .clk(clk), .reset(reset), .stall_D(stall_D1), .flush_DF(flush_D1 | flush_D1F), 
           			  .for_A_D(for_A_D1), .for_B_D(for_B_D1),
           			  .rfOut_1D(rfOut_1D1), .rfOut_2D(rfOut_2D1), .out_M1(out_M1), .out_M2(out_M2),
           			  .buffIn_D(buffIn_D1),
           			  .branch_D(branch_D1), .memToReg_D(memToReg_D1), .regWrite_D(regWrite_D1),
           			  .hit_D(hit_D1), .predBJ_D(predBJ_D1), .isBJ_D(isBJ_D1), .realBJ_D(realBJ_D1),
           			  .mult_D(mult_D1), .outSel_D(outSel_D1),
		              .rs_D(rs_D1), .rt_D(rt_D1), .writeReg_D(writeReg_D1),
           			  .addr_1D(addr_1D1), .addr_2D(addr_2D1),
		              .pc_D(pc_D1), .targetPC_D(targetPC_D1),
          			  .buffIn_E(buffIn_E1));

// --------------------------------------------------------------------------------  Register File ---------- //

wire regWrite_W1, regWrite_W2;
wire [4:0] writeReg_W1, writeReg_W2;
wire [width-1:0] result_W1, result_W2;

regFile rf( .clk(clk), .reset(reset), .write1(regWrite_W1), .write2(regWrite_W2),
            .readAddr1_D1(addr_1D1), .readAddr2_D1(addr_2D1), .readAddr1_D2(addr_1D2), .readAddr2_D2(addr_2D2), 
            .writeAddr_D1(writeReg_W1), .writeAddr_D2(writeReg_W2),
            .writeData_D1(result_W1), .writeData_D2(result_W2),
            .readData1_D1(rfOut_1D1), .readData2_D1(rfOut_2D1), .readData1_D2(rfOut_1D2), .readData2_D2(rfOut_2D2));

// --------------------------------------------------------------------------------  Decode Stage D2 ---------- //

wire stall_D2, flush_D2, branch_D2, memToReg_D2, regWrite_D2, mult_D2;
wire [1:0] for_A_D2, for_B_D2, outSel_D2;
wire [4:0] rs_D2, rt_D2, writeReg_D2;
wire [188:0] buffIn_E2;

decodeStage decodeD2( .clk(clk), .reset(reset), .stall_D(stall_D2), .flush_DF(flush_D2 | flush_D2F), 
           			  .for_A_D(for_A_D2), .for_B_D(for_B_D2),
           			  .rfOut_1D(rfOut_1D2), .rfOut_2D(rfOut_2D2), .out_M1(out_M1), .out_M2(out_M2),
						  .buffIn_D(buffIn_D2),
           			  .branch_D(branch_D2), .memToReg_D(memToReg_D2), .regWrite_D(regWrite_D2),
           			  .hit_D(hit_D2), .predBJ_D(predBJ_D2), .isBJ_D(isBJ_D2), .realBJ_D(realBJ_D2),
           			  .mult_D(mult_D2), .outSel_D(outSel_D2),
           			  .rs_D(rs_D2), .rt_D(rt_D2), .writeReg_D(writeReg_D2),
           			  .addr_1D(addr_1D2), .addr_2D(addr_2D2),
           			  .pc_D(pc_D2), .targetPC_D(targetPC_D2),
           			  .buffIn_E(buffIn_E2));

// --------------------------------------------------------------------------------  Execution Stage E1 ---------- //

wire stall_E1, flush_E1, multStall_E1, regWrite_E1, memToReg_E1;
wire [2:0] for_A_E1, for_B_E1;
wire [4:0] rs_E1, rt_E1, writeReg_E1;
wire [width-1:0] loE_t, hiE_t, lo_E1, hi_E1, lo_E2, hi_E2;
wire [104:0] buffIn_M1;

executionStage executeE1( .clk(clk), .reset(reset), .stall_E(stall_E1), .flush_E(flush_E1),
                          .for_A_E(for_A_E1), .for_B_E(for_B_E1),
                          .out_M1(out_M1), .result_W1(result_W1), .out_M2(out_M2), .result_W2(result_W2), .lo_E_t(loE_t), .hi_E_t(hiE_t),
                          .buffIn_E(buffIn_E1),
                          .multStall_E(multStall_E1), .regWrite_E(regWrite_E1), .memToReg_E(memToReg_E1),
                          .rs_E(rs_E1), .rt_E(rt_E1), .writeReg_E(writeReg_E1),
                          .lo_E(lo_E1), .hi_E(hi_E1), 
                          .buffIn_M(buffIn_M1));

wire stall_E2, flush_E2, multStall_E2, regWrite_E2, memToReg_E2;
wire [2:0] for_A_E2, for_B_E2;
wire [4:0] rs_E2, rt_E2, writeReg_E2;
wire [104:0] buffIn_M2;  

// --------------------------------------------------------------------------------  Execution Stage E2 ---------- //

executionStage executeE2( .clk(clk), .reset(reset), .stall_E(stall_E2), .flush_E(flush_E2),
                          .for_A_E(for_A_E2), .for_B_E(for_B_E2),
                          .out_M1(out_M1), .result_W1(result_W1), .out_M2(out_M2), .result_W2(result_W2), .lo_E_t(loE_t), .hi_E_t(hiE_t),
                          .buffIn_E(buffIn_E2),
                          .multStall_E(multStall_E2), .regWrite_E(regWrite_E2), .memToReg_E(memToReg_E2),
                          .rs_E(rs_E2), .rt_E(rt_E2), .writeReg_E(writeReg_E2),
                          .lo_E(lo_E2), .hi_E(hi_E2), 
                          .buffIn_M(buffIn_M2)); 
  
wire ms_1D, ms_2D;
wire [width-1:0] loOut, hiOut;

pipeBuffer#(1) multStallE1_Delay(.clk(clk), .reset(reset), .stall(0), .flush(0), .buffIn(multStall_E1), .buffOut(ms_1D));
pipeBuffer#(1) multStallE2_Delay(.clk(clk), .reset(reset), .stall(0), .flush(0), .buffIn(multStall_E2), .buffOut(ms_2D));

wire m1Done; 
assign m1Done = {multStall_E1, ms_1D} == 2'b01;

wire m2Done; 
assign m2Done = {multStall_E2, ms_2D} == 2'b01;

wire pSel; 
assign pSel = m2Done;  

mux2#(32) loMux(.I0(lo_E1), .I1(lo_E2), .S0(pSel), .muxOut(loOut));
mux2#(32) hiMux(.I0(hi_E1), .I1(hi_E2), .S0(pSel), .muxOut(hiOut));

pipeBuffer#(32) lo_t(.clk(clk), .reset(reset), .stall(~(m1Done | m2Done)), .flush(0), .buffIn(loOut), .buffOut(loE_t));
pipeBuffer#(32) hi_t(.clk(clk), .reset(reset), .stall(~(m1Done | m2Done)), .flush(0), .buffIn(hiOut), .buffOut(hiE_t));
 
// --------------------------------------------------------------------------------  Memory Stage M1 ---------- // 

wire memWrite_M1, memToReg_M1, memWrite_M2, memToReg_M2, regWrite_M1, regWrite_M2;
wire [width-1:0] writeData_M1, writeData_M2, readData_M1, readData_M2;

wire stall_M1, flush_M1;
wire [4:0] writeReg_M1;
wire [102:0] buffIn_W1;

memoryStage memoryM1( .clk(clk), .reset(reset), .stall_M(stall_M1), .flush_M(flush_M1),
                      .readData_M(readData_M1),
                      .buffIn_M(buffIn_M1),
                      .memWrite_M(memWrite_M1), .memToReg_M(memToReg_M1), .regWrite_M(regWrite_M1),
                      .writeReg_M(writeReg_M1),
                      .out_M(out_M1), .writeData_M(writeData_M1),
                      .buffIn_W(buffIn_W1)); 

// --------------------------------------------------------------------------------  Data Memory ---------- //

dataCache cacheData( .clk(clk), .writeEn1(memWrite_M1), .writeEn2(memWrite_M2),
                     .addr1(out_M1), .addr2(out_M2),
                     .writeData1(writeData_M1), .writeData2(writeData_M2),
                     .readData1(readData_M1), .readData2(readData_M2));
  
// --------------------------------------------------------------------------------  Memory Stage M2 ---------- //

wire stall_M2, flush_M2;
wire [4:0] writeReg_M2;
wire [102:0] buffIn_W2;

memoryStage memoryM2( .clk(clk), .reset(reset), .stall_M(stall_M2), .flush_M(flush_M2),
                      .readData_M(readData_M2),
                      .buffIn_M(buffIn_M2),
                      .memWrite_M(memWrite_M2), .memToReg_M(memToReg_M2), .regWrite_M(regWrite_M2),
                      .writeReg_M(writeReg_M2),
                      .out_M(out_M2), .writeData_M(writeData_M2),
                      .buffIn_W(buffIn_W2)); 

// --------------------------------------------------------------------------------  WriteBack Stage W1 ---------- //

wire stall_W1, flush_W1;
writebackStage writebackW1( .clk(clk), .reset(reset), .stall_W(stall_W1), .flush_W(flush_W1),
           				   	.buffIn_W(buffIn_W1), 
           				   	.regWrite_W(regWrite_W1),
           				   	.writeReg_W(writeReg_W1),
           				   	.result_W(result_W1));

// --------------------------------------------------------------------------------  WriteBack Stage W2 ---------- //

wire stall_W2, flush_W2;

writebackStage writebackW2( .clk(clk), .reset(reset), .stall_W(stall_W2), .flush_W(flush_W2),
           				   	.buffIn_W(buffIn_W2), 
           				   	.regWrite_W(regWrite_W2),
           				   	.writeReg_W(writeReg_W2),
           				   	.result_W(result_W2));

// --------------------------------------------------------------------------------  Hazard Detector ---------- //
  
hazardDetector hD( .mult_D1(mult_D1), .mult_D2(mult_D2), 
                   .outSel_D1(outSel_D1), .outSel_D2(outSel_D2),
                   .isBJ_D1(isBJ_D1), .realBJ_D1(realBJ_D1), 
                   .branch_D1(branch_D1), .branch_D2(branch_D2), .memToReg_D1(memToReg_D1), .memToReg_D2(memToReg_D2), .regWrite_D1(regWrite_D1), .regWrite_D2(regWrite_D2),
                   .rs_D1(rs_D1), .rt_D1(rt_D1), .writeReg_D1(writeReg_D1), .rs_D2(rs_D2), .rt_D2(rt_D2), .writeReg_D2(writeReg_D2),
                   .memToReg_E1(memToReg_E1), .regWrite_E1(regWrite_E1), .multStall_E1(multStall_E1), 
                   .memToReg_E2(memToReg_E2), .regWrite_E2(regWrite_E2), .multStall_E2(multStall_E2), 
                   .rs_E1(rs_E1), .rt_E1(rt_E1), .writeReg_E1(writeReg_E1), .rs_E2(rs_E2), .rt_E2(rt_E2), .writeReg_E2(writeReg_E2),
                   .memToReg_M1(memToReg_M1), .memToReg_M2(memToReg_M2),
                   .writeReg_M1(writeReg_M1), .writeReg_M2(writeReg_M2),
                   .stall_F(stall_F), 
                   .stall_D1(stall_D1), .stall_E1(stall_E1), .stall_M1(stall_M1), .stall_W1(stall_W1),
                   .stall_D2(stall_D2), .stall_E2(stall_E2), .stall_M2(stall_M2), .stall_W2(stall_W2),
                   .flush_D1(flush_D1), .flush_E1(flush_E1), .flush_M1(flush_M1), .flush_W1(flush_W1),
                   .flush_D2(flush_D2), .flush_E2(flush_E2), .flush_M2(flush_M2), .flush_W2(flush_W2));

// --------------------------------------------------------------------------------  Forwarding Unit ---------- //

forwardUnit fU( .rs_D1(rs_D1), .rt_D1(rt_D1), .rs_D2(rs_D2), .rt_D2(rt_D2), 
                .rs_E1(rs_E1), .rt_E1(rt_E1), .rs_E2(rs_E2), .rt_E2(rt_E2),
                .regWrite_M1(regWrite_M1), .regWrite_M2(regWrite_M2), .writeReg_M1(writeReg_M1), .writeReg_M2(writeReg_M2),
                .regWrite_W1(regWrite_W1), .regWrite_W2(regWrite_W2), .writeReg_W1(writeReg_W1), .writeReg_W2(writeReg_W2),
                .for_A_D1(for_A_D1), .for_B_D1(for_B_D1), .for_A_D2(for_A_D2), .for_B_D2(for_B_D2),
                .for_A_E1(for_A_E1), .for_B_E1(for_B_E1), .for_A_E2(for_A_E2), .for_B_E2(for_B_E2));

endmodule
