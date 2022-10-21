module top_th;

  timeunit      1ns;
  timeprecision 1ps;

  bit coverage_enable = 0;

  logic clk = 0;
  logic rst;

  always #10 clk = ~clk;

  initial
  begin
    rst = 0;
    #75 rst = 1;
  end

  fifo_in_if fifo_in_if();
  fifo_out_if fifo_out_if();

  assign fifo_in_if.clk = clk;
  assign fifo_out_if.clk = clk;

  // coverage
  top_cov top_cov(
    .clk          (coverage_enable && fifo.clk ),
    .data_in_rdy  (fifo.data_in_rdy            ),
    .data_out_vld (fifo.data_out_vld           )
  );

  fifo fifo(
    .clk (clk),
    .data_in (fifo_in_if.data_in),
    .data_in_vld (fifo_in_if.data_in_vld),
    .data_in_rdy (fifo_in_if.data_in_rdy),
    .data_out (fifo_out_if.data_out),
    .data_out_vld (fifo_out_if.data_out_vld),
    .data_out_rdy (fifo_out_if.data_out_rdy)
  );

endmodule
