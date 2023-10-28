module dataCache #(
    parameter cacheSize = 1024,
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

reg [cacheWordSize-1:0] cache [0:dataSize*cacheSize/cacheWordSize - 1];

always @(negedge clk) 
begin

    if ((addr1 == addr2) & writeEn1 & writeEn2) 
    begin
        {cache[addr2], cache[addr2-1], cache[addr2-2], cache[addr2-3]} <= writeData2;    
    end

    else
    begin
        if (writeEn1) begin
            {cache[addr1], cache[addr1-1], cache[addr1-2], cache[addr1-3]} <= writeData1;
        end 
    
        if (writeEn2) begin
            {cache[addr2], cache[addr2-1], cache[addr2-2], cache[addr2-3]} <= writeData2;        
        end
    end
end

assign readData1 = {cache[addr1], cache[addr1-1], cache[addr1-2], cache[addr1-3]};
assign readData2 = {cache[addr2], cache[addr2-1], cache[addr2-2], cache[addr2-3]};

endmodule
