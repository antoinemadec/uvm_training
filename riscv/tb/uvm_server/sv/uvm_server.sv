`ifndef UVM_SERVER_SV
`define UVM_SERVER_SV

class uvm_server extends uvm_component;

  `uvm_component_utils(uvm_server)

  // external
  uvm_event               event_to_uvm[UVM_SERVER_EVENT_NB];
  uvm_event               event_to_sw[UVM_SERVER_EVENT_NB];
  bit [31:0]              fifo_data_to_uvm[UVM_SERVER_FIFO_NB][$];
  bit [31:0]              fifo_data_to_sw[UVM_SERVER_FIFO_NB][$];

  uvm_tlm_analysis_fifo#(uvm_server_tx) m_mon_fifo;

  uvm_server_config       m_config;
  uvm_server_monitor      m_monitor;
  virtual uvm_server_if   vif;

  bit                     m_quit = 0;

  extern function new(string name, uvm_component parent);

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

  extern task process_ram_access();
  extern task process_cmd(uvm_server_tx tx);
  extern task process_cmd_print(uvm_server_tx tx);
  extern task process_cmd_gen_event(bit [23:0] event_idx);
  extern task process_cmd_wait_event(bit [23:0] event_idx);
  extern task process_cmd_quit(uvm_server_tx tx);
  extern task process_fifo_data_to_uvm(uvm_server_tx tx, int fifo_idx);
  extern task process_fifo_data_to_sw(uvm_server_tx tx, int fifo_idx);
  extern task update_data_to_sw();
  extern task update_data_to_sw_core(int fifo_idx);
  extern task check_max_event_idx(bit [23:0] event_idx);
endclass : uvm_server 


function  uvm_server::new(string name, uvm_component parent);
  uvm_event_pool event_pool = uvm_event_pool::get_global_pool();
  super.new(name, parent);
  m_mon_fifo = new("m_mon_fifo", this);
  foreach (event_to_uvm[i]) begin
    event_to_uvm[i] = event_pool.get($sformatf("uvm_server_to_uvm_%d", i));
    event_to_sw[i] = event_pool.get($sformatf("uvm_server_to_sw_%d", i));
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
    update_data_to_sw();
    process_ram_access();
    wait(m_quit);
  join_any
  phase.drop_objection(this);
endtask : run_phase


task uvm_server::process_ram_access();
    forever begin
      uvm_server_tx tx;
      m_mon_fifo.get(tx);
      `uvm_info(get_type_name(), {"received new packet from monitor: ", tx.sprint()}, UVM_DEBUG)
      if (tx.addr == m_config.cmd_address) begin
        process_cmd(tx);
      end
      else begin
        for (int i = 0; i < UVM_SERVER_FIFO_NB; i++) begin
          if (tx.addr == m_config.fifo_data_to_uvm_address[i]) begin
            process_fifo_data_to_uvm(tx, i);
          end
          if (tx.addr == m_config.fifo_data_to_sw_address[i]) begin
            process_fifo_data_to_sw(tx, i);
          end
        end
      end
    end
endtask : process_ram_access


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
  event_to_uvm[event_idx].trigger();
endtask : process_cmd_gen_event


task uvm_server::process_cmd_wait_event(bit [23:0] event_idx);
  `uvm_info(get_type_name(), $sformatf("process_cmd_wait_event(%0d) start", event_idx), UVM_DEBUG)
  check_max_event_idx(event_idx);

  event_to_sw[event_idx].wait_on();
  event_to_sw[event_idx].reset();
  vif.backdoor_write(m_config.cmd_address, 0);

  `uvm_info(get_type_name(), $sformatf("process_cmd_wait_event(%0d) done", event_idx), UVM_DEBUG)
endtask : process_cmd_wait_event


task uvm_server::process_cmd_quit(uvm_server_tx tx);
  `uvm_info(get_type_name(), "end of simulation", UVM_LOW)
  m_quit = 1;
endtask : process_cmd_quit


task uvm_server::process_fifo_data_to_uvm(uvm_server_tx tx, int fifo_idx);
  if (tx.rwb) begin
    `uvm_fatal(get_type_name(), $sformatf("illegal read from SW in fifo_data_to_uvm[%0d]", fifo_idx))
  end
  fifo_data_to_uvm[fifo_idx].push_back(tx.data);
endtask : process_fifo_data_to_uvm


task uvm_server::process_fifo_data_to_sw(uvm_server_tx tx, int fifo_idx);
  if (!tx.rwb) begin
    `uvm_fatal(get_type_name(), $sformatf("illegal write in SW in fifo_data_to_sw[%0d]", fifo_idx))
  end
  if (fifo_data_to_sw[fifo_idx].size() == 0) begin
    `uvm_fatal(get_type_name(), "UVM has no data to transmit to SW")
  end
  void'(fifo_data_to_sw[fifo_idx].pop_front());
endtask : process_fifo_data_to_sw


task uvm_server::update_data_to_sw();
  for (int i = 0; i < UVM_SERVER_FIFO_NB; i++) begin
    fork
      automatic int auto_i = i;
      update_data_to_sw_core(auto_i);
    join_none
  end
  wait fork;
endtask : update_data_to_sw


task uvm_server::update_data_to_sw_core(int fifo_idx);
  int fifo_to_sw_prev_size = 0;
  forever begin
    @(vif.cb);
    if (fifo_data_to_sw[fifo_idx].size() != fifo_to_sw_prev_size) begin
      // TODO: only when 0 to 1 or size is decreasing
      if (fifo_data_to_sw[fifo_idx].size() != 0) begin
        vif.backdoor_write(m_config.fifo_data_to_sw_address[fifo_idx], fifo_data_to_sw[fifo_idx][0]);
      end
      fifo_to_sw_prev_size = fifo_data_to_sw[fifo_idx].size();
    end
  end
endtask : update_data_to_sw_core


task uvm_server::check_max_event_idx(bit [23:0] event_idx);
  if (event_idx >= UVM_SERVER_EVENT_NB) begin
    `uvm_fatal(get_type_name(), $sformatf("process_cmd_gen/wait_event(%0d): max event_idx is %0d",
      event_idx, UVM_SERVER_EVENT_NB-1))
  end
endtask : check_max_event_idx

`endif // UVM_SERVER_SV
