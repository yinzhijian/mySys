boot.img:main boot
	dd if=boot of=boot.img
	dd if=main of=boot.img seek=1
	cp boot.img ./bochs-2.6.8/
boot:boot.o
	ld boot.o -o boot -Ttext=0x00 -m elf_i386 --oformat binary
boot.o:boot.s
	as boot.s -o boot.o --32
main:main.o
	ld -o main -Ttext 0x0 -e main --oformat binary -N -m elf_i386  main.o
main.o:main.s
	as main.s -o main.o --32
main.s:main.c
	gcc -S main.c -o main.s -m32 -O2
.PHONY :clean
clean:
	rm main main.o
