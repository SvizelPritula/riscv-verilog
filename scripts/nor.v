module NOR(input A, input B, output Y);
assign Y = ~(A | B);
endmodule