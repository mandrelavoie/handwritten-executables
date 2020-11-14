// gcc -Os -o shared-test shared-test.c -ldl

#include <stdio.h>
#include <dlfcn.h>

int main(int argc, char *argv[]) {
    int rc = 1;
    void *dl = NULL;

    if (argc != 3) {
        printf("Usage: %s [path to .so file] [function to call]\n", argv[0]);
        goto error;
    }

    dl = dlopen(argv[1], RTLD_NOW);
    if (!dl) {
        printf("%s\n", dlerror());
        goto error;
    }

    void (*func)() = dlsym(dl, argv[2]);
    if (!func) {
        printf("%s\n",dlerror());
        goto error;
    }

    func();
    rc = 0;
error:
    if (dl) {
        dlclose(dl);
    }
    
    return rc;
}