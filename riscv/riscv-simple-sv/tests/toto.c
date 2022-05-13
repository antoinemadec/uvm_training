typedef struct {
  int cmd;
  int fifo_cmd_input;   // write: push in   fifo_cmd_input
  int fifo_cmd_output;  // read:  pull from fifo_cmd_output
  int fifo_data_to_uvm; // write: push in   fifo_data_to_uvm
  int fifo_data_to_sw;  // read:  pull from fifo_data_to_sw
} spy_st;

static volatile spy_st spy __attribute__ ((section (".spy")));

int test(void)
{
  volatile int toto;
  spy.cmd = 0xdeadbeef;
  spy.fifo_cmd_input = 0xcafedeca;
  toto = spy.fifo_cmd_output;
  spy.fifo_data_to_uvm = 0xabcdabcd;
  toto = spy.fifo_data_to_sw;
  return 0;
}
