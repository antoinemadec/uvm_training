`ifndef UVM_SERVER_CONFIG_SV
`define UVM_SERVER_CONFIG_SV

class uvm_server_config extends uvm_object;

  // Do not register config class with the factory

  virtual uvm_server_if    vif;
                  
  bit [31:0] cmd_address              = 'h80000000;
  bit [31:0] fifo_cmd_input_address   = 'h80000004;
  bit [31:0] fifo_cmd_output_address  = 'h80000008;
  bit [31:0] fifo_data_to_uvm_address = 'h8000000c;
  bit [31:0] fifo_data_to_sw_address  = 'h80000010;

  extern function new(string name = "");

endclass : uvm_server_config 


function uvm_server_config::new(string name = "");
  super.new(name);
endfunction : new


`endif // UVM_SERVER_CONFIG_SV

