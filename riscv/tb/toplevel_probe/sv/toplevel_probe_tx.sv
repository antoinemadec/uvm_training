`ifndef TOPLEVEL_PROBE_SEQ_ITEM_SV
`define TOPLEVEL_PROBE_SEQ_ITEM_SV

class tx extends uvm_sequence_item; 

  `uvm_object_utils(tx)

  // To include variables in copy, compare, print, record, pack, unpack, and compare2string, define them using trans_var in file ./toplevel_probe.tpl
  // To exclude variables from compare, pack, and unpack methods, define them using trans_meta in file ./toplevel_probe.tpl

  // Transaction variables
  bit[31:0] rwb;
  bit[31:0] data;
  bit[3:0] byte_en;


  extern function new(string name = "");
  extern function void do_copy(uvm_object rhs);
  extern function bit  do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function void do_print(uvm_printer printer);
  extern function void do_record(uvm_recorder recorder);
  extern function void do_pack(uvm_packer packer);
  extern function void do_unpack(uvm_packer packer);
  extern function string convert2string();

endclass : tx 


function tx::new(string name = "");
  super.new(name);
endfunction : new


function void tx::do_copy(uvm_object rhs);
  tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  super.do_copy(rhs);
  rwb     = rhs_.rwb;    
  data    = rhs_.data;   
  byte_en = rhs_.byte_en;
endfunction : do_copy


function bit tx::do_compare(uvm_object rhs, uvm_comparer comparer);
  bit result;
  tx rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  result = super.do_compare(rhs, comparer);
  result &= comparer.compare_field("rwb", rwb,         rhs_.rwb,     $bits(rwb));
  result &= comparer.compare_field("data", data,       rhs_.data,    $bits(data));
  result &= comparer.compare_field("byte_en", byte_en, rhs_.byte_en, $bits(byte_en));
  return result;
endfunction : do_compare


function void tx::do_print(uvm_printer printer);
  if (printer.knobs.sprint == 0)
    `uvm_info(get_type_name(), convert2string(), UVM_MEDIUM)
  else
    printer.m_string = convert2string();
endfunction : do_print


function void tx::do_record(uvm_recorder recorder);
  super.do_record(recorder);
  // Use the record macros to record the item fields:
  `uvm_record_field("rwb",     rwb)    
  `uvm_record_field("data",    data)   
  `uvm_record_field("byte_en", byte_en)
endfunction : do_record


function void tx::do_pack(uvm_packer packer);
  super.do_pack(packer);
  `uvm_pack_int(rwb)     
  `uvm_pack_int(data)    
  `uvm_pack_int(byte_en) 
endfunction : do_pack


function void tx::do_unpack(uvm_packer packer);
  super.do_unpack(packer);
  `uvm_unpack_int(rwb)     
  `uvm_unpack_int(data)    
  `uvm_unpack_int(byte_en) 
endfunction : do_unpack


function string tx::convert2string();
  string s;
  $sformat(s, "%s\n", super.convert2string());
  $sformat(s, {"%s\n",
    "rwb     = 'h%0h  'd%0d\n", 
    "data    = 'h%0h  'd%0d\n", 
    "byte_en = 'h%0h  'd%0d\n"},
    get_full_name(), rwb, rwb, data, data, byte_en, byte_en);
  return s;
endfunction : convert2string


`endif // TOPLEVEL_PROBE_SEQ_ITEM_SV

