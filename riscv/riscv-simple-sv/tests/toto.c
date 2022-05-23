#include <stdint.h>
#include <stdbool.h>

#define UVM_SERVER_FIFO_NB 2

typedef struct {
  uint32_t cmd;
  uint32_t fifo_data_to_uvm[UVM_SERVER_FIFO_NB]; // write: push in   fifo_data_to_uvm[k]
  uint32_t fifo_data_to_sw[UVM_SERVER_FIFO_NB];  // read:  pull from fifo_data_to_sw[k]
  uint32_t fifo_data_to_sw_empty;
} spy_st;

static volatile spy_st uvm_server __attribute__ ((section (".uvm_server")));


void uvm_server_quit(void);
void uvm_server_gen_event(uint32_t event_idx);
void uvm_server_wait_event(uint32_t event_idx);
void uvm_server_push_data(uint32_t fifo_idx, uint32_t data);
bool uvm_server_pull_data(uint32_t fifo_idx, uint32_t *data);


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


int main(int argc, char *argv[])
{
  uint32_t data_arr[2];
  uint32_t data;
  uint32_t i;

  uvm_server_gen_event(16);

  uvm_server_wait_event(1);
  i = 0;
  while (uvm_server_pull_data(0, &data)) {
    data_arr[i] = data;
    i++;
  }
  uvm_server_push_data(0, data_arr[0]);
  uvm_server_push_data(0, data_arr[1]);
  uvm_server_gen_event(0);

  uvm_server_quit();
  return 0;
}
