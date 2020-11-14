// gcc -c -fPIC -Os -s -o shared-library.o shared-library.c
// gcc -shared shared-library.o -nostdlib -o shared-library.so
// strip shared-library.so

char* message = "Hello from a shared library!\n";
char* message2 = "Hello from somewhere else in a shared library!\n";

extern void say_hello(void) {
	__asm__("movq $1, %%rax \n\t"
		"movq $1, %%rdi \n\t"
		"movq %0, %%rsi \n\t"
		"movl %1, %%edx \n\t"
		"syscall"
		:: "g"(message), "g" (29));
}

extern void say_hello2(void) {
	__asm__("movq $1, %%rax \n\t"
		"movq $1, %%rdi \n\t"
		"movq %0, %%rsi \n\t"
		"movl %1, %%edx \n\t"
		"syscall"
		:: "g"(message2), "g" (29));
}