`ifndef TOP_TEST_SV
`define TOP_TEST_SV

class top_test extends uvm_test;

  `uvm_component_utils(top_test)

  top_env m_env;

  uvm_event m_event_to_uvm[UVM_SERVER_EVENT_NB];
  uvm_event m_event_to_sw[UVM_SERVER_EVENT_NB];

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass : top_test


function top_test::new(string name, uvm_component parent);
  uvm_event_pool event_pool = uvm_event_pool::get_global_pool();
  super.new(name, parent);
  foreach (m_event_to_uvm[i]) begin
    m_event_to_uvm[i] = event_pool.get($sformatf("uvm_server_to_uvm_%d", i));
    m_event_to_sw[i] = event_pool.get($sformatf("uvm_server_to_sw_%d", i));
  end
endfunction : new


function void top_test::build_phase(uvm_phase phase);
  m_env = top_env::type_id::create("m_env", this);
endfunction : build_phase


task top_test::run_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "start test", UVM_LOW);

  m_event_to_uvm[16].wait_on();
  m_event_to_uvm[16].reset();
  `uvm_info(get_type_name(), "running sequence", UVM_LOW);
  #1000;
  `uvm_info(get_type_name(), "sequence done", UVM_LOW);
  m_event_to_sw[1].trigger();
endtask : run_phase

`endif // TOP_TEST_SV
