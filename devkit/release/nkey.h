/*			Copyright Q Solutions				*/
/*	File:		nkey.h						*/
/*	Programmer:	MoT						*/
/*	Module:		uNode Keypad header file			*/
/*									*/

extern bit	x1_flag;			/* set by x1_int	*/

char	ngetkey		( void );		/* uNode getkey routine	*/
bit	test_x1		( void );		/* Return 1 if key int	*/
void	init_nkey	( void );		/* Set up keypad	*/
