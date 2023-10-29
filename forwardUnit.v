module forwardUnit (

    input [4:0] rs_D1, rt_D1, rs_D2, rt_D2, 
    input [4:0] rs_E1, rt_E1, rs_E2, rt_E2,
    
    input regWrite_M1, regWrite_M2, 
    input [4:0] writeReg_M1, writeReg_M2,
    
    input regWrite_W1, regWrite_W2, 
    input [4:0] writeReg_W1, writeReg_W2,
    
    output reg [1:0] for_A_D1, for_B_D1, for_A_D2, for_B_D2,
    output reg [2:0] for_A_E1, for_B_E1, for_A_E2, for_B_E2 

);

always @(*) begin
    
    //forward to decode stage
    if(rs_D1 != 0) begin //outM1, outM2,
      if     (rs_D1 == writeReg_M2 & regWrite_M2) for_A_D1 = 2'd2;
      else if(rs_D1 == writeReg_M1 & regWrite_M1) for_A_D1 = 2'd1;
      else for_A_D1 = 2'd0;
    end
    else for_A_D1 = 2'd0;

    if(rt_D1 != 0) begin
      if     (rt_D1 == writeReg_M2 & regWrite_M2) for_B_D1 = 2'd2;
      else if(rt_D1 == writeReg_M1 & regWrite_M1) for_B_D1 = 2'd1;
      else for_B_D1 = 2'd0;
    end
    else for_B_D1 = 2'd0; 

    if(rs_D2 != 0) begin //outM1, outM2,
      if     (rs_D2 == writeReg_M2 & regWrite_M2) for_A_D2 = 2'd2;
      else if(rs_D2 == writeReg_M1 & regWrite_M1) for_A_D2 = 2'd1;
      else for_A_D2 = 2'd0;
    end
    else for_A_D2 = 2'd0;

    if(rt_D2 != 0) begin
      if     (rt_D2 == writeReg_M2 & regWrite_M2) for_B_D2 = 2'd2;
      else if(rt_D2 == writeReg_M1 & regWrite_M1) for_B_D2 = 2'd1;
      else for_B_D2 = 2'd0;
    end 
    else for_B_D2 = 2'd0;

    //forward to execution stage
    if(rs_E1 != 0) begin //outM1, resultW1, outM2, resultW2,
      if     (rs_E1 == writeReg_M2 & regWrite_M2) for_A_E1 = 3'd3;
      else if(rs_E1 == writeReg_M1 & regWrite_M1) for_A_E1 = 3'd1;
      else if(rs_E1 == writeReg_W2 & regWrite_W2) for_A_E1 = 3'd4;
      else if(rs_E1 == writeReg_W1 & regWrite_W1) for_A_E1 = 3'd2;
      else for_A_E1 = 3'd0;
    end
    else for_A_E1 = 2'd0;

    if(rt_E1 != 0) begin
      if     (rt_E1 == writeReg_M2 & regWrite_M2) for_B_E1 = 3'd3;
      else if(rt_E1 == writeReg_M1 & regWrite_M1) for_B_E1 = 3'd1;
      else if(rt_E1 == writeReg_W2 & regWrite_W2) for_B_E1 = 3'd4;
      else if(rt_E1 == writeReg_W1 & regWrite_W1) for_B_E1 = 3'd2;
      else for_B_E1 = 3'd0;
    end
    else for_B_E1 = 3'd0;

    if(rs_E2 != 0) begin //outM1, resultW1, outM2, resultW2,
      if     (rs_E2 == writeReg_M2 & regWrite_M2) for_A_E2 = 3'd3;
      else if(rs_E2 == writeReg_M1 & regWrite_M1) for_A_E2 = 3'd1;
      else if(rs_E2 == writeReg_W2 & regWrite_W2) for_A_E2 = 3'd4;
      else if(rs_E2 == writeReg_W1 & regWrite_W1) for_A_E2 = 3'd2;
      else for_A_E2 = 3'd0;
    end
    else for_A_E2 = 3'd0;

    if(rt_E2 != 0) begin
      if     (rt_E2 == writeReg_M2 & regWrite_M2) for_B_E2 = 3'd3;
      else if(rt_E2 == writeReg_M1 & regWrite_M1) for_B_E2 = 3'd1;
      else if(rt_E2 == writeReg_W2 & regWrite_W2) for_B_E2 = 3'd4;
      else if(rt_E2 == writeReg_W1 & regWrite_W1) for_B_E2 = 3'd2;
      else for_B_E2 = 3'd0;
    end
    else for_B_E2 = 3'd0;
    
  end

endmodule