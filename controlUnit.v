module controlUnit(
    input [5:0] op, func,
    output seZE, eqNE, branch, jump,
    output memRead, memWrite, regWrite, memToReg, regDst,
    output aluSrc, startMult, multSign,
    output [1:0] outSel,
    output [3:0] aluOp
);

wire [17:0] controlSigs;

assign {memRead, memWrite, regWrite, memToReg, regDst, aluSrc, seZE, eqNE,
        branch, jump, startMult, multSign, outSel, aluOp} = controlSigs;

assign controlSigs = (op == 6'h0) ? (func == 6'h20 | func == 6'h21) ? 18'b001010000000_00_0100 :
                                    (func == 6'h22 | func == 6'h23) ? 18'b001010000000_00_1100 :
                                    (func == 6'h24) ? 18'b001010000000_00_0000 :
                                    (func == 6'h25) ? 18'b001010000000_00_0001 :
                                    (func == 6'h26) ? 18'b001010000000_00_0010 :
                                    (func == 6'h27) ? 18'b001010000000_00_0011 :
                                    (func == 6'h2a) ? 18'b001010000000_00_1101 :
                                    (func == 6'h2b) ? 18'b001010000000_00_0110 :
                                    (func == 6'h18) ? 18'b000000000011_00_0000 :
                                    (func == 6'h19) ? 18'b000000000010_00_0000 :
                                    (func == 6'h10) ? 18'b001010000000_11_0000 :
                                    (func == 6'h12) ? 18'b001010000000_10_0000 : 18'b0 :
                      (op == 6'h23) ? 18'b101101100000_00_0100 :
                      (op == 6'h2b) ? 18'b010001100000_00_0100 :
                      (op == 6'h4) ? 18'b000000111000_00_0000 :
                      (op == 6'h5) ? 18'b000000101000_00_0000 :
                      (op == 6'h8 | op == 6'h9) ? 18'b001001100000_00_0100 :
                      (op == 6'hc) ? 18'b001001000000_00_0000 :
                      (op == 6'hd) ? 18'b001001000000_00_0001 :
                      (op == 6'he) ? 18'b001001000000_00_0010 :
                      (op == 6'ha) ? 18'b001001100000_00_1101 :
                      (op == 6'hb) ? 18'b001001100000_00_0110 :
                      (op == 6'hf) ? 18'b001000000000_01_0000 :
                      (op == 6'h2) ? 18'b000000000100_00_0000 : 18'b0;

endmodule