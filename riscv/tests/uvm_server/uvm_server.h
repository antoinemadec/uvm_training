#ifndef UVM_SERVER_H
#define UVM_SERVER_H


#include <stdarg.h>
#include <stdint.h>
#include <stdbool.h>


// UVM_SERVER_DATA_FIFO_NB data fifo + 1 cmd fifo
#define UVM_SERVER_DATA_FIFO_NB 2
#define UVM_SERVER_FIFO_NB (UVM_SERVER_DATA_FIFO_NB + 1)


// low-level API
typedef struct {
  uint32_t cmd;
  uint32_t fifo_data_to_uvm[UVM_SERVER_FIFO_NB]; // write: push in   fifo_data_to_uvm[k]
  uint32_t fifo_data_to_sw[UVM_SERVER_FIFO_NB];  // read:  pull from fifo_data_to_sw[k]
  uint32_t fifo_data_to_sw_empty;                // [k]:   fifo_data_to_sw[k] is empty
} spy_st;


// high-level API
void uvm_server_quit(void);
void uvm_server_gen_event(uint32_t event_idx);
void uvm_server_wait_event(uint32_t event_idx);
void uvm_server_push_data(uint32_t fifo_idx, uint32_t data);
bool uvm_server_pull_data(uint32_t fifo_idx, uint32_t *data);
void uvm_server_print_info(uint32_t arg_cnt, char const *const str,  ...);
void uvm_server_print_warning(uint32_t arg_cnt, char const *const str,  ...);
void uvm_server_print_error(uint32_t arg_cnt, char const *const str,  ...);
void uvm_server_print_fatal(uint32_t arg_cnt, char const *const str,  ...);


#endif
