#include <sys/io.h>
  #include <stdlib.h>

  int main(void)
  {
     iopl(3);
     while(1) {
       outb(1<<2, 0xae08);
     }
     return 0;
  }