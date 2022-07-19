package uvm_server_pkg;

  `include "uvm_macros.svh"

  import uvm_pkg::*;

  localparam UVM_SERVER_EVENT_NB = 1024;

  // UVM_SERVER_DATA_FIFO_NB data fifo + 1 cmd args fifo
  localparam UVM_SERVER_DATA_FIFO_NB  = 2;
  localparam UVM_SERVER_FIFO_NB = UVM_SERVER_DATA_FIFO_NB + 1;

  `include "uvm_server_tx.sv"
  `include "uvm_server_config.sv"
  `include "uvm_server_monitor.sv"
  `include "uvm_server.sv"

endpackage : uvm_server_pkg
