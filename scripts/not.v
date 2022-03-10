(*blackbox*) module NOR(input A, input B, output Y);
endmodule

module NOT(input A, output Y);
NOR a (.A(A), .B(A), .Y(Y));
endmodule

module BUF(input A, output Y);
wire X;
NOT a(.A(A), .Y(X));
NOT b(.A(X), .Y(Y));
endmodule
