`ifndef UVM_SERVER_SV
`define UVM_SERVER_SV


class uvm_server extends uvm_component;

  `uvm_component_utils(uvm_server)

  //-----------------------------------------------------------
  // low-level API
  //-----------------------------------------------------------
  uvm_event               event_to_uvm[UVM_SERVER_EVENT_NB];
  uvm_event               event_to_sw[UVM_SERVER_EVENT_NB];
  bit [31:0]              fifo_data_to_uvm[UVM_SERVER_FIFO_NB][$];
  bit [31:0]              fifo_data_to_sw[UVM_SERVER_FIFO_NB][$];
  //-----------------------------------------------------------

  uvm_tlm_analysis_fifo#(uvm_server_tx) m_mon_fifo;

  uvm_server_config       m_config;
  uvm_server_monitor      m_monitor;
  virtual uvm_server_if   vif;

  bit                     m_quit = 0;

  extern function new(string name, uvm_component parent);

  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

  // __START_REMOVE_SECTION__
  extern task process_ram_access();
  extern task process_cmd(uvm_server_tx tx);
  extern task process_cmd_print(input int severity);
  extern task process_cmd_gen_event(bit [23:0] event_idx);
  extern task process_cmd_wait_event(bit [23:0] event_idx);
  extern task process_cmd_quit(uvm_server_tx tx);
  extern task process_fifo_data_to_uvm(uvm_server_tx tx, int fifo_idx);
  extern task process_fifo_data_to_sw(uvm_server_tx tx, int fifo_idx);
  extern task update_data_to_sw();
  extern task check_max_event_idx(bit [23:0] event_idx);
  // __END_REMOVE_SECTION__
  extern function string str_replace(string str, string pattern, string replacement);
  extern function string str_format(input string str, ref bit [31:0] q[$]);
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
  // TODO: proccess m_mon_fifo
  // __START_REMOVE_SECTION__
  fork
    update_data_to_sw();
    process_ram_access();
    wait(m_quit);
  join_any
  // __END_REMOVE_SECTION__
  phase.drop_objection(this);
endtask : run_phase


// __START_REMOVE_SECTION__
task uvm_server::process_ram_access();
    forever begin
      uvm_server_tx tx;
      m_mon_fifo.get(tx);
      if (tx.addr >= m_config.cmd_address && tx.addr <= m_config.fifo_data_to_sw_empty_address) begin
        `uvm_info(get_type_name(), {"received new packet from monitor: ", tx.sprint()}, UVM_DEBUG)
      end
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
      8'h0:  process_cmd_print(.severity(cmd_io));
      8'h1:  process_cmd_gen_event(.event_idx(cmd_io));
      8'h2:  process_cmd_wait_event(.event_idx(cmd_io));
      8'hff: process_cmd_quit(tx);
      default: begin
        `uvm_fatal(get_type_name(), $sformatf("cmd=0x%x does not exist", cmd))
      end
    endcase
  end
endtask : process_cmd


task uvm_server::process_cmd_print(input int severity);
  bit [31:0] addr;
  string str;
  int fifo_cmd_size;
  addr = fifo_data_to_uvm[UVM_SERVER_FIFO_NB-1].pop_front();
  str = str_format(vif.backdoor_get_string(addr), fifo_data_to_uvm[UVM_SERVER_FIFO_NB-1]);
  `uvm_info(get_type_name(), $sformatf("print: addr=0x%0x, str=%s", addr, str), UVM_DEBUG)
  str = {"[cpu] ", str};
  case (severity)
    0: `uvm_info(get_type_name(), str, UVM_LOW)
    1: `uvm_warning(get_type_name(), str)
    2: `uvm_error(get_type_name(), str)
    3: `uvm_fatal(get_type_name(), str)
    default: begin
      `uvm_fatal(get_type_name(), $sformatf("print severity=%0d is not defined", severity))
    end
  endcase
  fifo_cmd_size = fifo_data_to_uvm[UVM_SERVER_FIFO_NB-1].size();
  if (fifo_cmd_size != 0) begin
    `uvm_fatal(get_type_name(), $sformatf("fifo_cmd_size=%0d at the end of process_cmd_print()", fifo_cmd_size))
  end
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
    `uvm_fatal(get_type_name(), $sformatf("illegal write from SW in fifo_data_to_sw[%0d]", fifo_idx))
  end
  if (fifo_data_to_sw[fifo_idx].size() == 0) begin
    `uvm_fatal(get_type_name(), "UVM has no data to transmit to SW")
  end
  void'(fifo_data_to_sw[fifo_idx].pop_front());
endtask : process_fifo_data_to_sw


task uvm_server::update_data_to_sw();
  forever begin
    bit [31:0] fifo_data_to_sw_empty;
    @(vif.cb);
    for (int i = 0; i < UVM_SERVER_FIFO_NB; i++) begin
      fifo_data_to_sw_empty[i] = 1'b1;
      if (fifo_data_to_sw[i].size() != 0) begin
        fifo_data_to_sw_empty[i] = 1'b0;
        vif.backdoor_write(m_config.fifo_data_to_sw_address[i], fifo_data_to_sw[i][0]);
      end
    end
    vif.backdoor_write(m_config.fifo_data_to_sw_empty_address, fifo_data_to_sw_empty);
  end
endtask : update_data_to_sw


task uvm_server::check_max_event_idx(bit [23:0] event_idx);
  if (event_idx >= UVM_SERVER_EVENT_NB) begin
    `uvm_fatal(get_type_name(), $sformatf("process_cmd_gen/wait_event(%0d): max event_idx is %0d",
      event_idx, UVM_SERVER_EVENT_NB-1))
  end
endtask : check_max_event_idx
// __END_REMOVE_SECTION__


function string uvm_server::str_replace(string str, string pattern, string replacement);
  string s;
  int p_len;
  s = "";
  p_len = pattern.len();
  foreach (str[i]) begin
    s = {s, str[i]};
    if (s.substr(s.len()-p_len,s.len()-1) == pattern) begin
      s = {s.substr(0, s.len()-p_len-1), replacement};
    end
  end
  return s;
endfunction


function string uvm_server::str_format(input string str, ref bit [31:0] q[$]);
  string s;
  bit fmt_start;
  int fmt_cnt;
  fmt_start = 0;
  s = "";
  str = str_replace(str, "%%", "__pct__");
  foreach (str[i]) begin
    s = {s, str[i]};
    case (str[i])
      "%", " ", "\t", "\n": begin
        if (fmt_start && fmt_cnt > 0) begin
          s = $sformatf(s, q.pop_front());
        end
        fmt_cnt = 0;
        fmt_start = (str[i] == "%");
      end
      default: begin
        fmt_cnt ++;
      end
    endcase
  end
  if (fmt_start && fmt_cnt > 0) begin
    s = $sformatf(s, q.pop_front());
  end
  s = str_replace(s, "__pct__", "%");
  return s;
endfunction


`endif // UVM_SERVER_SV
