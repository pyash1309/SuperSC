module multUnit #(
    parameter width = 32
) (
    input clk, isSigned, multBegin,
    input [width-1:0] multSrc1, multSrc2,
    output multStall,
    output reg [width*2 - 1:0] multOut
);

wire start;
reg [width*2-1:0] srcTemp1;
reg [width*4:0] sTemp;
reg busy = 0, stall = 0;

integer i;

assign start = multBegin & ~busy;
assign multStall = start | stall;

always @(posedge clk ) 
begin

    if(start)
    begin
        i <= 0;
        busy <= 1;
        stall <= 1;
        sTemp[width*4:width*2] <= {(width*4-width*2+1){1'b0}};

        if(isSigned)
        begin
            srcTemp1[width*2-1:0] <= {{width{multSrc1[width-1]}}, multSrc1[width-1:0]};
            sTemp[width*2-1:0] <= {{width{multSrc2[width-1]}}, multSrc2[width-1:0]};
        end

        else
        begin
            srcTemp1[width*2-1:0] <= {{width{1'b0}}, multSrc1[width-1:0]};
            sTemp[width*2-1:0] <= {{width{1'b0}}, multSrc2[width-1:0]};
        end
    end

    else if (i < 64) 
    begin
        i = i + 1;
        if(sTemp[0]) sTemp[width*4:width*2] = sTemp[width*4:width*2] + srcTemp1[width*2-1:0];
        sTemp = sTemp >> 1;
        if(i == 64) 
        begin
            stall <= 0;
            multOut <= sTemp[width*2-1:0];
        end
    end

    else 
        busy <= 0;

end

endmodule