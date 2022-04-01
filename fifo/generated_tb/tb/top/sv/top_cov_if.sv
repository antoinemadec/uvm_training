`ifndef TOP_COV_IF_SV
`define TOP_COV_IF_SV

interface top_cov_if();

  timeunit      1ns;
  timeprecision 1ps;

  import top_pkg::*;

  wire clk;
  wire [31:0] data_in;
  wire data_in_vld;
  wire data_in_rdy;
  wire [31:0] data_out;
  wire data_out_vld;
  wire data_out_rdy;

  property full_empty_full;
    @(posedge clk) !data_in_rdy ##[1:$] !data_out_vld ##[1:$] !data_in_rdy;
  endproperty

  property empty_full_empty;
    @(posedge clk) !data_out_vld ##[1:$] !data_in_rdy ##[1:$] !data_out_vld;
  endproperty

  cp_empty_full_empty: cover property(empty_full_empty);
  cp_full_empty_full: cover property(full_empty_full);

endinterface : top_cov_if

`endif // TOP_COV_IF_SV

