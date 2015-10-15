#include "symbol.h"
#include "display.h"

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

#define inp(val,port)({\
__asm__ __volatile__("inb %0,%1\n\t" \
	:"a"(val):"0"(val),"n"(port);val;})
#define outp(val,port)({\
__asm__ __volatile__("outb %1,%0\n\t" \
	::"n"(val),"n"(port);})
struct cmos_time_struct{
u1 second;
u1 minute;
u1 hour;
u1 day;
u1 month;
u1 year;
}cmos_time_struct;
void get_cmos_time(){
	outp();	
}
void main(void) {
	SET_DATA_SEL(KERNEL_DATA_SEL);
	//SET_STACK(KERNEL_STACK);
    LGDT(&GDT48);
    LIDT(&IDT48);
    SET_DATA_SEL(KERNEL_DATA_SEL);
    display('H');
    display('A');
    display((char)test('Y'));
    while(1);
}
/*
void display(char c){
	u1 * addr = DISPLAY_ADDRESS;
	if(current > DISPLAY_LIMIT) current=0;
	*(DISPLAY_ADDRESS+current)= c;
	current++;
	*(DISPLAY_ADDRESS+current)= 0xa;
	//PUT_CHAR(0xa,DISPLAY_ADDRESS+current);
	current++;
}*/
