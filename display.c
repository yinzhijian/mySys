#include "display.h"

u2 current=0;
void display(char c){
        u1 * addr = DISPLAY_ADDRESS;
        if(current > DISPLAY_LIMIT) current=0;
        *(u2 *)(DISPLAY_ADDRESS+current)= 0x0c00|c;
        current+=2;
}
int test(int param){
	return param;
}
