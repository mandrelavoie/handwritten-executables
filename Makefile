NASM = nasm
NASMFLAGS = -f bin

MKDIR = mkdir -p
CHMOD = chmod +x

SRC_DIR := src
OUT_DIR := out

TARGETS = ${OUT_DIR}/00-hello-world.elf \
          ${OUT_DIR}/01-procedure-calls.elf

.PHONY: clean all

${OUT_DIR}:
	@${MKDIR} $@

${OUT_DIR}/%: ${OUT_DIR}
	${NASM} ${NASMFLAGS} -o $@ ${SRC_DIR}/$*.S
	${CHMOD} $@

clean:
	@rm -rf ${OUT_DIR}

all: ${TARGETS}