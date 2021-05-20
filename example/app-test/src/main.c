//============================================================================
// Name        : main.cpp
// Author      : Iulian Gheorghiu (morgoth@devboard.tech)
// Version     : 1.0
// Copyright   : GNUv2
// Description : Led play
//============================================================================

#include "riscv_hal.h"

#define CPU_FREQ		(16000000)
#define delay_cycles	500
//#define delay_cycles	(CPU_FREQ / 23)
//#define RTC_PERIOD		(CPU_FREQ / 1000)

volatile unsigned long long STimerCnt = 0;

#ifdef __cplusplus
extern "C" {
#endif

int IRQHandler_1(unsigned int int_nr)
{
	STimerCnt ++;
	return 1;
}
#ifdef __cplusplus
}
#endif

typedef struct PORT_struct
{
	volatile unsigned int OUT;  /* I/O Port Output */
	volatile unsigned int OUTSET;  /* I/O Port Output Set */
	volatile unsigned int OUTCLR;  /* I/O Port Output Clear */
	volatile unsigned int DIR;  /* I/O Port direction, 1=Out, 0=In */
	volatile unsigned int IN;  /* I/O Port input */
} PORT_t;

#define LED_IO				(*(PORT_t *) 0x100)  /* Virtual Port */

#define SET		OUTSET
#define CLEAR	OUTCLR

void delay(unsigned long time)
{
	unsigned long long time_to_tick = STimerCnt + time;
	unsigned long long rtc_cnt_int;
	do
	{
		rtc_cnt_int = STimerCnt;
	} while (time_to_tick > rtc_cnt_int);

	/*STimerCnt = time;
	while(STimerCnt)
	{
		STimerCnt--;
	};*/

}


void left_to_right(unsigned long times)
{
	LED_IO.CLEAR = 0xFF;
	delay(times);
	LED_IO.SET = 0b00000001;
	delay(times);
	LED_IO.CLEAR = 0b00000001;
	LED_IO.SET = 0b00000010;
	delay(times);
	LED_IO.CLEAR = 0b00000010;
	LED_IO.SET = 0b00000100;
	delay(times);
	LED_IO.CLEAR = 0b00000100;
	LED_IO.SET = 0b00001000;
	delay(times);
	LED_IO.CLEAR = 0b00001000;
	LED_IO.SET = 0b00010000;
	delay(times);
	LED_IO.CLEAR = 0b00010000;
	LED_IO.SET = 0b00100000;
	delay(times);
	LED_IO.CLEAR = 0b00100000;
	LED_IO.SET = 0b01000000;
	delay(times);
	LED_IO.CLEAR = 0b01000000;
	LED_IO.SET = 0b10000000;
	delay(times);
	LED_IO.CLEAR = 0xFF;
	delay(times);
}

void right_to_left(unsigned long times)
{
	LED_IO.CLEAR = 0xFF;
	delay(times);
	LED_IO.SET = 0b10000000;
	delay(times);
	LED_IO.CLEAR = 0b10000000;
	LED_IO.SET = 0b01000000;
	delay(times);
	LED_IO.CLEAR = 0b01000000;
	LED_IO.SET = 0b00100000;
	delay(times);
	LED_IO.CLEAR = 0b00100000;
	LED_IO.SET = 0b00010000;
	delay(times);
	LED_IO.CLEAR = 0b00010000;
	LED_IO.SET = 0b00001000;
	delay(times);
	LED_IO.CLEAR = 0b00001000;
	LED_IO.SET = 0b00000100;
	delay(times);
	LED_IO.CLEAR = 0b00000100;
	LED_IO.SET = 0b00000010;
	delay(times);
	LED_IO.CLEAR = 0b00000010;
	LED_IO.SET = 0b00000001;
	delay(times);
	LED_IO.CLEAR = 0xFF;
	delay(times);
}

void center_to_center(unsigned long times)
{
	LED_IO.CLEAR = 0xFF;
	delay(times);
	LED_IO.SET = 0b10000001;
	delay(times);
	LED_IO.CLEAR = 0b10000001;
	LED_IO.SET = 0b01000010;
	delay(times);
	LED_IO.CLEAR = 0b01000010;
	LED_IO.SET = 0b00100100;
	delay(times);
	LED_IO.CLEAR = 0b00100100;
	LED_IO.SET = 0b00011000;
	delay(times);
	LED_IO.CLEAR = 0b00011000;
	LED_IO.SET = 0b00100100;
	delay(times);
	LED_IO.CLEAR = 0b00100100;
	LED_IO.SET = 0b01000010;
	delay(times);
	LED_IO.CLEAR = 0b01000010;
	LED_IO.SET = 0b10000001;
	delay(times);
	LED_IO.CLEAR = 0xFF;
	delay(times);
}

unsigned char cnt = 0;

int
main()
{
	LED_IO.DIR = 0xFFFFFFFF;
	LED_IO.CLEAR = 0xFF;
    while(1)
    {
    	delay(delay_cycles);
    	LED_IO.OUT = cnt++;
    	//left_to_right(delay_cycles);
    	//right_to_left(delay_cycles);
    	//center_to_center(delay_cycles);
    }
}
