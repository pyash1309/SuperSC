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