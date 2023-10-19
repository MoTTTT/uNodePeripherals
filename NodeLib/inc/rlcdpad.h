/*			Copyright Q Solutions				*/
/*	File:		lcdpad.c					*/
/*	Programmer:	MoT						*/
/*	Module:		IIC bus LcdPad module				*/
/*									*/
/*			History						*/
/* 22:12 20/04/1997    	Cleanup						*/
/*									*/

#define		PING	100		/* LcdPad test byte		*/
#define		RL_RST	0x00		/* Reset LCD			*/
#define		RL_CTR	0x01		/* Write control to LCD		*/
#define		RL_DAT	0x02		/* Write data to LCD		*/
#define		RL_CLR	0x01		/* Clear LCD			*/
#define		RL_L1	0x80		/* Cursor to line 1		*/
#define		RL_L2	0xC0		/* Cursor to line 2		*/
#define		RL_CON	0x0F		/* Cursor On			*/
#define		RL_COF	0x0C		/* Cursor Off			*/

void	init_rkpad	( void );	/* Init Remote Keypad		*/
bit	init_rlcd	( void );	/* Rem LCD to defaults, clear	*/
void	set_rlcd	( char in );	/* Control Remote LCD		*/
char	rputchar	( char out );	/* Send char to remote LCD	*/
void	paint_rlcd	( char*l1, char*l2 );	/* Splash Screen	*/
bit	test_rkey	( void );	/* Test for keypress		*/
char	rgetkey		( void );	/* Get keypress from remote pad	*/

extern bit	rlcd_data;		/* Remote LCD DATA flag		*/
