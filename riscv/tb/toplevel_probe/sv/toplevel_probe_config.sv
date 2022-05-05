`ifndef TOPLEVEL_PROBE_CONFIG_SV
`define TOPLEVEL_PROBE_CONFIG_SV

class toplevel_probe_config extends uvm_object;

  // Do not register config class with the factory

  virtual toplevel_probe_if vif;
                  
  uvm_active_passive_enum   is_active = UVM_ACTIVE;
  bit                       coverage_enable;       
  bit                       checks_enable;         

  // You can insert variables here by setting config_var in file ./toplevel_probe.tpl

  extern function new(string name = "");

endclass : toplevel_probe_config 


function toplevel_probe_config::new(string name = "");
  super.new(name);
endfunction : new


`endif // TOPLEVEL_PROBE_CONFIG_SV

