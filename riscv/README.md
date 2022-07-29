# uvm_training - risc-v
Write system-level tests in C, make them communicate with a UVM server

![](.images/uvm_sw_ipc.png)


# TODO
  - support nested wait_event ?
    - use dedicated wait_event_address
    - 1 bit per index
    - SW clear bit when done
  - add stressful tests


# Agenda

## III- Practical Case Study: RiscV
### day1: architecture and API
  - why co-simulation?
    - reuse C code on emulator/FPGA/ASIC
    - SW engineers can now code tests
  - explain the architecture
    - address range in RAM
      - C write -> monitor -> action
      - SV backdoor write -> C read -> action
  - code API
    - C side
      - look at uvm_sw_ipc.h and uvm_sw_ipc.c
      - look at the linker script + uvm_sw_ipc __attribute__
    - SV/UVM side
      - look at top_th.sv, uvm_sw_ipc_config.sv and uvm_sw_ipc.sv
      - look at the interface + monitor + sequence_item
### day2: my first command
  - implement uvm_sw_ipc_quit()
### day3: C->UVM
  - implement uvm_print_\*()
    - va_arg
    - string in text_memory
  - void uvm_sw_ipc_gen_event(uint32_t event_idx);
    - uvm_event
  - void uvm_sw_ipc_push_data(uint32_t fifo_idx, uint32_t data);
### day4: UVM->C
  - void uvm_sw_ipc_wait_event(uint32_t event_idx);
  - bool uvm_sw_ipc_pull_data(uint32_t fifo_idx, uint32_t \*data);
### day5: to go further
  - nested wait_event
  - use registers instead of RAM
  - uvm_sw_ipc in a TB ram
