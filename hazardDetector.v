module hazardDetector (

    input mult_D1, mult_D2,
    input [1:0] outSel_D1, outSel_D2,
    input isBJ_D1, realBJ_D1, 
    input branch_D1, branch_D2, memToReg_D1, memToReg_D2, regWrite_D1, regWrite_D2,
    input [4:0] rs_D1, rt_D1, writeReg_D1, rs_D2, rt_D2, writeReg_D2,

    input memToReg_E1, regWrite_E1, multStall_E1, 
    input memToReg_E2, regWrite_E2, multStall_E2, 
    input [4:0] rs_E1, rt_E1, writeReg_E1, rs_E2, rt_E2, writeReg_E2,

    input memToReg_M1, memToReg_M2,
    input [4:0] writeReg_M1, writeReg_M2,

    output stall_F, 
    output stall_D1, stall_E1, stall_M1, stall_W1,
    output stall_D2, stall_E2, stall_M2, stall_W2,
    output flush_D1, flush_E1, flush_M1, flush_W1,
    output flush_D2, flush_E2, flush_M2, flush_W2

);
  //lw stall
  wire lwStall_1; 
  assign lwStall_1 = ( (((rs_D1 == writeReg_E1) | (rt_D1 == writeReg_E1)) & memToReg_E1) |
                       (((rs_D1 == writeReg_E2) | (rt_D1 == writeReg_E2)) & memToReg_E2) );
                                                                                   
  wire lwStall_2; 
  assign lwStall_2 = ( (((rs_D2 == writeReg_D1) | (rt_D2 == writeReg_D1)) & memToReg_D1) |
                       (((rs_D2 == writeReg_E1) | (rt_D2 == writeReg_E1)) & memToReg_E1) |
                       (((rs_D2 == writeReg_E2) | (rt_D2 == writeReg_E2)) & memToReg_E2) );

  //branch stall
  wire bsc_E1; 
  assign bsc_E1 = ( (((rs_D1 == writeReg_E1) | (rt_D1 == writeReg_E1)) & regWrite_E1) |
                    (((rs_D1 == writeReg_E2) | (rt_D1 == writeReg_E2)) & regWrite_E2) );
  
  wire bsc_M1; 
  assign bsc_M1 = ( (((rs_D1 == writeReg_M1) | (rt_D1 == writeReg_M1)) & memToReg_M1) |
                    (((rs_D1 == writeReg_M2) | (rt_D1 == writeReg_M2)) & memToReg_M2) );
  
  wire branchStall_1; 
  assign branchStall_1 = branch_D1 & (bsc_E1 | bsc_M1);

  wire bsc_D2; 
  assign bsc_D2 = ((rs_D2 == writeReg_D1) | (rt_D2 == writeReg_D1)) & regWrite_D1; 
  
  wire bsc_E2; 
  assign bsc_E2 = ( (((rs_D2 == writeReg_E1) | (rt_D2 == writeReg_E1)) & regWrite_E1) |
                    (((rs_D2 == writeReg_E2) | (rt_D2 == writeReg_E2)) & regWrite_E2) );
  
  wire bsc_M2; 
  assign bsc_M2 = ( (((rs_D2 == writeReg_M1) | (rt_D2 == writeReg_M1)) & memToReg_M1) |
                    (((rs_D2 == writeReg_M2) | (rt_D2 == writeReg_M2)) & memToReg_M2) );
  
  wire branchStall_2; 
  assign branchStall_2 = branch_D2 & (bsc_D2 | bsc_E2 | bsc_M2);

  //execution stall
  wire exeStall_2; 
  assign exeStall_2 = ((rs_E2 == writeReg_E1) | (rt_E2 == writeReg_E1)) & regWrite_E1; 

  //stalls
  assign stall_W1 = 0;
  assign stall_W2 = 0;
  assign stall_M1 = 0;
  assign stall_M2 = 0;

  assign stall_E1 = multStall_E1;
  assign stall_E2 = stall_E1 | exeStall_2 | multStall_E2;
  assign stall_D1 = stall_E2 | lwStall_1 | branchStall_1;
  assign stall_D2 = stall_D1 | ((lwStall_2 | branchStall_2) & ~(isBJ_D1 & realBJ_D1)) 
                             | (mult_D1 & (outSel_D2 == 2'b10)|(outSel_D2 == 2'b11));
  
  assign stall_F = stall_D2;
  
  //flushes  
  assign flush_W1 = 0;
  assign flush_W2 = 0;
  assign flush_M1 = stall_E1;
  assign flush_M2 = stall_E1 | stall_E2;
  assign flush_E1 = stall_D1 | stall_E2;
  assign flush_E2 = stall_D1 | stall_D2 | (isBJ_D1 & realBJ_D1);
  assign flush_D1 = stall_D2;
  assign flush_D2 = 0;
    
endmodule