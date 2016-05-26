#include <unistd.h>
#include <stdio.h>

int main(void) {
    long open_max = sysconf(_SC_OPEN_MAX);
    printf("_SC_OPEN_MAX: %ld\n", open_max);

    int i, j;
    for (j=0; j < 1000; j++)
        for (i=3; i < open_max; i++)
            close(i);
}
