`ifndef TOP_ENV_SV
`define TOP_ENV_SV

class top_env extends uvm_env;

  `uvm_component_utils(top_env)

  extern function new(string name, uvm_component parent);


  // Child agents
  toplevel_probe_config    m_toplevel_probe_config;  
  toplevel_probe_agent     m_toplevel_probe_agent;   
  toplevel_probe_coverage  m_toplevel_probe_coverage;

  top_config               m_config;
                
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function void end_of_elaboration_phase(uvm_phase phase);
  extern task          run_phase(uvm_phase phase);

endclass : top_env 


function top_env::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void top_env::build_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "In build_phase", UVM_HIGH)

  if (!uvm_config_db #(top_config)::get(this, "", "config", m_config)) 
    `uvm_error(get_type_name(), "Unable to get top_config")

  m_toplevel_probe_config = m_config.m_toplevel_probe_config;

  uvm_config_db #(toplevel_probe_config)::set(this, "m_toplevel_probe_agent", "config", m_toplevel_probe_config);
  if (m_toplevel_probe_config.is_active == UVM_ACTIVE )
    uvm_config_db #(toplevel_probe_config)::set(this, "m_toplevel_probe_agent.m_sequencer", "config", m_toplevel_probe_config);
  uvm_config_db #(toplevel_probe_config)::set(this, "m_toplevel_probe_coverage", "config", m_toplevel_probe_config);


  m_toplevel_probe_agent    = toplevel_probe_agent   ::type_id::create("m_toplevel_probe_agent", this);
  m_toplevel_probe_coverage = toplevel_probe_coverage::type_id::create("m_toplevel_probe_coverage", this);

endfunction : build_phase


function void top_env::connect_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "In connect_phase", UVM_HIGH)

  m_toplevel_probe_agent.analysis_port.connect(m_toplevel_probe_coverage.analysis_export);


endfunction : connect_phase


function void top_env::end_of_elaboration_phase(uvm_phase phase);
  uvm_factory factory = uvm_factory::get();
  `uvm_info(get_type_name(), "Information printed from top_env::end_of_elaboration_phase method", UVM_MEDIUM)
  `uvm_info(get_type_name(), $sformatf("Verbosity threshold is %d", get_report_verbosity_level()), UVM_MEDIUM)
  uvm_top.print_topology();
  factory.print();
endfunction : end_of_elaboration_phase


task top_env::run_phase(uvm_phase phase);
  top_default_seq vseq;
  vseq = top_default_seq::type_id::create("vseq");
  vseq.set_item_context(null, null);
  if ( !vseq.randomize() )
    `uvm_fatal(get_type_name(), "Failed to randomize virtual sequence")
  vseq.m_toplevel_probe_agent = m_toplevel_probe_agent;
  vseq.m_config               = m_config;              
  vseq.set_starting_phase(phase);
  vseq.start(null);

endtask : run_phase


`endif // TOP_ENV_SV

