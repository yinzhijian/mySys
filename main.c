
typedef unsigned char u1;
typedef unsigned short u2;
typedef unsigned int u4;
typedef unsigned long int u8;
#define GDT_NUM 10
#define GDT_SIZE GDT_NUM*8-1

#define IDT_NUM 256
#define IDT_SIZE IDT_NUM*8-1

#define DPL_KERNEL 0
#define DPL_USER 3

#define SEG_DESC_TYPE_DATA_RW 0x2
#define SEG_DESC_TYPE_CODE_RW 0xa

#define SEG_DESC_S_SYSTEM 0
#define SEG_DESC_S_CODEDATA 1

#define SEG_DESC_G_BYTE 0
#define SEG_DESC_G_4KB 1

#define KERNEL_CODE_SEL 8
#define KERNEL_DATA_SEL 16

#define DISPLAY_ADDRESS 0xb8000
#define DISPLAY_LIMIT 4000
#define KERNEL_STACK 0x9ffff //640KB
#define GDT_ITEM(base,limit,type,S,DPL,G) \
(limit&0xffff),(base&0xffff),(((8+S+DPL)<<12)+(type<<8)+((base<<8)>>16)),(((base>>24)<<8)+(((G<<3)+4)<<4)+((limit>>16)&0xf))
struct TSS
{
	u4 pre_link;
	u4 esp0;u4 ss0;
	u4 esp1;u4 ss1;
	u4 esp2;u4 ss2;
	u4 cr3;
	u4 eip;
	u4 eflags;
	u4 eax;u4 ecx;u4 edx;u4 ebx;u4 esp;u4 sbp;u4 esi;u4 edi;
	u4 es;u4 cs;u4 ss;u4 ds;u4 fs;u4 gs;
	u4 ldt_sel;
	u2 t;//debug trap 
	u2 io_bitmap;
}__attribute__ ((packed));
struct DT{
	u2 s1;
	u2 s2;
	u2 s3;
	u2 s4;
}__attribute__ ((packed));
struct DT gdt[GDT_NUM]={
	{0,0,0,0}, //not used
	{GDT_ITEM(0,0xfffff,SEG_DESC_TYPE_CODE_RW,SEG_DESC_S_CODEDATA,DPL_KERNEL,SEG_DESC_G_4KB)}, //kernel code limit 1MB
	{GDT_ITEM(0,0xfffff,SEG_DESC_TYPE_DATA_RW,SEG_DESC_S_CODEDATA,DPL_KERNEL,SEG_DESC_G_4KB)} //kernel data limit 1MB
	//{GDT_ITEM(0x8000,4000,SEG_DESC_TYPE_DATA_RW,SEG_DESC_S_CODEDATA,DPL_KERNEL,SEG_DESC_G_BYTE)} //display
};
struct DT idt[IDT_NUM];
struct DT48{
	u2 limit;
	u4 base;
}__attribute__ ((packed));

struct DT48 GDT48={GDT_SIZE,(u4)&gdt};
struct DT48 IDT48={IDT_SIZE,(u4)&idt};

#define LGDT(GDT48) ({\
__asm__ __volatile__("lgdt (%0)\n\t" \
	::"r"(GDT48));})

#define LIDT(IDT48) ({\
__asm__ __volatile__("lidt (%0)\n\t" \
	::"r"(IDT48));})

#define SET_DATA_SEL(DATA_SEL) ({\
__asm__ __volatile__("movw %0,%%ds\n\t" \
	"movw %0,%%es\n\t" \
	"movw %0,%%fs\n\t" \
	"movw %0,%%gs\n\t" \
	::"r"(DATA_SEL));})

#define SET_STACK(LIMIT) ({\
__asm__ __volatile__("movl %0,%%esp\n\t" \
	::"r"(LIMIT));})

#define PUT_CHAR(c,location)({\
__asm__ __volatile__("movb %0,(%1)\n\t" \
	::"r"(c),"r"((location)));})

u2 current = 2;
void display(char c);
void main(void) {
	SET_DATA_SEL(KERNEL_DATA_SEL);
	//SET_STACK(KERNEL_STACK);
    LGDT(&GDT48);
    LIDT(&IDT48);
    SET_DATA_SEL(KERNEL_DATA_SEL);
    display('H');
    display('A');
    while(1);
}

void display(char c){
	if(current > DISPLAY_LIMIT) current=0;
	PUT_CHAR(c,(DISPLAY_ADDRESS+current));
	current++;
	PUT_CHAR(0xa,DISPLAY_ADDRESS+current);
	current++;
}