module branchPred (
    
    input clk, reset, stall_F,
    input hit_D1, predBJ_D1, isBJ_D1, realBJ_D1,
    input hit_D2, predBJ_D2, isBJ_D2, realBJ_D2,
    input [31:0] pc_F1, pc_D1, targetPC_D1,
    input [31:0] pc_F2, pc_D2, targetPC_D2,
    output hit_F1, predBJ_F1, 
    output reg flush_D1F,
    output hit_F2, predBJ_F2, 
    output reg flush_D2F,
    output reg [31:0] pcNext_1

);

wire [31:0] targetPC_F1; // target_pcF is the target pc stored in branch target buffer 
wire [31:0] targetPC_F2;

branchTargetBuffer bTB(clk, reset, stall_F,
                         hit_D1, isBJ_D1, realBJ_D1,
                         hit_D2, isBJ_D2, realBJ_D2,
                         pc_F1, pc_D1, targetPC_D1,
                         pc_F2, pc_D2, targetPC_D2,
                         hit_F1, hit_F2,
                         targetPC_F1, targetPC_F2);

globalHistoryPredictor gHP(clk, reset, stall_F,
                             isBJ_D1, realBJ_D1,
                             isBJ_D2, realBJ_D2,
                             pc_F1, pc_D1,
                             pc_F2, pc_D2,
                             predBJ_F1, predBJ_F2);
  
always @(*) 
begin
    
    if(~isBJ_D1 & ~isBJ_D2) 
    begin //if both instrutions in decode stage are not branch
    
        if (hit_F1 & predBJ_F1) 
            begin pcNext_1 <= targetPC_F1; flush_D1F <= 0; flush_D2F <= 0; end
        else if(hit_F2 & predBJ_F2) 
            begin pcNext_1 <= targetPC_F2; flush_D1F <= 0; flush_D2F <= 0; end
        else
            begin pcNext_1 <= pc_F1 + 8;   flush_D1F <= 0; flush_D2F <= 0; end
    
    end

    else 
    begin
      
        if(hit_D1 & predBJ_D1) 
        begin //if predicted d1 branch takes
        
            if (realBJ_D1) 
            begin //if d1 actually takes
                if (hit_F1 & predBJ_F1) 
                begin pcNext_1 <= targetPC_F1; flush_D1F <= 0; flush_D2F <= 0; end
                
                else if(hit_F2 & predBJ_F2) 
                begin pcNext_1 <= targetPC_F2; flush_D1F <= 0; flush_D2F <= 0; end
                
                else                       
                begin pcNext_1 <= pc_F1 + 8;   flush_D1F <= 0; flush_D2F <= 0; end 
            end
            
            else if(realBJ_D2) 
            begin pcNext_1 <= targetPC_D2; flush_D1F <= 1; flush_D2F <= 1; end //if d2 actually takes
            
            else
            begin pcNext_1 <= pc_D1 + 8;   flush_D1F <= 1; flush_D2F <= 1; end //none of them takes
        
        end
      
        else if(hit_D2 & predBJ_D2) 
        begin //if predicted d2 branch takes

            if (realBJ_D1) 
            begin pcNext_1 <= targetPC_D1; flush_D1F <= 1; flush_D2F <= 1; end //if d1 actually takes
            
            else if(realBJ_D2) 
            begin //if d2 actually takes
                if (hit_F1 & predBJ_F1) 
                begin pcNext_1 <= targetPC_F1; flush_D1F <= 0; flush_D2F <= 0; end
                
                else if(hit_F2 & predBJ_F2) 
                begin pcNext_1 <= targetPC_F2; flush_D1F <= 0; flush_D2F <= 0; end
                
                else                       
                begin pcNext_1 <= pc_F1 + 8;   flush_D1F <= 0; flush_D2F <= 0; end 
            end

            else
            begin pcNext_1 <= pc_D1 + 8;    flush_D1F <= 1; flush_D2F <= 1; end //none of them takes

        end

        else 
        begin //predicted none of them takes
        
            if (realBJ_D1) 
            begin pcNext_1 <= targetPC_D1; flush_D1F <= 1; flush_D2F <= 1; end //if d1 actually takes
            
            else if(realBJ_D2) 
            begin pcNext_1 <= targetPC_D2; flush_D1F <= 1; flush_D2F <= 1; end //if d2 actually takes
            
            else 
            begin //none of them takes
                
                if (hit_F1 & predBJ_F1) 
                begin pcNext_1 <= targetPC_F1; flush_D1F <= 0; flush_D2F <= 0; end
          
                else if(hit_F2 & predBJ_F2) 
                begin pcNext_1 <= targetPC_F2; flush_D1F <= 0; flush_D2F <= 0; end
                
                else 
                begin pcNext_1 <= pc_F1 + 8;   flush_D1F <= 0; flush_D2F <= 0; end 
            end        
        end
    end

end

endmodule

module branchTargetBuffer(
    
    input clk, reset, stall_F,
    input hit_D1, isBJ_D1, realBJ_D1,
    input hit_D2, isBJ_D2, realBJ_D2,
    input [31:0] pc_F1, pc_D1, targetPC_D1,
    input [31:0] pc_F2, pc_D2, targetPC_D2,
    output hit_F1, hit_F2,
    output [31:0] targetPC_F1,
    output [31:0] targetPC_F2

);

