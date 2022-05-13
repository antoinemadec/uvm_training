`ifndef UVM_SERVER_SV
`define UVM_SERVER_SV

class uvm_server extends uvm_component;

  `uvm_component_utils(uvm_server)

  uvm_tlm_analysis_fifo#(uvm_server_tx) m_fifo;

  uvm_server_config       m_config;
  uvm_server_monitor      m_monitor;

  extern function new(string name, uvm_component parent);

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass : uvm_server 


function  uvm_server::new(string name, uvm_component parent);
  super.new(name, parent);
  m_fifo = new("m_fifo", this);
endfunction : new


function void uvm_server::build_phase(uvm_phase phase);

  if (!uvm_config_db #(uvm_server_config)::get(this, "", "config", m_config))
    `uvm_error(get_type_name(), "uvm_server config not found")

  m_monitor     = uvm_server_monitor    ::type_id::create("m_monitor", this);

endfunction : build_phase


function void uvm_server::connect_phase(uvm_phase phase);
  if (m_config.vif == null)
    `uvm_warning(get_type_name(), "uvm_server virtual interface is not set!")

  m_monitor.vif      = m_config.vif;
  m_monitor.m_config = m_config;
  m_monitor.analysis_port.connect(m_fifo.analysis_export);

endfunction : connect_phase


task uvm_server::run_phase(uvm_phase phase);
  phase.raise_objection(this);
  fork
    forever begin
      uvm_server_tx tx;
      m_fifo.get(tx);
      `uvm_info(get_type_name(), tx.sprint(), UVM_LOW)
    end
    #100000;
  join_any
  phase.drop_objection(this);
endtask : run_phase

`endif // UVM_SERVER_SV

