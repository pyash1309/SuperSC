// Pipeline Buffer Module

module pipeBuffer #(
    parameter width = 1
) (
    input clk, reset, stall, flush,
    input [width-1:0] buffIn,
    output reg [width-1:0] buffOut 
);

always @(posedge clk ) 
begin
    if (reset) 
        buffOut <= {width{1'b0}};
    
    else if (~stall) begin
        
        if(flush) buffOut <= {width{1'b0}};
        else buffOut <= buffIn;

    end
        
end
    
endmodule

// 2 x 1 Multiplexer Module 

module mux2 #(
    parameter width = 1
) (
    input [width-1:0] I0, I1,
    input S0,
    output [width-1:0] muxOut
);
    
assign muxOut = S0 ? I0 : I1;

endmodule

// 4 x 1 Multiplexer Module 

module mux4 #(
    parameter width = 1
) (
    input [width-1:0] I0, I1, I2, I3,
    input [1:0] S,
    output [width-1:0] muxOut
);
    
assign muxOut = (S == 2'b00) ? I0 :
                (S == 2'b01) ? I1 :
                (S == 2'b10) ? I2 :
                (S == 2'b11) ? I3 : {width{1'bx}};

endmodule

// 8 x 1 Multiplexer Module 

module mux5 #(
    parameter width = 1
) (
    input [width-1:0] I0, I1, I2, I3, I4,
    input [2:0] S,
    output [width-1:0] muxOut
);
    
assign muxOut = (S == 3'b000) ? I0 :
                (S == 3'b001) ? I1 :
                (S == 3'b010) ? I2 :
                (S == 3'b011) ? I3 :
                (S == 3'b100) ? I4 : {width{1'bx}};

endmodule

// Sign Extension Module

module szExt #(
    parameter width = 32,
    parameter sz = 0                    // 0 -> Sign Extension | 1 -> Zero Extension
) (
    input [width/2 - 1:0] szIn,
    output [width - 1:0] szOut
);

assign szOut = (sz) ? {{(width/2){1'b0}}, szIn} : {{(width/2){szIn[width/2 - 1]}}, szIn};
    
endmodule

// Left Shifter Module

module shifter #(
    parameter width = 32,
    parameter shiftAmt = 2
) (
    input [width/2 - 1:0] shiftIn,
    output [width-1:0] shiftOut
);

assign shiftOut = {shiftIn[width-shiftAmt-1:0],{shiftAmt{1'b0}}};
    
endmodule