.code16
.globl _start
.text
BOOTSEG = 0x07c0
COPYSEG = 0x1000
INITSEG = 0x0000
SETUPLEN = 0x9 #8KB=16*512bytes
_start:
jmpl $BOOTSEG,$go
go:
movw %cs,%ax
movw %ax,%ds
movw %ax,%es
#show the msg
movw $msgend-msg,%cx
movw $0x000c,%bx
movw $msg,%bp
movw $0x1301,%ax
int $0x10
#load system into COPYSEG
movw $0,%dx #驱动器0,磁头0
movw $2,%cx #扇区2，磁道0
movw $COPYSEG,%ax
movw %ax,%es
xor %bx,%bx #es:bx->指向数据缓冲区
movw $0x0200+SETUPLEN,%ax #服务2，读入SETUPLEN个扇区
int $0x13 #中断13
jnc ok_load
die:jmp die
ok_load:
#copy copyseg to initseg
xor %si,%si
xor %di,%di
movw $COPYSEG,%ax
movw %ax,%ds
movw $INITSEG,%ax
movw %ax,%es
movw $512*(SETUPLEN),%cx
cld
rep movsb
#reset the ds to BOOSEG 
movw $BOOTSEG,%ax
movw %ax,%ds
#open the A20
inb $0x92,%al
orb $0b00000010,%al
outb %al,$0x92
#临时设置GDT、IDT
lidt idt_48
lgdt gdt_48
#movw $1,%ax
#lmsw %ax
#set pe = 1
movl %cr0,%ebx
or $1,%ebx
movl %ebx,%cr0
jmpl $8,$0
msg:
.ascii "Loading system ..."
.byte 13,10
msgend:
.align 8
gdt:
.word 0,0,0,0 #gdt0
.word 0x007f,0x0,0x9a00,0x00c0 #code
.word 0x007f,0x0,0x9200,0x00c0 #data
.word 80*25*2-1,0x8000,0x920b,0x0040 #display
gdt_end:
idt_48:
.word 0 #idt length=0
.word 0,0 #base addr=0
gdt_48:
.word (gdt_end-gdt) #gdt length (unit bytes)
#.word 0x1f #can contains 4 gdt
#.word 0x07ff #2048 bytes 可容纳256个描述符
.word 0x7c00+gdt,0
.org 510
.word 0xAA55

