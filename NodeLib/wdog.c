/*			Copyright Q Solutions				*/
/*	File:		WDog.c						*/
/*	Programmer:	MoT						*/
/*	Module:		Watchdog refresh routine			*/
/*									*/
/*			History						*/
/* 00:40 17/04/1997 	Written from scratch				*/

/* Library files							*/
#include	<reg552.h>

/* Local defines							*/
#define		WD_MASK	0x10		/* Watchdog refresh mask	*/

void	wdog	( char period );	/* Refresh Watchdog timer	*/

void	wdog	( char period )		/* Refresh Watchdog timer	*/
{
	PCON|=	WD_MASK;		/* Enable Refresh		*/
	T3=	period;			/* Refresh Watchdog Timer	*/
}