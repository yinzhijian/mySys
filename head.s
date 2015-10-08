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
task0:
krn_stk0:
.fill 128,4,0
krn_stk0_end:
stack0:
.fill 128,4,0
stack0_end:
task0_end:
task1:
krn_stk1:
.fill 128,4,0
krn_stk1_end:
stack1:
.fill 128,4,0
stack1_end:
task1_end:
.align 8
ldt0:
.word 0,0,0,0 #ldt0 not used
.word task0_end,task0,0xfa00,0x0040 #code
.word task0_end,task0,0xf200,0x0040 #data
ldt0_end:
ldt1:
.word 0,0,0,0 #ldt1 not used
.word task1_end,task1,0xfa00,0x0040 #code
.word task1_end,task1,0xf200,0x0040 #data
ldt1_end:
tss0:
.long 0 #pre tss link
.long krn_stk0_end,0x16,0,0,0,0 #esp0,ss0,esp1,ss1,esp2,ss2
.long 0 #cr3
.long 0,0,0,0,0,0,stack0_end-task0,0,0,0 #eip,eflags,eax,ecx,edx,ebx,esp,ebp,esi,edi
.long 0x17,0xf,0x17,0x17,0x17,0x17 #es,cs,ss,ds,fs,gs
.long 0x48 #ldt
.long 0x80000000 #bitmap
tss0_end:
tss1:
.long 0 #pre tss link
.long krn_stk1_end,0x16,0,0,0,0 #esp0,ss0,esp1,ss1,esp2,ss2
.long 0 #cr3
.long 0,0,0,0,0,0,stack1_end-task1,0,0,0 #eip,eflags,eax,ecx,edx,ebx,esp,ebp,esi,edi
.long 0x17,0xf,0x17,0x17,0x17,0x17 #es,cs,ss,ds,fs,gs
.long 0x56 #ldt
.long 0x80000000 #bitmap
tss1_end:
gdt:
.word 0,0,0,0 #gdt0
.word 0x007f,0,0x9a00,0x00c0 #code
.word 0x007f,0,0x9200,0x00c0 #data
.word 80*25*2-1,0x8000,0x920b,0x0040 #display
.word tss0_end-tss0,tss0,0xea00,0x0000 #tss0
.word tss1_end-tss1,tss1,0xea00,0x0000 #tss1
.word ldt0_end-ldt0,ldt0,0xd200,0x0000#LDT0
.word ldt1_end-ldt1,ldt1,0xd200,0x0000#LDT1
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
