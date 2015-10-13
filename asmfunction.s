.code32
.global asmfunction
.section .data
testdata:
.asciz "This is a test message from the asm function"
datasize:
.int datasize-testdata
.section .text
.type func,@function
asmfunction:
pushl %ebp
movl %esp,%ebp
pushl %ebx
movl $4,%eax
movl $1,%ebx
movl $testdata,%ecx
movl datasize,%edx
int $0x80
popl %ebx
movl %ebp,%esp
popl %ebp
ret
