agent_name = fifo_out

trans_item = fifo_out_tx
trans_var  = bit[15:0] data;

# needed to have better driver/monitor template
driver_inc = dummy.sv inline
monitor_inc = dummy.sv inline

if_port    = wire clk;
if_port    = wire [15:0] data_out;
if_port    = wire data_out_vld;
if_port    = wire data_out_rdy;
if_clock   = clk
