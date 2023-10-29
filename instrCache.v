module instrCache #(
    parameter memWidth = 8,
    parameter instrWidth = 32,
    parameter cacheSize = 256
) (
    input [instrWidth-1:0] pcF1, pcF2,
    output [instrWidth-1:0] instrF1, instrF2
);

reg [memWidth-1:0] cacheInstr [0:(instrWidth/memWidth)*cacheSize - 1];

initial begin
    integer i;
    for(i=0; i<(instrWidth/memWidth)*cacheSize; i=i+1)
        cacheInstr[i] <= 0;
end

assign instrF1 = {cacheInstr[pcF1+3], cacheInstr[pcF1+2], cacheInstr[pcF1+1], cacheInstr[pcF1]};
assign instrF2 = {cacheInstr[pcF2+3], cacheInstr[pcF2+2], cacheInstr[pcF2+1], cacheInstr[pcF2]};

endmodule
