`ifndef TOP_SCOREBOARD
  `define TOP_SCOREBOARD

  `uvm_analysis_imp_decl(_from_fifo_in)
  `uvm_analysis_imp_decl(_from_fifo_out)

  class top_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(top_scoreboard)

    uvm_analysis_imp_from_fifo_in #(fifo_in_tx, top_scoreboard) fifo_in_to_scoreboard;
    uvm_analysis_imp_from_fifo_out #(fifo_out_tx, top_scoreboard) fifo_out_to_scoreboard;

    top_config m_config;

    bit [15:0] q16[$];

    function new(string name, uvm_component parent);
      super.new(name, parent);
      if (!uvm_config_db #(top_config)::get(this, "", "config", m_config))
        `uvm_error(get_type_name(), "Unable to get top_config")
      fifo_in_to_scoreboard = new("fifo_in_to_scoreboard", this);
      fifo_out_to_scoreboard = new("fifo_out_to_scoreboard", this);
    endfunction : new


    virtual function void write_from_fifo_in(input fifo_in_tx pkt);
      `uvm_info(get_type_name(), $sformatf("Received fifo_in_tx: %s",
        pkt.sprint( uvm_default_line_printer )), UVM_HIGH)
      q16.push_back(pkt.data[31:16]);
      q16.push_back(pkt.data[15:0]);
    endfunction: write_from_fifo_in


    virtual function void write_from_fifo_out(input fifo_out_tx pkt);
      bit [15:0] expected_data;

      `uvm_info(get_type_name(), $sformatf("Received fifo_out_tx: %s",
        pkt.sprint( uvm_default_line_printer )), UVM_HIGH)

      expected_data = q16.pop_front();
      if (pkt.data != expected_data) begin
        `uvm_error(get_type_name(), $psprintf("expected data_out=0x%0x but got 0x%0x", expected_data, pkt.data));
      end
    endfunction: write_from_fifo_out


    virtual function void check_phase(uvm_phase phase);
      if (q16.size() != 0) begin
        `uvm_error(get_type_name(), "q16 should be empty at the end of the simulation");
      end
    endfunction : check_phase


  endclass : top_scoreboard


`endif //  `ifndef TOP_SCOREBOARD

