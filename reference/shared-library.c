// gcc -Os -o shared-library.so shared-library.c -fPIC
// strip shared-library.so

char* message = "Hello from a shared library!\n";

extern void say_hello(void) {
	__asm__("movq $1, %%rax \n\t"
		"movq $1, %%rdi \n\t"
		"movq %0, %%rsi \n\t"
		"movl %1, %%edx \n\t"
		"syscall"
		:: "g"(message), "g" (29));
}