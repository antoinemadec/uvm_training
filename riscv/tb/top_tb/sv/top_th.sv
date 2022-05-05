module top_th;

  timeunit      1ns;
  timeprecision 1ps;


  // Example clock and reset declarations
  logic clock = 0;
  logic reset;

  // Example clock generator process
  always #10 clock = ~clock;

  // Example reset generator process
  initial
  begin
    reset = 1;         // Active low reset in this example
    #75 reset = 0;
  end

  assign toplevel_probe_if_0.reset = reset;

  assign toplevel_probe_if_0.clock = clock;

  // Pin-level interfaces connected to DUT
  toplevel_probe_if  toplevel_probe_if_0 ();

  toplevel toplevel (
    .clock           (clock),
    .reset           (reset),
    .bus_read_data   (toplevel_probe_if_0.bus_read_data),
    .bus_address     (toplevel_probe_if_0.bus_address),
    .bus_write_data  (toplevel_probe_if_0.bus_write_data),
    .bus_byte_enable (toplevel_probe_if_0.bus_byte_enable),
    .bus_read_enable (toplevel_probe_if_0.bus_read_enable),
    .bus_write_enable(toplevel_probe_if_0.bus_write_enable)
  );

endmodule

