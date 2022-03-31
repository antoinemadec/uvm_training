`ifndef FIFO_OUT_CONFIG_SV
`define FIFO_OUT_CONFIG_SV

class fifo_out_config extends uvm_object;

  // Do not register config class with the factory

  virtual fifo_out_if      vif;

  uvm_active_passive_enum  is_active = UVM_ACTIVE;
  bit                      coverage_enable;
  bit                      checks_enable;

  // You can insert variables here by setting config_var in file ./fifo_out.tpl

  extern function new(string name = "");

endclass : fifo_out_config


function fifo_out_config::new(string name = "");
  super.new(name);
endfunction : new


`endif // FIFO_OUT_CONFIG_SV

