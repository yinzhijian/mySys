#ifndef __SYMBOL__
#define __SYMBOL__
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

#define DISPLAY_ADDRESS ((u1 *)0xb8000)
#define DISPLAY_LIMIT 4000
#define KERNEL_STACK 0x9ffff //640KB
#define GDT_ITEM(base,limit,type,S,DPL,G) \
(limit&0xffff),(base&0xffff),(((8+S+DPL)<<12)+(type<<8)+((base<<8)>>16)),(((base>>24)<<8)+(((G<<3)+4)<<4)+((limit>>16)&0xf))
#endif
