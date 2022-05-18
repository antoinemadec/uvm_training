#include <stdint.h>

typedef struct {
  uint32_t cmd;
  uint32_t fifo_cmd_input;   // write: push in   fifo_cmd_input
  uint32_t fifo_cmd_output;  // read:  pull from fifo_cmd_output
  uint32_t fifo_data_to_uvm; // write: push in   fifo_data_to_uvm
  uint32_t fifo_data_to_sw;  // read:  pull from fifo_data_to_sw
} spy_st;

static volatile spy_st spy __attribute__ ((section (".uvm_server")));


void uvm_server_quit(void);
void uvm_server_gen_event(uint32_t event_idx);
void uvm_server_wait_event(uint32_t event_idx);


void uvm_server_quit()
{
  spy.cmd = 0xff;
}


void uvm_server_gen_event(uint32_t event_idx)
{
  spy.cmd = 0x1 | (event_idx << 8);
}


void uvm_server_wait_event(uint32_t event_idx)
{
  uint32_t i;
  spy.cmd = 0x2 | (event_idx << 8);
  while (spy.cmd != 0x0) {
    if (spy.cmd == 0x0) {
      break;
    }
  }
}


int main(int argc, char *argv[])
{
  /* spy.cmd = 0; */
  uvm_server_gen_event(16);
  uvm_server_wait_event(1);
  /* spy.fifo_cmd_input = 0xcafedeca; */
  /* toto = spy.fifo_cmd_output; */
  /* spy.fifo_data_to_uvm = 0xabcdabcd; */
  /* toto = spy.fifo_data_to_sw; */
  uvm_server_quit();
  return 0;
}
