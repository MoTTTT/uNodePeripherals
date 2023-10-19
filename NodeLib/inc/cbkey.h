/************************************************************************/
/*			Copyright Q Solutions				*/
/*	File:		cbkey.h						*/
/*	Programmer:	MoT						*/
/*	Module:		Switch Matrix Keypad Driver			*/
/*									*/
/*			History						*/
/* 19:57 30/03/1997	Written from scratch				*/
/************************************************************************/
/* This module uses P4.0 to P4.3 as row control lines, and P5.0 to P5.4	*/
/* for monitoring lines.						*/
/* Scancodes are numbered:						*/
/* 0 for P4.0, P5.0;	1 for P4.1, P5.0; etc...			*/
/* 5 for P4.0, P5.1;	etc...						*/
/* If more than one key is pressed, the highest of the possible scan-	*/
/* codes will be returned.						*/

void	init_cbkey	( void );	/* Initialise Keypad		*/
bit	test_cbkey	( void );	/* Nonblocking test for keypress*/
char	read_cbkey	( void );	/* Wait for keypress, return it	*/

extern	bit newkey;			/* Keypress flag		*/
extern	unsigned int keysum;		/* Debug sample count		*/
extern	unsigned int keycount;		/* Debug sample count		*/

/* NOTE: This module uses of Timer 0 to generate a sample period.	*/
/*	 The global interrupt enable (IE) needs to be set.		*/
/*	 It can be enabled/disabled by manipulating the Timer 0		*/
/*	 interrupt enable (ET0)						*/
