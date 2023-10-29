module fetchStage #(
    parameter width = 32
) (
    
    input clk, reset, stall_F, flush_F, 
    input hit_D1, predBJ_D1, isBJ_D1, realBJ_D1, 
    input hit_D2, predBJ_D2, isBJ_D2, realBJ_D2,
    input [width-1:0] pc_D1, targetPC_D1,
    input [width-1:0] pc_D2, targetPC_D2,
    output flush_D1F, flush_D2F,
    output [65:0] buffIn_D1, buffIn_D2

);

wire hit_F1, predBJ_F1;
wire hit_F2, predBJ_F2;
wire [width-1:0] pcNext_1, pc_F1, pc_F2, instr_F1, instr_F2;
assign pc_F2 = pc_F1 + 4;
    
pipeBuffer#(32) pcReg(.clk(clk), .reset(reset), .stall(stall_F), .flush(flush_F), .buffIn(pcNext_1), .buffOut(pc_F1));
instrCache iMem(.pcF1(pc_F1), .pcF2(pc_F2), .instrF1(instr_F1), .instrF2(instr_F2));
    
branchPred bP( .clk(clk), .reset(reset), .stall_F(stall_F),
               .hit_D1(hit_D1), .predBJ_D1(predBJ_D1), .isBJ_D1(isBJ_D1), .realBJ_D1(realBJ_D1),
               .hit_D2(hit_D2), .predBJ_D2(predBJ_D2), .isBJ_D2(isBJ_D2), .realBJ_D2(realBJ_D2),
               .pc_F1(pc_F1), .pc_D1(pc_D1), .targetPC_D1(targetPC_D1),
               .pc_F2(pc_F2), .pc_D2(pc_D2), .targetPC_D2(targetPC_D2),
               .hit_F1(hit_F1), .predBJ_F1(predBJ_F1), .flush_D1F(flush_D1F),
               .hit_F2(hit_F2), .predBJ_F2(predBJ_F2), .flush_D2F(flush_D2F),
               .pcNext_1(pcNext_1));
    
assign buffIn_D1 = {hit_F1, predBJ_F1, pc_F1, instr_F1};
assign buffIn_D2 = {hit_F2, predBJ_F2, pc_F2, instr_F2};

endmodule