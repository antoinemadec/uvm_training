module top_th;

  timeunit      1ns;
  timeprecision 1ps;

  bit coverage_enable = 0;

  // Example clock and reset declarations
  logic clk = 0;
  logic reset;

  // Example clock generator process
  always #10 clk = ~clk;

  // Example reset generator process
  initial
  begin
    reset = 0;         // Active low reset in this example
    #75 reset = 1;
  end

  assign fifo_in_if_0.clk  = clk;
  assign fifo_out_if_0.clk = clk;
  assign top_cov_if_0.clk  = coverage_enable & clk;

  // Pin-level interfaces connected to DUT
  fifo_in_if   fifo_in_if_0 ();
  fifo_out_if  fifo_out_if_0 ();

  // for coverage purposes
  top_cov_if   top_cov_if_0 ();
  assign top_cov_if_0.data_in      = fifo.data_in;
  assign top_cov_if_0.data_in_vld  = fifo.data_in_vld;
  assign top_cov_if_0.data_in_rdy  = fifo.data_in_rdy;
  assign top_cov_if_0.data_out     = fifo.data_out;
  assign top_cov_if_0.data_out_vld = fifo.data_out_vld;
  assign top_cov_if_0.data_out_rdy = fifo.data_out_rdy;

  fifo fifo (
    .clk         (clk),
    .data_in     (fifo_in_if_0.data_in),
    .data_in_vld (fifo_in_if_0.data_in_vld),
    .data_in_rdy (fifo_in_if_0.data_in_rdy),
    .data_out    (fifo_out_if_0.data_out),
    .data_out_vld(fifo_out_if_0.data_out_vld),
    .data_out_rdy(fifo_out_if_0.data_out_rdy)
  );

endmodule

