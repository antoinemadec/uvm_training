// RISC-V SiMPLE SV -- data memory model
// BSD 3-Clause License
// (c) 2017-2019, Arthur Matos, Marcus Vinicius Lamar, Universidade de Brasília,
//                Marek Materzok, University of Wrocław

`include "config.sv"
`include "constants.sv"

module example_data_memory (
  input [`DATA_BITS-3:0] address,
  input [3:0] byteena,
  input clock,
  input [31:0] data,
  input wren,
  output [31:0] q
);

  (* nomem2reg *)
  // FIXME: stack is in 0xffff_ff.. instead of 0x8002_00..
  // logic [31:0] mem[0:2**(`DATA_BITS-2)-1];
  logic [31:0] mem[int];

  reg [31:0] q_reg;
  always @(address, wren)
    q_reg = mem[$isunknown(address) ? 0:address];

  assign q = q_reg;

  always_ff @(posedge clock)
    if (wren) begin
      bit [31:0] data_masked;
      data_masked = 0;
      if (byteena[0]) data_masked[7:0] = data[7:0];
      if (byteena[1]) data_masked[15:8] = data[15:8];
      if (byteena[2]) data_masked[23:16] = data[23:16];
      if (byteena[3]) data_masked[31:24] = data[31:24];
      mem[address] <= data_masked;
    end

  `ifdef DATA_HEX
    initial $readmemh(`DATA_HEX, mem);
  `endif

endmodule

