`ifndef UVM_SERVER_IF_SV
`define UVM_SERVER_IF_SV

  `define UVM_SERVER_MEM top_tb.th.toplevel.data_memory_bus

interface uvm_server_if(); 

  timeunit      1ns;
  timeprecision 1ps;

  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import uvm_server_pkg::*;

  wire clock;
  wire reset;
  wire cen;
  wire wen;
  wire [31:0] address;
  wire [31:0] rdata;
  wire [31:0] wdata;
  wire [3:0] byteen;

  clocking cb @(posedge clock);
    input reset;
    input cen;
    input wen;
    input address;
    input rdata;
    input wdata;
    input byteen;
  endclocking : cb

  function void backdoor_write(bit [31:0] addr, bit [31:0] wdata);
    `UVM_SERVER_MEM.data_memory.mem[addr[16:2]] = wdata;
    `uvm_info("uvm_server_if", $sformatf("backdoor_write 0x%x -> [0x%x]", wdata, addr), UVM_DEBUG);
  endfunction : backdoor_write

endinterface : uvm_server_if

`endif // UVM_SERVER_IF_SV

