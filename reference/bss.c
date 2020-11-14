// gcc -Os -s -no-pie -nostdlib -o bss bss.c

static char message[100];

extern void _start(void) {
	message[0] = 'A';
	message[1] = 'l';
	message[2] = 'l';
	message[3] = 'o';
	message[4] = '!';
	message[5] = '\n';
	message[6] = 0;

	__asm__("movq $1, %%rax \n\t"
		"movq $1, %%rdi \n\t"
		"movq %0, %%rsi \n\t"
		"movl %1, %%edx \n\t"
		"syscall"
		:: "g"(message), "g" (29));
}