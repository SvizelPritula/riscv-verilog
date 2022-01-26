module NOR(input A, input B, output Y);
assign Y = ~(A | B);
endmodule

module NOT(input A, output Y);
NOR a (.A(A), .B(A), .Y(Y));
endmodule

module BUF(input A, output Y);
wire X;
NOR a(.A(A), .Y(X));
NOR b(.A(X), .Y(Y));
endmodule