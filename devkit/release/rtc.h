/*			Copyright Q Solutions				*/
/*	File:		rtc.h						*/
/*	Programmer:	MoT						*/
/*	Module:		IIC Bus PCF8583 Real Time Clock Handler		*/
/*									*/

#ifndef TIMESTRUCT
#define TIMESTRUCT
typedef struct { byte h; byte m; byte s; } time;
typedef struct { byte d; byte m; } date;
#endif

bit	init_rtc	( void );		/* RTC answering	*/
bit	get_time	( time *in );		/* Read time		*/
bit	set_time	( time *in );		/* Set time		*/
bit	get_date	( date *in );		/* Read date 		*/
bit	test_alarm	( void );		/* Test for RTC alarm	*/
