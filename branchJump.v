module branchJump #(

    parameter width = 32

) (
    
    input eqNE_D, branch_D, jump_D, 
    input [1:0] for_A_D, for_B_D,
    input [width-1:0] rfOut_1D, rfOut_2D, out_M1, out_M2, pc_D, instr_D,
    output isBJ_D, realBJ_D,
    output [width-1:0] targetPC_D

);

wire equal, branchCond;
wire [width-1:0] muxAOut, muxBOut;
wire [width-1:0] pcPlus_4D; assign pcPlus_4D = pc_D + 4;
  
mux4#(32) forwardMux_AD(.I0(rfOut_1D), .I1(out_M1), .I2(out_M2), .I3(1'b0), .S(for_A_D), .muxOut(muxAOut));
mux4#(32) forwardMux_BD(.I0(rfOut_2D), .I1(out_M1), .I2(out_M2), .I3(1'b0), .S(for_B_D), .muxOut(muxBOut));
  
assign equal = (muxAOut == muxBOut);
assign branchCond = (eqNE_D) ? equal : ~equal; // branch condition determined by beq or bne
assign isBJ_D = branch_D | jump_D;
assign realBJ_D = (branch_D & branchCond) | jump_D;

wire [width-1:0] seImm, ls2Out;

szExt#(.width(32), .sz(0)) sE(.szIn(instr_D[15:0]), .szOut(seImm));
shifter#(.width(32), .shiftAmt(2)) branchShift(.shiftIn(seImm), .shiftOut(ls2Out));
  
wire [width-1:0] branchPC; assign branchPC = ls2Out + pcPlus_4D;
wire [width-1:0] jumpPC; assign jumpPC = {pcPlus_4D[width-1:28], instr_D[25:0], 2'b0};

assign targetPC_D = (branch_D) ? branchPC : (jump_D) ? jumpPC : 32'b0;

endmodule