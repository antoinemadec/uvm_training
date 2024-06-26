`ifndef FIFO_IN_MONITOR_SV
`define FIFO_IN_MONITOR_SV

class fifo_in_monitor extends uvm_monitor;

  `uvm_component_utils(fifo_in_monitor)

  virtual fifo_in_if vif;

  fifo_in_config m_config;

  uvm_analysis_port #(fifo_in_tx) analysis_port;

  fifo_in_tx m_trans;

  extern function new(string name, uvm_component parent);

  extern task run_phase(uvm_phase phase);
  extern task do_mon();

endclass : fifo_in_monitor


function fifo_in_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
  analysis_port = new("analysis_port", this);
endfunction : new


task fifo_in_monitor::run_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "run_phase", UVM_HIGH)

  m_trans = fifo_in_tx::type_id::create("m_trans");
  do_mon();
endtask : run_phase


task fifo_in_monitor::do_mon();
  forever begin
    fifo_in_tx tx;
    tx = fifo_in_tx::type_id::create("tx");
    @(vif.cb_mon);
    while (!(vif.cb_mon.data_in_vld === 1'b1 && vif.cb_mon.data_in_rdy === 1'b1)) begin
      @(vif.cb_mon);
    end
    tx.data = vif.cb_mon.data_in;
    analysis_port.write(tx);
  end
endtask : do_mon


`endif // FIFO_IN_MONITOR_SV
