/*			Copyright Q Solutions				*/
/*	File:		rtc.c						*/
/*	Programmer:	MoT						*/
/*	Module:		IIC Bus PCF8583 Real Time Clock Handler		*/
/*									*/
/*			History						*/
/* 21:02 12/04/1997  	Collection and Cleanup				*/

bit	init_rtc	( void );		/* RTC answering	*/
bit	show_time	( void );		/* Prints time		*/
bit	show_date	( void );		/* Prints date 		*/
void	prompt_time	( );			/* Print time prompt	*/
bit	get_time	( );			/* Read time from keypad*/
bit	test_alarm	( );			/* Test for RTC alarm	*/
