CC=riscv64-unknown-elf-gcc
LD=riscv64-unknown-elf-ld
SREC_CAT=srec_cat
OBJCOPY=riscv64-unknown-elf-objcopy
CFLAGS=-mabi=ilp32 -march=rv32i -ffunction-sections -fdata-sections
LDFLAGS=-Tlink.ld -melf32lriscv -Map=$@.map
CSRCS=$(wildcard *.c)
CS=$(CSRCS:.c=.S)
SRCS=$(wildcard *.S) ${CS}
OBJS=$(SRCS:.S=.o)
ELFS=$(SRCS:.S=.elf)
BINS=$(SRCS:.S=.text.bin) $(SRCS:.S=.data.bin)
VHS=$(SRCS:.S=.text.vh) $(SRCS:.S=.data.vh)
MAP=$(SRCS:.S=.elf.map)

all: ${CS} ${VHS}

%.S: %.c
	${CC} -c ${CFLAGS} -S -o $@ $<

%.o: %.S test_macros.h riscv_test.h
	${CC} -c ${CFLAGS} -o $@ $<

%.elf: %.o 
	${LD} ${LDFLAGS} $< -o $@

%.text.bin: %.elf
	${OBJCOPY} -O binary $< $@ -j .init -j .text --change-addresses -0x400000

%.data.bin: %.elf
	${OBJCOPY} -O binary $< $@ -j .data -j .eh_frame -j .fini_array -j .init_array --change-addresses -0x80000000

%.vh: %.bin
	${SREC_CAT} $< -binary -byte-swap 4 -O $@ -VMem 32

clean:
	rm -f ${OBJS} ${ELFS} ${BINS} ${VHS} ${MAP} ${CS}
