`ifndef TOP_TEST_SV
`define TOP_TEST_SV

  // ___________________________________________________________________________________________
  //             C-side                              |              UVM-side
  // ________________________________________________|__________________________________________
  // uvm_server_gen_event(0)                      ---|-->   uvm_server_wait_event(0)
  // uvm_server_wait_event(16)                    <--|---   uvm_server_gen_event(16)
  // uvm_server_push_data(0, 0xdeadbeef)          ---|-->   uvm_server_pull_data(0, data)
  // uvm_server_pull_data(1 , &data)              <--|---   uvm_server_push_data(1, data)
  // uvm_server_print_info(1, "data=0x%0x", data) ---|-->   `uvm_info(...)
  // uvm_server_quit()                            ---|-->   end of simulation

class top_test extends uvm_test;

  `uvm_component_utils(top_test)

  top_env m_env;

  //-----------------------------------------------------------
  // high-level API
  //-----------------------------------------------------------
  extern task uvm_server_gen_event(int event_idx);
  extern task uvm_server_wait_event(int event_idx);
  extern function void uvm_server_push_data(input int fifo_idx, input [31:0] data);
  extern function bit  uvm_server_pull_data(input int fifo_idx, output [31:0] data);
  //-----------------------------------------------------------

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass : top_test


function top_test::new(string name, uvm_component parent);
  uvm_event_pool event_pool = uvm_event_pool::get_global_pool();
  super.new(name, parent);
endfunction : new


function void top_test::build_phase(uvm_phase phase);
  m_env = top_env::type_id::create("m_env", this);
endfunction : build_phase


task top_test::uvm_server_gen_event(int event_idx);
  m_env.m_uvm_server.event_to_sw[event_idx].trigger();
endtask : uvm_server_gen_event


task top_test::uvm_server_wait_event(int event_idx);
  m_env.m_uvm_server.event_to_uvm[event_idx].wait_on();
  m_env.m_uvm_server.event_to_uvm[event_idx].reset();
endtask : uvm_server_wait_event


function void top_test::uvm_server_push_data(input int fifo_idx, input [31:0] data);
  m_env.m_uvm_server.fifo_data_to_sw[fifo_idx].push_back(data);
endfunction : uvm_server_push_data


function bit top_test::uvm_server_pull_data(input int fifo_idx, output [31:0] data);
  if (m_env.m_uvm_server.fifo_data_to_uvm[fifo_idx].size() == 0) begin
    return 0;
  end
  data = m_env.m_uvm_server.fifo_data_to_uvm[fifo_idx].pop_front();
  return 1;
endfunction : uvm_server_pull_data


task top_test::run_phase(uvm_phase phase);
  bit [31:0] data_to_uvm;

  `uvm_info(get_type_name(), "start test", UVM_LOW);

  uvm_server_wait_event(16);
  `uvm_info(get_type_name(), "running sequence", UVM_LOW);
  #1000;
  `uvm_info(get_type_name(), "sequence done", UVM_LOW);
  uvm_server_push_data(0, 32'hdeadbeef);
  uvm_server_push_data(0, 32'hcafedeca);
  `uvm_info(get_type_name(), "data pushed", UVM_LOW);
  uvm_server_gen_event(1);
  uvm_server_wait_event(0);
  while (uvm_server_pull_data(0, data_to_uvm)) begin
    `uvm_info(get_type_name(), $sformatf("data_to_uvm = 0x%0x", data_to_uvm), UVM_LOW);
  end
endtask : run_phase

`endif // TOP_TEST_SV
