`ifndef PRINT_TEST_SV
`define PRINT_TEST_SV

class print_test extends uvm_test;

  `uvm_component_utils(print_test)

  top_env m_env;

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass : print_test


function print_test::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void print_test::build_phase(uvm_phase phase);
  m_env = top_env::type_id::create("m_env", this);
endfunction : build_phase


task print_test::run_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "start test", UVM_LOW);
endtask : run_phase

`endif // PRINT_TEST_SV
