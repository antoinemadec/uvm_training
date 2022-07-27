`ifndef BASIC_TEST_SV
`define BASIC_TEST_SV

class basic_test extends uvm_test;

  `uvm_component_utils(basic_test)

  top_env m_env;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass : basic_test


function basic_test::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void basic_test::build_phase(uvm_phase phase);
  m_env = top_env::type_id::create("m_env", this);
endfunction : build_phase


task basic_test::run_phase(uvm_phase phase);
  bit [31:0] data_to_uvm;
  uvm_server us = m_env.m_uvm_server;

  `uvm_info(get_type_name(), "start test", UVM_LOW);

  us.uvm_server_wait_event(16);
  `uvm_info(get_type_name(), "running sequence", UVM_LOW);
  #1000;
  `uvm_info(get_type_name(), "sequence done", UVM_LOW);
  us.uvm_server_push_data(0, 32'hdeadbeef);
  us.uvm_server_push_data(0, 32'hcafedeca);
  `uvm_info(get_type_name(), "data pushed", UVM_LOW);
  us.uvm_server_gen_event(1);
  us.uvm_server_wait_event(0);
  while (us.uvm_server_pull_data(0, data_to_uvm)) begin
    `uvm_info(get_type_name(), $sformatf("data_to_uvm = 0x%0x", data_to_uvm), UVM_LOW);
  end
endtask : run_phase

`endif // BASIC_TEST_SV
