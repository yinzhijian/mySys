.code32
.global startup_32
.text
LATCH          =11930 #定时器初始计数值，每隔10毫秒发送一次中断请求
TASK0_CODE_SEL =0xf 
TASK0_DATA_SEL =0x17 
TASK1_CODE_SEL =0xf 
TASK1_DATA_SEL =0x17 
KRN_CODE_SEL = 8
KRN_DATA_SEL = 16
DISPLAY_SEL = 24
TSS0_SEL = 32
TSS1_SEL = 40
LDT0_SEL = 48
LDT1_SEL = 56
startup_32:
#cli #close 中断
#reset the ds
movw $16,%ax
movw %ax,%ds
#reload the gdt &idt
lgdt gdt_48
lidt idt_48
#set the ss and the esp
movw $KRN_DATA_SEL,%ax
movw %ax,%ss
movl $krn_stk0_end,%eax
movl %eax,%esp
#set normal idts
movl $256,%ecx
xor %eax,%eax
idt_loop:
movw $normal_interrupt_handle,idt(%eax)
movl $2,%ebx
movw $KRN_CODE_SEL,idt(%eax,%ebx,1)
movl $4,%ebx
movw $0x8e00,idt(%eax,%ebx,1)
movl $6,%ebx
movw $0,idt(%eax,%ebx,1)
addl $8,%eax
loop idt_loop
#set 0x80 interrupt handle
movl $0x400,%eax
movw $x80_interrupt_handle,idt(%eax)
movl $0x404,%eax
movw $0xef00,idt(%eax)#DPL = 3
call function_settimer0
#clear eflags TF flag
pushfl
andl $0xffffbfff,(%esp)
popfl
#set tss0 ldt0
movl $TSS0_SEL,%eax
ltr %ax
movl $LDT0_SEL,%eax
lldt %ax
#sti #start 中断
#preper the interept stack to back task0
pushl $TASK0_DATA_SEL#ss
pushl $stack0_end-task0#esp
pushfl  #eflags 
pushl $TASK0_CODE_SEL #cs
pushl $0 #$task0 #eip
iret #to task0
loop:
jmp loop
function_settimer0:
#set the timer0 refence by  https://en.wikipedia.org/wiki/Intel_8253
movb $0x36,%al#36h=00110110b#D7D6为指定哪个COUNTER，D5D4为写高位低位【11为先写低位后写高位】，D3D2D1为哪个模式，D0为16进制还是10进制
movl $0x43,%edx
outb %al,%dx#43h为8253的控制端口
#每10ms中断一次 clock ticks at a value of 1193181.8181,count = clock ticks/Hz = 1193181/100=11931
movw LATCH,%ax
movl $0x40,%edx
outb %al,%dx#write low
movb %ah,%al
outb %al,%dx#write high 40h为8253的counter0的RW端口
ret
#timer0 end
msg:
.ascii "head is loaded"
.byte 13,10
msgend:
x80_interrupt_handle:
movw $KRN_DATA_SEL,%bx
movw %bx,%ds
pushl %eax
call function_display
popl %eax
iret

normal_interrupt_handle:
movw $KRN_DATA_SEL,%bx
movw %bx,%ds
pushl $67 # char C
call function_display
addl $4,%esp
iret

display_index:
.word 0
function_display:
pushl %ebp
movl %esp,%ebp
movl 8(%ebp),%edx #first param with display char
movw display_index,%bx
#show the msg with b8000
movw $DISPLAY_SEL,%ax
movw %ax,%es
movb %dl,%es:0(%bx)
movb $0x0a,%es:1(%bx)
addw $2,%bx
cmp $80*25,%bx
jnz not_eq 
xor %bx,%bx
not_eq:
movw %bx,display_index
movl %ebp,%esp
popl %ebp
ret

task0:
movl $65,%eax #char A
int $0x80
movl $0xffffff,%ecx
idle0:
loop idle0
jmp task0
krn_stk0:
.fill 128,4,0
krn_stk0_end:
stack0:
.fill 128,4,0
stack0_end:
task0_end:
task1:
movl $66,%eax #char B
int $0x80
movl $0xffffff,%ecx
idle1:
loop idle1
jmp task1
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
.long krn_stk0_end,KRN_DATA_SEL,0,0,0,0 #esp0,ss0,esp1,ss1,esp2,ss2
.long 0 #cr3
.long 0,0,0,0,0,0,stack0_end-task0,0,0,0 #eip,eflags,eax,ecx,edx,ebx,esp,ebp,esi,edi
.long 0x17,0xf,0x17,0x17,0x17,0x17 #es,cs,ss,ds,fs,gs
.long LDT0_SEL#ldt
.long 0x80000000 #bitmap
tss0_end:
tss1:
.long 0 #pre tss link
.long krn_stk1_end,KRN_DATA_SEL,0,0,0,0 #esp0,ss0,esp1,ss1,esp2,ss2
.long 0 #cr3
.long 0,0,0,0,0,0,stack1_end-task1,0,0,0 #eip,eflags,eax,ecx,edx,ebx,esp,ebp,esi,edi
.long 0x17,0xf,0x17,0x17,0x17,0x17 #es,cs,ss,ds,fs,gs
.long LDT1_SEL#ldt
.long 0x80000000 #bitmap
tss1_end:
gdt:
.word 0,0,0,0 #gdt0
.word 0x007f,0,0x9a00,0x00c0 #code
.word 0x007f,0,0x9200,0x00c0 #data
.word 80*25*2-1,0x8000,0x920b,0x0040 #display
.word tss0_end-tss0,tss0,0xe900,0x0000 #tss0
.word tss1_end-tss1,tss1,0xe900,0x0000 #tss1
.word ldt0_end-ldt0,ldt0,0xe200,0x0000#LDT0
.word ldt1_end-ldt1,ldt1,0xe200,0x0000#LDT1
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
