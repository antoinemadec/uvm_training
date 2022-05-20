`ifndef UVM_SERVER_CONFIG_SV
`define UVM_SERVER_CONFIG_SV

class uvm_server_config extends uvm_object;

  // Do not register config class with the factory

  virtual uvm_server_if    vif;
                  
  bit [31:0] cmd_address;
  bit [31:0] fifo_data_to_uvm_address[UVM_SERVER_FIFO_NB];
  bit [31:0] fifo_data_to_sw_address[UVM_SERVER_FIFO_NB];

  extern function new(string name = "");

endclass : uvm_server_config 


function uvm_server_config::new(string name = "");
  super.new(name);
  cmd_address = 'h80000000;
  for (int i = 0; i < UVM_SERVER_FIFO_NB; i++) begin
    fifo_data_to_uvm_address[i] = 'h80000004 + i*4;
    fifo_data_to_sw_address[i]  = 'h80000004 + (UVM_SERVER_FIFO_NB + i)*4;
  end
endfunction : new


`endif // UVM_SERVER_CONFIG_SV

