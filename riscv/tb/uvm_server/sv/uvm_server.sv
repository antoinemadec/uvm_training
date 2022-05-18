`ifndef UVM_SERVER_SV
`define UVM_SERVER_SV

class uvm_server extends uvm_component;

  `uvm_component_utils(uvm_server)

  uvm_tlm_analysis_fifo#(uvm_server_tx) m_mon_fifo;

  uvm_server_config       m_config;
  uvm_server_monitor      m_monitor;
  virtual uvm_server_if   vif;

  uvm_event               m_event_to_uvm[UVM_SERVER_EVENT_NB];
  uvm_event               m_event_to_sw[UVM_SERVER_EVENT_NB];
  bit                     m_quit = 0;
  bit [31:0]              fifo_cmd_input[$];
  bit [31:0]              fifo_cmd_output[$];
  bit [31:0]              fifo_data_to_uvm[$];
  bit [31:0]              fifo_data_to_sw[$];

  extern function new(string name, uvm_component parent);

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

  extern task process_cmd(uvm_server_tx tx);
  extern task process_cmd_print(uvm_server_tx tx);
  extern task process_cmd_gen_event(bit [23:0] event_idx);
  extern task process_cmd_wait_event(bit [23:0] event_idx);
  extern task process_cmd_quit(uvm_server_tx tx);

  extern task process_fifo_cmd_input(uvm_server_tx tx);
  extern task process_fifo_cmd_output(uvm_server_tx tx);
  extern task process_fifo_data_to_uvm(uvm_server_tx tx);
  extern task process_fifo_data_to_sw(uvm_server_tx tx);

  extern task check_max_event_idx(bit [23:0] event_idx);
endclass : uvm_server 


function  uvm_server::new(string name, uvm_component parent);
  uvm_event_pool event_pool = uvm_event_pool::get_global_pool();
  super.new(name, parent);
  m_mon_fifo = new("m_mon_fifo", this);
  foreach (m_event_to_uvm[i]) begin
    m_event_to_uvm[i] = event_pool.get($sformatf("uvm_server_to_uvm_%d", i));
    m_event_to_sw[i] = event_pool.get($sformatf("uvm_server_to_sw_%d", i));
  end
endfunction : new


function void uvm_server::build_phase(uvm_phase phase);
  if (!uvm_config_db #(uvm_server_config)::get(this, "", "config", m_config))
    `uvm_error(get_type_name(), "uvm_server config not found")

  m_monitor = uvm_server_monitor::type_id::create("m_monitor", this);
endfunction : build_phase


function void uvm_server::connect_phase(uvm_phase phase);
  if (m_config.vif == null)
    `uvm_warning(get_type_name(), "uvm_server virtual interface is not set!")

  vif                = m_config.vif;
  m_monitor.vif      = m_config.vif;
  m_monitor.m_config = m_config;
  m_monitor.analysis_port.connect(m_mon_fifo.analysis_export);
endfunction : connect_phase


task uvm_server::run_phase(uvm_phase phase);
  phase.raise_objection(this);
  fork
    forever begin
      uvm_server_tx tx;
      m_mon_fifo.get(tx);
      `uvm_info(get_type_name(), {"received new packet from monitor: ", tx.sprint()}, UVM_DEBUG)
      case (tx.addr)
        m_config.cmd_address:              process_cmd(tx);
        m_config.fifo_cmd_input_address:   process_fifo_cmd_input(tx);
        m_config.fifo_cmd_output_address:  process_fifo_cmd_output(tx);
        m_config.fifo_data_to_uvm_address: process_fifo_data_to_uvm(tx);
        m_config.fifo_data_to_sw_address:  process_fifo_data_to_sw(tx);
      endcase
    end
    wait(m_quit);
  join_any
  phase.drop_objection(this);
endtask : run_phase


task uvm_server::process_cmd(uvm_server_tx tx);
  bit [7:0] cmd;
  bit [23:0] cmd_io;
  {cmd_io, cmd} = tx.data;
  if (tx.rwb == 0) begin
    case (cmd)
      8'h0:  process_cmd_print(tx);
      8'h1:  process_cmd_gen_event(.event_idx(cmd_io));
      8'h2:  process_cmd_wait_event(.event_idx(cmd_io));
      8'hff: process_cmd_quit(tx);
      default: begin
        `uvm_fatal(get_type_name(), $sformatf("cmd=0x%x does not exist", cmd))
      end
    endcase
  end
endtask : process_cmd


task uvm_server::process_cmd_print(uvm_server_tx tx);
  `uvm_info(get_type_name(), "print", UVM_LOW)
endtask : process_cmd_print


task uvm_server::process_cmd_gen_event(bit [23:0] event_idx);
  `uvm_info(get_type_name(), $sformatf("process_cmd_gen_event(%0d)", event_idx), UVM_DEBUG)
  check_max_event_idx(event_idx);
  m_event_to_uvm[event_idx].trigger();
endtask : process_cmd_gen_event


task uvm_server::process_cmd_wait_event(bit [23:0] event_idx);
  `uvm_info(get_type_name(), $sformatf("process_cmd_wait_event(%0d) start", event_idx), UVM_DEBUG)
  check_max_event_idx(event_idx);

  m_event_to_sw[event_idx].wait_on();
  m_event_to_sw[event_idx].reset();
  vif.backdoor_write(m_config.cmd_address, 0);

  `uvm_info(get_type_name(), $sformatf("process_cmd_wait_event(%0d) done", event_idx), UVM_DEBUG)
endtask : process_cmd_wait_event


task uvm_server::process_cmd_quit(uvm_server_tx tx);
  `uvm_info(get_type_name(), "end of simulation", UVM_LOW)
  m_quit = 1;
endtask : process_cmd_quit


task uvm_server::process_fifo_cmd_input(uvm_server_tx tx);
  if (tx.rwb) begin
    `uvm_fatal(get_type_name(), "illegal read from SW in fifo_cmd_input")
  end
  fifo_cmd_input.push_back(tx.data);
endtask : process_fifo_cmd_input


task uvm_server::process_fifo_cmd_output(uvm_server_tx tx);
  bit [31:0] cmd_output;
  if (!tx.rwb) begin
    `uvm_fatal(get_type_name(), "illegal write in SW in fifo_cmd_output")
  end
  cmd_output = fifo_cmd_output.pop_front();
  // TODO: write cmd_output in SW mem
endtask : process_fifo_cmd_output


task uvm_server::process_fifo_data_to_uvm(uvm_server_tx tx);
  if (tx.rwb) begin
    `uvm_fatal(get_type_name(), "illegal read from SW in fifo_data_to_uvm")
  end
  fifo_cmd_input.push_back(tx.data);
endtask : process_fifo_data_to_uvm


task uvm_server::process_fifo_data_to_sw(uvm_server_tx tx);
  bit [31:0] data_to_sw;
  if (!tx.rwb) begin
    `uvm_fatal(get_type_name(), "illegal write in SW in fifo_data_to_sw")
  end
  data_to_sw = fifo_cmd_output.pop_front();
  // TODO: write data_to_sw in SW mem
endtask : process_fifo_data_to_sw


task uvm_server::check_max_event_idx(bit [23:0] event_idx);
  if (event_idx >= UVM_SERVER_EVENT_NB) begin
    `uvm_fatal(get_type_name(), $sformatf("process_cmd_gen/wait_event(%0d): max event_idx is %0d",
      event_idx, UVM_SERVER_EVENT_NB-1))
  end
endtask : check_max_event_idx

`endif // UVM_SERVER_SV
