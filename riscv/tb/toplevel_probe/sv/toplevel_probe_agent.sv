`ifndef TOPLEVEL_PROBE_AGENT_SV
`define TOPLEVEL_PROBE_AGENT_SV

class toplevel_probe_agent extends uvm_agent;

  `uvm_component_utils(toplevel_probe_agent)

  uvm_analysis_port #(tx) analysis_port;

  toplevel_probe_config       m_config;
  toplevel_probe_sequencer_t  m_sequencer;
  toplevel_probe_driver       m_driver;
  toplevel_probe_monitor      m_monitor;

  local int m_is_active = -1;

  extern function new(string name, uvm_component parent);

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function uvm_active_passive_enum get_is_active();

endclass : toplevel_probe_agent 


function  toplevel_probe_agent::new(string name, uvm_component parent);
  super.new(name, parent);
  analysis_port = new("analysis_port", this);
endfunction : new


function void toplevel_probe_agent::build_phase(uvm_phase phase);

  if (!uvm_config_db #(toplevel_probe_config)::get(this, "", "config", m_config))
    `uvm_error(get_type_name(), "toplevel_probe config not found")

  m_monitor     = toplevel_probe_monitor    ::type_id::create("m_monitor", this);

  if (get_is_active() == UVM_ACTIVE)
  begin
    m_driver    = toplevel_probe_driver     ::type_id::create("m_driver", this);
    m_sequencer = toplevel_probe_sequencer_t::type_id::create("m_sequencer", this);
  end

endfunction : build_phase


function void toplevel_probe_agent::connect_phase(uvm_phase phase);
  if (m_config.vif == null)
    `uvm_warning(get_type_name(), "toplevel_probe virtual interface is not set!")

  m_monitor.vif      = m_config.vif;
  m_monitor.m_config = m_config;
  m_monitor.analysis_port.connect(analysis_port);

  if (get_is_active() == UVM_ACTIVE)
  begin
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    m_driver.vif      = m_config.vif;
    m_driver.m_config = m_config;
  end

endfunction : connect_phase


function uvm_active_passive_enum toplevel_probe_agent::get_is_active();
  if (m_is_active == -1)
  begin
    if (uvm_config_db#(uvm_bitstream_t)::get(this, "", "is_active", m_is_active))
    begin
      if (m_is_active != m_config.is_active)
        `uvm_warning(get_type_name(), "is_active field in config_db conflicts with config object")
    end
    else 
      m_is_active = m_config.is_active;
  end
  return uvm_active_passive_enum'(m_is_active);
endfunction : get_is_active


`endif // TOPLEVEL_PROBE_AGENT_SV

