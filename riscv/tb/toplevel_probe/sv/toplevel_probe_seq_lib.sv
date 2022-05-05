`ifndef TOPLEVEL_PROBE_SEQ_LIB_SV
`define TOPLEVEL_PROBE_SEQ_LIB_SV

class toplevel_probe_default_seq extends uvm_sequence #(tx);

  `uvm_object_utils(toplevel_probe_default_seq)

  toplevel_probe_config  m_config;

  extern function new(string name = "");
  extern task body();

`ifndef UVM_POST_VERSION_1_1
  // Functions to support UVM 1.2 objection API in UVM 1.1
  extern function uvm_phase get_starting_phase();
  extern function void set_starting_phase(uvm_phase phase);
`endif

endclass : toplevel_probe_default_seq


function toplevel_probe_default_seq::new(string name = "");
  super.new(name);
endfunction : new


task toplevel_probe_default_seq::body();
  `uvm_info(get_type_name(), "Default sequence starting", UVM_HIGH)

  req = tx::type_id::create("req");
  start_item(req); 
  if ( !req.randomize() )
    `uvm_error(get_type_name(), "Failed to randomize transaction")
  finish_item(req); 

  `uvm_info(get_type_name(), "Default sequence completed", UVM_HIGH)
endtask : body


`ifndef UVM_POST_VERSION_1_1
function uvm_phase toplevel_probe_default_seq::get_starting_phase();
  return starting_phase;
endfunction: get_starting_phase


function void toplevel_probe_default_seq::set_starting_phase(uvm_phase phase);
  starting_phase = phase;
endfunction: set_starting_phase
`endif


`endif // TOPLEVEL_PROBE_SEQ_LIB_SV

