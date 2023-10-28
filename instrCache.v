module instrCache #(
    parameter memWidth = 8,
    parameter instrWidth = 32,
    parameter cacheSize = 256
) (
    input [instrWidth-1:0] pcF1, pcF2,
    output [instrWidth-1:0] instrF1, instrF2
);

reg [memWidth-1:0] cache [0:(instrWidth/memWidth)*cacheSize - 1];

initial begin
    integer i;
    for(i=0; i<(instrWidth/memWidth)*cacheSize; i=i+1)
        cache[i] <= 0;
end

assign instrF1 = {cache[pcF1-3], cache[pcF1-2], cache[pcF1-1], cache[pcF1]};
assign instrF2 = {cache[pcF2-3], cache[pcF2-2], cache[pcF2-1], cache[pcF2]};

endmodule