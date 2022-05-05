`ifndef TOPLEVEL_PROBE_COVERAGE_SV
`define TOPLEVEL_PROBE_COVERAGE_SV

class toplevel_probe_coverage extends uvm_subscriber #(tx);

  `uvm_component_utils(toplevel_probe_coverage)

  toplevel_probe_config m_config;    
  bit                   m_is_covered;
  tx                    m_item;
     
  covergroup m_cov;
    option.per_instance = 1;
    // You may insert additional coverpoints here ...

    cp_rwb: coverpoint m_item.rwb;
    //  Add bins here if required

    cp_data: coverpoint m_item.data;
    //  Add bins here if required

    cp_byte_en: coverpoint m_item.byte_en;
    //  Add bins here if required

  endgroup

  extern function new(string name, uvm_component parent);
  extern function void write(input tx t);
  extern function void build_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

endclass : toplevel_probe_coverage 


function toplevel_probe_coverage::new(string name, uvm_component parent);
  super.new(name, parent);
  m_is_covered = 0;
  m_cov = new();
endfunction : new


function void toplevel_probe_coverage::write(input tx t);
  if (m_config.coverage_enable)
  begin
    m_item = t;
    m_cov.sample();
    // Check coverage - could use m_cov.option.goal instead of 100 if your simulator supports it
    if (m_cov.get_inst_coverage() >= 100) m_is_covered = 1;
  end
endfunction : write


function void toplevel_probe_coverage::build_phase(uvm_phase phase);
  if (!uvm_config_db #(toplevel_probe_config)::get(this, "", "config", m_config))
    `uvm_error(get_type_name(), "toplevel_probe config not found")
endfunction : build_phase


function void toplevel_probe_coverage::report_phase(uvm_phase phase);
  if (m_config.coverage_enable)
    `uvm_info(get_type_name(), $sformatf("Coverage score = %3.1f%%", m_cov.get_inst_coverage()), UVM_MEDIUM)
  else
    `uvm_info(get_type_name(), "Coverage disabled for this agent", UVM_MEDIUM)
endfunction : report_phase


`endif // TOPLEVEL_PROBE_COVERAGE_SV

