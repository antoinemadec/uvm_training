`ifndef FIFO_OUT_DRIVER_SV
`define FIFO_OUT_DRIVER_SV

class fifo_out_driver extends uvm_driver #(fifo_out_tx);

  `uvm_component_utils(fifo_out_driver)

  virtual fifo_out_if vif;

  fifo_out_config m_config;

  extern function new(string name, uvm_component parent);

  extern task run_phase(uvm_phase phase);
  extern task do_drive();

endclass : fifo_out_driver


function fifo_out_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


task fifo_out_driver::run_phase(uvm_phase phase);
  `uvm_info(get_type_name(), "run_phase", UVM_HIGH)

  vif.cb_drv.data_out_rdy <= 1'b0;
  @(vif.cb_drv);

  forever
  begin
    seq_item_port.get_next_item(req);
    `uvm_info(get_type_name(), {"req item\n",req.sprint}, UVM_DEBUG)
    do_drive();
    seq_item_port.item_done();
  end
endtask : run_phase


task fifo_out_driver::do_drive();
  repeat (get_delay(req.rate)) begin
    @(vif.cb_drv);
  end
  vif.cb_drv.data_out_rdy <= 1'b1;
  @(vif.cb_drv);
  while (vif.cb_drv.data_out_vld !== 1) begin
    @(vif.cb_drv);
  end
  vif.cb_drv.data_out_rdy <= 1'b0;
endtask : do_drive


`endif // FIFO_OUT_DRIVER_SV
