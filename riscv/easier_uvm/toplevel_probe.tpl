agent_name = toplevel_probe

trans_item = tx
trans_var  = bit[31:0] rwb;
trans_var  = bit[31:0] data;
trans_var  = bit[3:0] byte_en;

# needed to have better driver/monitor template
driver_inc = dummy.sv inline
monitor_inc = dummy.sv inline

if_port    = wire clock;
if_port    = wire reset;
if_port    = wire [31:0] bus_read_data;
if_port    = wire [31:0] bus_address;
if_port    = wire [31:0] bus_write_data;
if_port    = wire [3:0]  bus_byte_enable;
if_port    = wire        bus_read_enable;
if_port    = wire        bus_write_enable;
if_clock   = clock
if_reset   = reset
