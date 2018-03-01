#include <stdio.h>

void microkernel_sendmsg(char *);
void microkernel_getmsg(char *);

int main()
{
    printf("Hello World!\n");
    printf("This must be a monolithic design\n");
    microkernel_sendmsg("is more portable");
    return 0;
}

void microkernel_sendmsg(char *a)
{
    printf("microkernel: %s\n", a);
}

void microkernel_getmsg(char *b)
{
    //TODO: getmsg feature
}
