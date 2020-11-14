NASM = nasm
NASMFLAGS = -f bin

MKDIR = mkdir -p
CHMOD = chmod +x

SRC_DIR := src
OUT_DIR := out

TARGETS = ${OUT_DIR}/00-hello-world.elf \
		  ${OUT_DIR}/01-procedure-calls.elf \
		  ${OUT_DIR}/02-nx-stack.elf \
		  ${OUT_DIR}/03-section-table.elf \
		  ${OUT_DIR}/04-execve.elf \
		  ${OUT_DIR}/05-bss.elf \
		  ${OUT_DIR}/06-rodata.elf \
		  ${OUT_DIR}/07-shared-library.so

.PHONY: clean all

${OUT_DIR}:
	@${MKDIR} $@

${OUT_DIR}/%: ${SRC_DIR}/%.S ${OUT_DIR} 
	${NASM} ${NASMFLAGS} -o $@ $<
	@${CHMOD} $@

clean:
	@rm -rf ${OUT_DIR}

all: ${TARGETS}