.code32
.global startup_32
.text
startup_32:
#reset the ds
movw $16,%ax
movw %ax,%ds
#reload the gdt &idt
lgdt gdt_48
lidt idt_48
movw $32,%ax
movw %ax,%ss
movl $0xfffe,%eax
movl %eax,%esp
pushl $300
pushl $200
pushl $100
popl %ecx
popl %ebx
popl %eax
#show the msg with b8000
movw $24,%ax
movw %ax,%es
movw $0,%bx
movb $0x59,%es:(%bx)
movw $1,%bx
movb $0x8a,%es:(%bx)
loop:
jmp loop
msg:
.ascii "head is loaded"
.byte 13,10
msgend:
.align 8
gdt:
.word 0,0,0,0 #gdt0
.word 0x007f,0,0x9a00,0x00c0 #code
.word 0x007f,0,0x9200,0x00c0 #data
.word 80*25*2-1,0x8000,0x920b,0x0040 #display
.word 0x0001,0xffff,0x9600,0x00c0 #stack
gdt_end:
idt:
.fill 256,8,0
idt_end:
idt_48:
.word (idt_end-idt)
.word idt,0
gdt_48:
.word (gdt_end-gdt)
.word gdt,0
stack_1_end:
.fill 20
stack_1:

