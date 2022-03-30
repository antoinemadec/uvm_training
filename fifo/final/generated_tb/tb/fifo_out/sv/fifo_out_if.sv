`ifndef FIFO_OUT_IF_SV
`define FIFO_OUT_IF_SV

interface fifo_out_if(); 

  timeunit      1ns;
  timeprecision 1ps;

  import fifo_out_pkg::*;

  wire clk;
  wire [15:0] data_out;
  wire data_out_vld;
  wire data_out_rdy;

  clocking cb @(posedge clk);
    inout data_out;
    inout data_out_vld;
    inout data_out_rdy;
  endclocking : cb

endinterface : fifo_out_if

`endif // FIFO_OUT_IF_SV

