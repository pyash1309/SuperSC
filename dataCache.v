module dataCache #(
    parameter cacheSize = 32,
    parameter cacheWordSize = 8,
    parameter dataSize = 32,
    parameter addrSize = 32
) (
    input clk,
    input writeEn1, writeEn2,
    input [addrSize-1:0] addr1, addr2,
    input [dataSize-1:0] writeData1, writeData2,
    output [dataSize-1:0] readData1, readData2
);

reg [cacheWordSize-1:0] cacheData [0:((dataSize*cacheSize)/cacheWordSize)-1];

always @(negedge clk) 
begin

    if ((addr1 == addr2) & writeEn1 & writeEn2) 
    begin
        {cacheData[addr2+3], cacheData[addr2+2], cacheData[addr2+1], cacheData[addr2]} <= writeData2;    
    end

    else
    begin
        if (writeEn1) begin
            {cacheData[addr1+3], cacheData[addr1+2], cacheData[addr1+1], cacheData[addr1]} <= writeData1;
        end 
    
        if (writeEn2) begin
            {cacheData[addr2+3], cacheData[addr2+2], cacheData[addr2+1], cacheData[addr2]} <= writeData2;        
        end
    end
end

assign readData1 = {cacheData[addr1+3], cacheData[addr1+2], cacheData[addr1+1], cacheData[addr1]};
assign readData2 = {cacheData[addr2+3], cacheData[addr2+2], cacheData[addr2+1], cacheData[addr2]};

endmodule

/*module dataCache(input clk, write1, write2,
                   input [31:0] addr1, addr2,
                   input [31:0] write_data1, write_data2,
                   output [31:0] read_data1, read_data2);

  reg [31:0] ram [0:63]; //64 words memory
    
  always @(negedge clk) begin
    if((addr1 == addr2) & write1 & write2) ram[addr2[31:2]] <= write_data2;
    else begin
      if(write1) ram[addr1[31:2]] <= write_data1;
      if(write2) ram[addr2[31:2]] <= write_data2;
    end
  end
  
  assign read_data1 = ram[addr1[31:2]];
  assign read_data2 = ram[addr2[31:2]];

endmodule
*/