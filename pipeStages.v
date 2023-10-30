module fetch #(
    parameter width = 32
) (

);
    
endmodule


module decode #(
    parameter width = 32
) (
    
);
    
endmodule


module execute #(
    parameter width = 32
) (
    
);
    
endmodule


module memory #(
    parameter width = 32
) (
    
);
    
endmodule


module writeBack #(
    parameter width = 32
) (
    
    input clk, reset, stall_W, flush_W,
    input [102:0] buffIn_W,

    output regWrite_W,
    output [4:0] writeReg_W,
    output [width-1:0] result_W

);

wire memToReg_W;
wire [width-1:0] out_W, readData_W;
wire [width-1:0] instr_W;
wire [102:0] buffOut_W;

assign {regWrite_W, memToReg_W, readdataW, out_W, writeReg_W, instr_W} = buffOut_W;

pipeBuffer#(103) writeBuffer(clk, reset, stall_W, flush_W, buffIn_W, buffOut_W);

mux2#(32) memToReg_mux_W(out_W, readData_W, memToReg_W, result_W);
    
endmodule