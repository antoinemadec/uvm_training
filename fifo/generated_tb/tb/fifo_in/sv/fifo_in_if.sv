`ifndef FIFO_IN_IF_SV
`define FIFO_IN_IF_SV

interface fifo_in_if();

  timeunit      1ns;
  timeprecision 1ps;

  import fifo_in_pkg::*;

  wire clk;
  wire [31:0] data_in;
  wire data_in_vld;
  wire data_in_rdy;

  clocking cb @(posedge clk);
    inout data_in;
    inout data_in_vld;
    inout data_in_rdy;
  endclocking : cb

endinterface : fifo_in_if

`endif // FIFO_IN_IF_SV

