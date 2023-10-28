module regFile #(
    parameter fileSize = 32,
    parameter regSize = 32
) (
    input clk, reset,
    input write1, write2,
    input [regAddr-1:0] readAddr1_D1, readAddr1_D2, readAddr2_D1, readAddr2_D2,
    input [regAddr-1:0] writeAddr_D1, writeAddr_D2,
    input [regSize-1:0] writeData_D1, writeData_D2,
    output [regSize-1:0] readData1_D1, readData1_D2, readData2_D1, readData2_D2
);

localparam regAddr = $clog2(fileSize);

reg [regSize-1:0] regfile [0:fileSize-1];
integer i;

always @(negedge clk ) 
begin

    if (reset) 
    begin
        for (i=0; i<fileSize; i=i+1) begin
            regfile[i] <= {regSize{1'b0}};
        end    
    end

    else
    begin
        if((writeAddr_D1 == writeAddr_D2) & write1 & write2)
            regfile[writeAddr_D2] <= writeData_D2;
        else
        begin
            if(write1) regfile[writeAddr_D1] <= writeData_D1;
            if(write2) regfile[writeAddr_D2] <= writeData_D2;
        end
    end
end

assign readData1_D1 = (readAddr1_D1 != 0) ? regfile[readAddr1_D1] : {regSize{1'b0}};
assign readData1_D2 = (readAddr1_D2 != 0) ? regfile[readAddr1_D2] : {regSize{1'b0}};
assign readData2_D1 = (readAddr2_D1 != 0) ? regfile[readAddr2_D1] : {regSize{1'b0}};
assign readData2_D2 = (readAddr2_D2 != 0) ? regfile[readAddr2_D2] : {regSize{1'b0}};

endmodule
