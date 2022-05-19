#include <stdint.h>

typedef struct {
  uint32_t cmd;
  uint32_t fifo_cmd_input;   // write: push in   fifo_cmd_input
  uint32_t fifo_cmd_output;  // read:  pull from fifo_cmd_output
  uint32_t fifo_data_to_uvm; // write: push in   fifo_data_to_uvm
  uint32_t fifo_data_to_sw;  // read:  pull from fifo_data_to_sw
} spy_st;

static volatile spy_st uvm_server __attribute__ ((section (".uvm_server")));


void uvm_server_quit(void);
void uvm_server_gen_event(uint32_t event_idx);
void uvm_server_wait_event(uint32_t event_idx);


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


int main(int argc, char *argv[])
{
  uint32_t data0;
  uint32_t data1;
  uint32_t data2;

  /* uvm_server.cmd = 0; */
  uvm_server_gen_event(16);

  uvm_server_wait_event(1);
  data0 = uvm_server.fifo_data_to_sw;
  data1 = uvm_server.fifo_data_to_sw;
  uvm_server.fifo_data_to_uvm = data0;
  uvm_server.fifo_data_to_uvm = data1;
  uvm_server_gen_event(0);

  /* uvm_server.fifo_cmd_input = 0xcafedeca; */
  /* toto = uvm_server.fifo_cmd_output; */

  uvm_server_quit();
  return 0;
}
