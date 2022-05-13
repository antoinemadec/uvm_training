module top_th;

  `define UVM_SERVER_MEM top_tb.th.toplevel.data_memory_bus

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

  assign uvm_server_if_0.clock   = clock;
  assign uvm_server_if_0.reset   = reset;
  assign uvm_server_if_0.cen     = `UVM_SERVER_MEM.read_enable || `UVM_SERVER_MEM.write_enable;
  assign uvm_server_if_0.wen     = `UVM_SERVER_MEM.write_enable;
  assign uvm_server_if_0.address = `UVM_SERVER_MEM.address;
  assign uvm_server_if_0.rdata   = `UVM_SERVER_MEM.read_data;
  assign uvm_server_if_0.wdata   = `UVM_SERVER_MEM.write_data;
  assign uvm_server_if_0.byteen  = `UVM_SERVER_MEM.byte_enable;

  // Pin-level interfaces connected to DUT
  uvm_server_if  uvm_server_if_0 ();

  toplevel toplevel (
    .clock           (clock),
    .reset           (reset),
    .bus_read_data   (/*unused*/),
    .bus_address     (/*unused*/),
    .bus_write_data  (/*unused*/),
    .bus_byte_enable (/*unused*/),
    .bus_read_enable (/*unused*/),
    .bus_write_enable(/*unused*/),
    .inst            (/*unused*/),
    .pc              (/*unused*/)
  );

endmodule

