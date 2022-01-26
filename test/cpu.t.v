module cpu_test();

reg clk;
reg rst;
wire [31:0] memory_in;
wire [31:0] memory_out;
wire [31:2] address;
wire [3:0] write_enable;
wire write_capable;
wire read_capable;

cpu cpu(
  .clk(clk),
  .rst(rst),
  .memory_out(memory_out),
  .memory_in(memory_in),
  .address(address),
  .write_enable(write_enable),
  .read_capable(read_capable),
  .write_capable(write_capable)
);

memory memory (
  .clk(clk),
  .memory_out(memory_out),
  .memory_in(memory_in),
  .address(address),
  .write_enable(write_enable),
  .read_capable(read_capable),
  .write_capable(write_capable)
);

initial begin
  rst = 1;
  clk = 0;
  #10;
  clk = 1;
  #10;
  rst = 0;
  clk = 0;
  #10;

  forever begin
    #10 clk = 1;
    // $display("%h %b - %h %b - %h %b (%b)", address, address, memory_out, memory_out, memory_in, memory_in, write_enable);
    #10 clk = 0;
  end
end

endmodule