`ifndef TOP_TEST_SV
`define TOP_TEST_SV

class top_test extends uvm_test;

  `uvm_component_utils(top_test)

  top_env m_env;

  // uvm_server
  uvm_event   event_to_uvm[UVM_SERVER_EVENT_NB];
  uvm_event   event_to_sw[UVM_SERVER_EVENT_NB];
  extern function void push_to_sw(int fifo_idx, bit [31:0] data);
  extern function bit pull_from_sw(input int fifo_idx, output [31:0] data);

  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass : top_test


function top_test::new(string name, uvm_component parent);
  uvm_event_pool event_pool = uvm_event_pool::get_global_pool();
  super.new(name, parent);
endfunction : new


function void top_test::connect_phase(uvm_phase phase);
  event_to_uvm = m_env.m_uvm_server.event_to_uvm;
  event_to_sw  = m_env.m_uvm_server.event_to_sw;
endfunction : connect_phase


function void top_test::build_phase(uvm_phase phase);
  m_env = top_env::type_id::create("m_env", this);
endfunction : build_phase


function void top_test::push_to_sw(int fifo_idx, bit [31:0] data);
  m_env.m_uvm_server.fifo_data_to_sw[fifo_idx].push_back(data);
endfunction : push_to_sw


function bit top_test::pull_from_sw(input int fifo_idx, output [31:0] data);
  if (m_env.m_uvm_server.fifo_data_to_uvm[fifo_idx].size() == 0) begin
    return 0;
  end
  data = m_env.m_uvm_server.fifo_data_to_uvm[fifo_idx].pop_front();
  return 1;
endfunction : pull_from_sw


task top_test::run_phase(uvm_phase phase);
  bit [31:0] data_to_uvm;

  `uvm_info(get_type_name(), "start test", UVM_LOW);

  event_to_uvm[16].wait_on();
  event_to_uvm[16].reset();
  `uvm_info(get_type_name(), "running sequence", UVM_LOW);
  #1000;
  `uvm_info(get_type_name(), "sequence done", UVM_LOW);
  push_to_sw(0, 32'hdeadbeef);
  push_to_sw(0, 32'hcafedeca);
  `uvm_info(get_type_name(), "data pushed", UVM_LOW);
  event_to_sw[1].trigger();
  event_to_uvm[0].wait_on();
  event_to_uvm[0].reset();
  while (pull_from_sw(0, data_to_uvm)) begin
    `uvm_info(get_type_name(), $sformatf("data_to_uvm = 0x%0x", data_to_uvm), UVM_LOW);
  end
endtask : run_phase

`endif // TOP_TEST_SV
