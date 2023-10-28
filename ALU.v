module ALU #(
    parameter width = 32
) (
    input [width-1:0] aluIn1, aluIn2,
    input [3:0] aluFunc,
    output [width-1:0] aluOut
);

wire [width-1:0] signAluIn2, sum;
wire cOut, sltu;

assign signAluIn2 = (aluFunc[3]) ? ~aluIn2 : aluIn2;
assign {cOut, sum} = aluFunc[3] + aluIn1 + signAluIn2;
assign sltu = (aluIn1 < signAluIn2) ? 1'b1 : 1'b0;

assign aluOut = (aluFunc[2:0] == 3'b000) ? aluIn1 & signAluIn2 :    // AND
                (aluFunc[2:0] == 3'b001) ? aluIn1 | signAluIn2 :    // OR
                (aluFunc[2:0] == 3'b010) ? aluIn1 ^ signAluIn2 :    // XOR
                (aluFunc[2:0] == 3'b011) ? aluIn1 ~^ signAluIn2 :   // XNOR
                (aluFunc[2:0] == 3'b100) ? sum :                    // ADD, ADDU, SUB, SUBU
                (aluFunc[2:0] == 3'b101) ? {31'b0, sum[31]} :       // SLT
                (aluFunc[2:0] == 3'b110) ? {31'b0, sltu} :          // SLTU
                32'hx;                                              // Default

endmodule