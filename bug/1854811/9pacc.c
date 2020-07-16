 #include <stdlib.h>
  #include <string.h>
  #include <unistd.h>
  #include <dirent.h>

  #define FSIZE  0x300

  int main(void)
  {
     char foo[256] = {0};
     char boo[256] = {0}
     char foldername[FSIZE] = {0};

     memset(foo, 0x41, 255);
     memset(boo, 0x42, 255);
     snprintf(foldername, FSIZE, "/home/leonwxqian/share/%s/%s/AAAAAAAAAA",foo, boo);

     DIR *dir = 0;
     while(1) {
       dir = opendir(foldername);
       closedir(dir);
     }

     return 0;
  }