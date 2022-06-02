#include <stdarg.h>
#include <stdint.h>
#include <stdbool.h>

#include "uvm_server.h"


static volatile spy_st uvm_server __attribute__ ((section (".uvm_server")));


// TODO: implement uvm_server_* functions
// __START_REMOVE_SECTION__
#define UVM_SERVER_PRINT_PUSH_ARGS                                               \
  va_list ap; uvm_server.fifo_data_to_uvm[UVM_SERVER_FIFO_NB-1] = (uint32_t)str; \
  va_start(ap, str);                                                             \
  for (uint32_t i = 0; i < arg_cnt; i++) {                                       \
    uvm_server.fifo_data_to_uvm[UVM_SERVER_FIFO_NB-1] = va_arg(ap, uint32_t);    \
  }                                                                              \
  va_end(ap);


void uvm_server_quit()
{
  uvm_server.cmd = 0xff;
}


void uvm_server_gen_event(uint32_t event_idx)
{
  uvm_server.cmd = 0x1 | (event_idx << 8);
}


void uvm_server_wait_event(uint32_t event_idx)
{
  uint32_t i;
  uvm_server.cmd = 0x2 | (event_idx << 8);
  while (uvm_server.cmd != 0x0) {
    if (uvm_server.cmd == 0x0) {
      break;
    }
  }
}


void uvm_server_push_data(uint32_t fifo_idx, uint32_t data)
{
  uvm_server.fifo_data_to_uvm[fifo_idx] = data;
}


bool uvm_server_pull_data(uint32_t fifo_idx, uint32_t *data)
{
  bool empty;
  empty = (bool) ((uvm_server.fifo_data_to_sw_empty >> fifo_idx) & 0x1);
  if (empty) {
    return false;
  } else {
    *data = uvm_server.fifo_data_to_sw[fifo_idx];
    return true;
  }
}


void uvm_server_print_info(uint32_t arg_cnt, char const *const str,  ...) {
  UVM_SERVER_PRINT_PUSH_ARGS;
  uvm_server.cmd = 0x0;
}


void uvm_server_print_warning(uint32_t arg_cnt, char const *const str,  ...) {
  UVM_SERVER_PRINT_PUSH_ARGS;
  uvm_server.cmd = 0x0 | 1<<8;
}


void uvm_server_print_error(uint32_t arg_cnt, char const *const str,  ...) {
  UVM_SERVER_PRINT_PUSH_ARGS;
  uvm_server.cmd = 0x0 | 2<<8;
}


void uvm_server_print_fatal(uint32_t arg_cnt, char const *const str,  ...) {
  UVM_SERVER_PRINT_PUSH_ARGS;
  uvm_server.cmd = 0x0 | 3<<8;
}
// __END_REMOVE_SECTION__
