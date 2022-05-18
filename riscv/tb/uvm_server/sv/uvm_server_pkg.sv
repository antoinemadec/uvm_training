package uvm_server_pkg;

  `include "uvm_macros.svh"

  import uvm_pkg::*;

  localparam UVM_SERVER_EVENT_NB = 1024;

  `include "uvm_server_tx.sv"
  `include "uvm_server_config.sv"
  `include "uvm_server_monitor.sv"
  `include "uvm_server.sv"

endpackage : uvm_server_pkg