wire [31:3] tag_F1; 
assign tag_F1 = pc_F1[31:3];
  
wire [2:0] index_F1;
assign index_F1 = pc_F1[2:0];
  
wire [2:0] index_D1; 
assign index_D1 = pc_D1[2:0];
  
wire [31:3] tag_F2; 
assign tag_F2 = pc_F2[31:3];
  
wire [2:0] index_F2; 
assign index_F2 = pc_F2[2:0];
  
wire [2:0] index_D2; 
assign index_D2 = pc_D2[2:0];
  
reg valid [0:7]; 
reg [31:0] bPcTag [0:7]; 
reg [31:0] t_PC [0:7]; // branch pc tag and target pc

integer i;

assign hit_F1 = valid[index_F1] & (tag_F1 == bPcTag[index_F1]);
assign hit_F2 = valid[index_F2] & (tag_F2 == bPcTag[index_F2]);
 
assign targetPC_F1 = t_PC[index_F1];
assign targetPC_F2 = t_PC[index_F2];
  
always @(posedge clk) 
begin
    
    if(reset) 
    begin
        for(i = 0; i <= 7; i = i + 1)
		  begin
            valid[i] <= 0; bPcTag[i] <= 0; t_PC[i] <= 0;
		  end
    end

    else if(~stall_F) 
    begin 																		//store pc and target if not hit but branch
        
        if(isBJ_D1 & realBJ_D1 & ~hit_D1) 
        begin
            valid[index_D1] <= 1;
            bPcTag[index_D1] <= pc_D1[31:3];
            t_PC[index_D1] <= targetPC_D1;
        end
      
        if(isBJ_D2 & realBJ_D2 & ~hit_D2 & (~isBJ_D1 | (isBJ_D1 & ~realBJ_D1))) 
        begin
            valid[index_D2] <= 1;
            bPcTag[index_D2] <= pc_D2[31:3];
            t_PC[index_D2] <= targetPC_D2;
        end
    end
end

endmodule

module globalHistoryPredictor(
    
    input clk, reset, stall_F,
    input isBJ_D1, realBJ_D1,
    input isBJ_D2, realBJ_D2,
    input [31:0] pc_F1, pc_D1,
    input [31:0] pc_F2, pc_D2,
    output predBJ_F1, predBJ_F2

);

wire [6:0] pcLower_F1; 
assign pcLower_F1 = pc_F1[6:0];

wire [6:0] pcLower_D1; 
assign pcLower_D1 = pc_D1[6:0];

wire [6:0] pcLower_F2; 
assign pcLower_F2 = pc_F2[6:0];
  
wire [6:0] pcLower_D2; 
assign pcLower_D2 = pc_D2[6:0];

reg [1:0] bhr; 				//branch history registor
reg [1:0] pht [0:511]; 	//pattern history table

wire [8:0] phtAddr_F1; 
assign phtAddr_F1 = { pcLower_F1[6:0], bhr[1:0] }; //combining 7 bits from pc and 2 bits of bhr

wire [8:0] phtAddr_D1; 
assign phtAddr_D1 = { pcLower_D1[6:0], bhr[1:0] };

wire [8:0] phtAddr_F2; 
assign phtAddr_F2 = { pcLower_F2[6:0], bhr[1:0] }; //combining 7 bits from pc and 2 bits of bhr

wire [8:0] phtAddr_D2; 
assign phtAddr_D2 = { pcLower_D2[6:0], bhr[1:0] };

integer i;
  
assign predBJ_F1 = pht[phtAddr_F1][1];
assign predBJ_F2 = pht[phtAddr_F2][1];

always @(posedge clk) 
begin
    
    if(reset) 
    begin
        bhr <= 0;
        for(i = 0; i < 512; i = i + 1) pht[i] <= 0;
    end

    else if(~stall_F)
    begin

        if(isBJ_D1) 
        begin // if is a branch and branched in reality, increment pht
        
            if(realBJ_D1) 
            begin
                if(pht[phtAddr_D1] != 2'd3) pht[phtAddr_D1] = pht[phtAddr_D1] + 2'd1;
                bhr = bhr << 1;
                bhr[0] = realBJ_D1;
            end
        
            else 
            begin
                if(pht[phtAddr_D1] != 2'd0) pht[phtAddr_D1] = pht[phtAddr_D1] - 2'd1;
                bhr = bhr << 1;
                bhr[0] = realBJ_D1;
            end

        end
      
        if(isBJ_D2) 
        begin // if is a branch and branched in reality, increment pht
            
            if(realBJ_D2 & (~isBJ_D1|(isBJ_D1 & ~realBJ_D1)))
            begin
                if(pht[phtAddr_D2] != 2'd3) pht[phtAddr_D2] = pht[phtAddr_D2] + 2'd1;
                bhr = bhr << 1;
                bhr[0] = realBJ_D2;
            end
            
            else if(~realBJ_D2 & (~isBJ_D1|(isBJ_D1 & ~realBJ_D1)))
            begin
                if(pht[phtAddr_D2] != 2'd0) pht[phtAddr_D2] = pht[phtAddr_D2] - 2'd1;
                bhr = bhr << 1;
                bhr[0] = realBJ_D2;
            end
        end
    end
end

endmodule
