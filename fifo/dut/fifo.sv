module fifo (
  input clk,
  // data_in
  input [31:0]        data_in,
  input               data_in_vld,
  output logic        data_in_rdy,
  // data_out
  output logic [15:0] data_out,
  output logic        data_out_vld,
  input               data_out_rdy
);

  localparam FIFO16_SIZE = 8;

  bit [15:0] q16[$];

  always_ff @(posedge clk) begin
    if (data_in_vld && data_in_rdy) begin
      q16.push_back(data_in[31:16]);
      q16.push_back(data_in[15:0]);
    end
    if (data_out_vld && data_out_rdy) begin
      void'(q16.pop_front());
    end
    if (q16.size() <= (FIFO16_SIZE - 2)) begin
      data_in_rdy = 1;
    end else begin
      data_in_rdy = 0;
    end
    if (q16.size() > 0) begin
      data_out = q16[0];
      data_out_vld = 1;
    end else begin
      data_out = 1'bX;
      data_out_vld = 0;
    end
  end

endmodule
