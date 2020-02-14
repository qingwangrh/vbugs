 qemu-img create prova.img 1G

 qemu-img info prova.img

 time qemu-img convert -f raw -O raw -t none prova.img prova1.img

 #test point ?
 #compare which version