`ifndef FIFO_IN_DRIVER_SV
`define FIFO_IN_DRIVER_SV

class fifo_in_driver extends uvm_driver #(fifo_in_tx);

  `uvm_component_utils(fifo_in_driver)

  virtual fifo_in_if vif;

  fifo_in_config m_config;

  extern function new(string name, uvm_component parent);

  extern task run_phase(uvm_phase phase);
  extern task do_drive();

endclass : fifo_in_driver


function fifo_in_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


task fifo_in_driver::run_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "run_phase", UVM_HIGH)

  vif.cb_drv.data_in <= 'hx;
  vif.cb_drv.data_in_vld <= 1'b0;
  @(vif.cb_drv);

  forever
  begin
    seq_item_port.get_next_item(req);
    `uvm_info(get_type_name(), {"req item\n",req.sprint}, UVM_DEBUG)
    do_drive();
    seq_item_port.item_done();
  end
endtask : run_phase


task fifo_in_driver::do_drive();
  repeat (get_delay(req.rate)) begin
    @(vif.cb_drv);
  end
  vif.cb_drv.data_in <= req.data;
  vif.cb_drv.data_in_vld <= 1'b1;
  @(vif.cb_drv);
  while (vif.data_in_rdy !== 1) begin
    @(vif.cb_drv);
  end
  vif.cb_drv.data_in <= 'hx;
  vif.cb_drv.data_in_vld <= 1'b0;
endtask : do_drive


`endif // FIFO_IN_DRIVER_SV
