/*			Copyright Q Solutions				*/
/*	File:		time.h						*/
/*	Programmer:	MoT						*/
/*	Module:		Time related routines				*/
/*									*/

#ifndef TIMESTRUCT
#define TIMESTRUCT
typedef struct { byte h; byte m; byte s; } time;
typedef struct { byte d; byte m; } date;
#endif

bit	show_time	( void );		/* Prints current time	*/
bit	print_time	( time *out );		/* Prints a time	*/
bit	show_date	( void );		/* Prints current date	*/
bit	print_date	( date *out );		/* Prints a date	*/
void	prompt_time	( void );		/* Print time prompt	*/
long	dif_time	( time *t1, time *t2 );	/* Time diff in s	*/
long	tim2lng		( time *in );		/* Time in seconds	*/
