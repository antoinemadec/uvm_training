`ifndef UVM_SW_IPC_CONFIG_SV
`define UVM_SW_IPC_CONFIG_SV

class uvm_sw_ipc_config extends uvm_object;

  // Do not register config class with the factory

  virtual uvm_sw_ipc_if    vif;

  // low-level API
  bit [31:0] fesvr_tohost_address;
  bit [31:0] cmd_address;
  bit [31:0] fesvr_arg_address[3];
  bit [31:0] fifo_data_to_uvm_address[3];
  bit [31:0] fesvr_response_address;
  bit [31:0] fifo_data_to_sw_address[3];
  bit [31:0] fifo_data_to_sw_empty_address;

  extern function new(string name = "");

endclass : uvm_sw_ipc_config


function uvm_sw_ipc_config::new(string name = "");
  super.new(name);
  fesvr_tohost_address          = 'h80000000 + 4*0;
  cmd_address                   = 'h80000000 + 4*1;
  fesvr_arg_address[0]          = 'h80000000 + 4*2;
  fesvr_arg_address[1]          = 'h80000000 + 4*3;
  fesvr_arg_address[2]          = 'h80000000 + 4*4;
  fifo_data_to_uvm_address[0]   = 'h80000000 + 4*5;
  fifo_data_to_uvm_address[1]   = 'h80000000 + 4*6;
  fifo_data_to_uvm_address[2]   = 'h80000000 + 4*7;
  fesvr_response_address        = 'h80000000 + 4*8;
  fifo_data_to_sw_address[0]    = 'h80000000 + 4*9;
  fifo_data_to_sw_address[1]    = 'h80000000 + 4*10;
  fifo_data_to_sw_address[2]    = 'h80000000 + 4*11;
  fifo_data_to_sw_empty_address = 'h80000000 + 4*12;
endfunction : new


`endif // UVM_SW_IPC_CONFIG_SV

