module top_tb;

  timeunit      1ns;
  timeprecision 1ps;

  `include "uvm_macros.svh"

  import uvm_pkg::*;

  import top_test_pkg::*;
  import top_pkg::top_config;

  // Configuration object for top-level environment
  top_config top_env_config;

  // Test harness
  top_th th();

  initial
  begin
    bit coverage_enable;
    coverage_enable = $test$plusargs("coverage_enable") ? 1:0;

    // Create and populate top-level configuration object
    top_env_config = new("top_env_config", coverage_enable);
    if ( !top_env_config.randomize() )
      `uvm_fatal("top_tb", "Failed to randomize top-level configuration object" )

    th.coverage_enable = coverage_enable;

    top_env_config.m_fifo_in_config.vif  = th.fifo_in_if;
    top_env_config.m_fifo_out_config.vif = th.fifo_out_if;

    uvm_config_db #(top_config)::set(null, "uvm_test_top", "config", top_env_config);
    uvm_config_db #(top_config)::set(null, "uvm_test_top.m_env", "config", top_env_config);

    run_test();
  end

  `ifdef XCELIUM
    // dump all waveforms (xrun specific)
    initial
      begin
        $shm_open("waves.shm");
        $shm_probe("ACMTF");
      end
  `endif
endmodule
