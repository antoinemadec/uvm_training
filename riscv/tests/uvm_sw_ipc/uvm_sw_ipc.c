#include <stdarg.h>
#include <stdint.h>
#include <stdbool.h>

#include "uvm_sw_ipc.h"


static volatile uvm_sw_ipc_st uvm_sw_ipc __attribute__ ((section (".uvm_sw_ipc")));


// TODO: implement uvm_sw_ipc_* functions
// __START_REMOVE_SECTION__
#define UVM_SW_IPC_PRINT_PUSH_ARGS                                               \
  va_list ap; uvm_sw_ipc.fifo_data_to_uvm[UVM_SW_IPC_FIFO_NB-1] = (uint32_t)str; \
  va_start(ap, str);                                                             \
  for (uint32_t i = 0; i < arg_cnt; i++) {                                       \
    uvm_sw_ipc.fifo_data_to_uvm[UVM_SW_IPC_FIFO_NB-1] = va_arg(ap, uint32_t);    \
  }                                                                              \
  va_end(ap);


void uvm_sw_ipc_quit()
{
  uvm_sw_ipc.cmd = SYS_uvm_quit;
}


void uvm_sw_ipc_gen_event(uint32_t event_idx)
{
  uvm_sw_ipc.cmd = SYS_uvm_gen_event | (event_idx << 8);
}


void uvm_sw_ipc_wait_event(uint32_t event_idx)
{
  uvm_sw_ipc.cmd = SYS_uvm_wait_event | (event_idx << 8);
  while (uvm_sw_ipc.cmd != 0x0) {
    if (uvm_sw_ipc.cmd == 0x0) {
      break;
    }
  }
}


void uvm_sw_ipc_push_data(uint32_t fifo_idx, uint32_t data)
{
  uvm_sw_ipc.fifo_data_to_uvm[fifo_idx] = data;
}


bool uvm_sw_ipc_pull_data(uint32_t fifo_idx, uint32_t *data)
{
  bool empty;
  empty = (bool) ((uvm_sw_ipc.fifo_data_to_sw_empty >> fifo_idx) & 0x1);
  if (empty) {
    return false;
  } else {
    *data = uvm_sw_ipc.fifo_data_to_sw[fifo_idx];
    return true;
  }
}


void uvm_sw_ipc_print_info(uint32_t arg_cnt, char const *const str,  ...) {
  UVM_SW_IPC_PRINT_PUSH_ARGS;
  uvm_sw_ipc.cmd = SYS_uvm_print;
}


void uvm_sw_ipc_print_warning(uint32_t arg_cnt, char const *const str,  ...) {
  UVM_SW_IPC_PRINT_PUSH_ARGS;
  uvm_sw_ipc.cmd = SYS_uvm_print | 1<<8;
}


void uvm_sw_ipc_print_error(uint32_t arg_cnt, char const *const str,  ...) {
  UVM_SW_IPC_PRINT_PUSH_ARGS;
  uvm_sw_ipc.cmd = SYS_uvm_print | 2<<8;
}


void uvm_sw_ipc_print_fatal(uint32_t arg_cnt, char const *const str,  ...) {
  UVM_SW_IPC_PRINT_PUSH_ARGS;
  uvm_sw_ipc.cmd = SYS_uvm_print | 3<<8;
}
// __END_REMOVE_SECTION__

void sys_write(char const *const str, int length) {
  uvm_sw_ipc.fesvr_response = 0;
  uvm_sw_ipc.cmd = SYS_write;
  uvm_sw_ipc.fesvr_args[0] = 1;
  uvm_sw_ipc.fesvr_args[1] = (uint32_t)str;
  uvm_sw_ipc.fesvr_args[2] = length;
  while (uvm_sw_ipc.cmd == 0x0) {};
}

void sys_exit(int code) {
  uvm_sw_ipc.fesvr_response = 0;
  uvm_sw_ipc.cmd = SYS_exit;
  uvm_sw_ipc.fesvr_args[0] = code;
  uvm_sw_ipc.fesvr_args[1] = 0;
  uvm_sw_ipc.fesvr_args[2] = 0;
  while (uvm_sw_ipc.cmd == 0x0) {};
}
