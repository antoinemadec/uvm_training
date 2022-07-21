`ifndef TOP_COV_SV
  `define TOP_COV_SV

  module top_cov(
    input clk,
    input data_in_rdy,
    input data_out_vld
  );

    sequence full_empty_full;
      @(posedge clk) !data_in_rdy ##[1:$] !data_out_vld ##[1:$] !data_in_rdy;
    endsequence

    sequence empty_full_empty;
      @(posedge clk) !data_out_vld ##[1:$] !data_in_rdy ##[1:$] !data_out_vld;
    endsequence

    cp_empty_full_empty: cover property(empty_full_empty);
    cp_full_empty_full: cover property(full_empty_full);

  endmodule : top_cov

`endif // TOP_COV_SV

