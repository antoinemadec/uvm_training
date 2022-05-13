`ifndef UVM_SERVER_CONFIG_SV
`define UVM_SERVER_CONFIG_SV

class uvm_server_config extends uvm_object;

  // Do not register config class with the factory

  virtual uvm_server_if    vif;
                  
  // You can insert variables here by setting config_var in file ./uvm_server.tpl

  extern function new(string name = "");

endclass : uvm_server_config 


function uvm_server_config::new(string name = "");
  super.new(name);
endfunction : new


`endif // UVM_SERVER_CONFIG_SV

