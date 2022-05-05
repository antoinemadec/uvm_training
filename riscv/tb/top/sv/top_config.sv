`ifndef TOP_CONFIG_SV
`define TOP_CONFIG_SV

class top_config extends uvm_object;

  // Do not register config class with the factory

  rand toplevel_probe_config  m_toplevel_probe_config;

  // You can insert variables here by setting config_var in file common.tpl

  extern function new(string name = "");

endclass : top_config 


function top_config::new(string name = "");
  super.new(name);

  m_toplevel_probe_config                 = new("m_toplevel_probe_config");
  m_toplevel_probe_config.is_active       = UVM_ACTIVE;                    
  m_toplevel_probe_config.checks_enable   = 1;                             
  m_toplevel_probe_config.coverage_enable = 1;                             

endfunction : new


`endif // TOP_CONFIG_SV

