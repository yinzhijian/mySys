rm boot head
as boot.s -o boot.o --32
ld boot.o -o boot -Ttext=0x00 -m elf_i386 --oformat binary
as head.s -o head.o --32 
ld head.o -o head -Ttext=0x00 -m elf_i386 --oformat binary
dd if=boot of=boot.img 
dd if=head of=boot.img seek=1
cp boot.img ./bochs-2.6.8/
