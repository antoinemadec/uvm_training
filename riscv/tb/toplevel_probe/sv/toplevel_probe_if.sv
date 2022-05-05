`ifndef TOPLEVEL_PROBE_IF_SV
`define TOPLEVEL_PROBE_IF_SV

interface toplevel_probe_if(); 

  timeunit      1ns;
  timeprecision 1ps;

  import toplevel_probe_pkg::*;

  wire clock;
  wire reset;

  wire [31:0] bus_read_data;
  wire [31:0] bus_address;
  wire [31:0] bus_write_data;
  wire [3:0]  bus_byte_enable;
  wire        bus_read_enable;
  wire        bus_write_enable;

  clocking cb_mon @(posedge clock);
    output reset;
    output bus_read_data;
    output bus_address;
    output bus_write_data;
    output bus_byte_enable;
    output bus_read_enable;
    output bus_write_enable;
  endclocking : cb_mon

endinterface : toplevel_probe_if

`endif // TOPLEVEL_PROBE_IF_SV

