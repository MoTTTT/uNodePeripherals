/************************************************************************/
/*			SPM_M1.F					*/
/*			Written by C.J. van Rensberg			*/
/*			Edited for the 80C51 by M.J.Colley		*/
/************************************************************************/

#pragma		ROM (COMPACT)
#pragma		SMALL
#pragma		CODE
#pragma		SYMBOLS
#pragma		PAGELENGTH(64)

/************************************************************************/
/*				INCLUDES				*/
/************************************************************************/
#include	<stdio.h>
#include	<reg51.h>
/************************************************************************/

/************************************************************************/
/*				DEFINES					*/
/************************************************************************/
#define		KPAD	(( char *) 0x2FD00L)	/* Address of keypad	*/
#define		DTMF	(( char *) 0x2FF00L)	/* Address of DTMF dec	*/
#define		LCD_DATA	0		/* Values of io_stream	*/
#define		LCD_COMMAND	1		/*			*/
#define		CLEAR		0x01		/* LCD control commands	*/
#define		LINE_1		0x80		/*			*/
#define		LINE_2		0xC0		/*			*/
#define		LINE_3		0x90
#define		LINE_4		0xD0
#define		ODD_MASK	00000001
#define		CallRec		((Phones *) 0x20000L)
#define		LCD		0xFB
#define		RTC_CON		(( char *) 0x2FC00L)
#define		RTC_SEC		(( char *) 0x2FC02L)
#define		RTC_TSEC	(( char *) 0x2FC03L)
#define		RTC_MIN		(( char *) 0x2FC04L)
#define		RTC_TMIN	(( char *) 0x2FC05L)
#define		RTC_HOR		(( char *) 0x2FC06L)
#define		RTC_THOR	(( char *) 0x2FC07L)
#define		RTC_DAY		(( char *) 0x2FC08L)
#define		RTC_TDAY	(( char *) 0x2FC09L)
#define		RTC_MON		(( char *) 0x2FC0AL)
#define		RTC_TMON	(( char *) 0x2FC0BL)
#define		RTC_YER		(( char *) 0x2FC0CL)
#define		RTC_TYER	(( char *) 0x2FC0DL)
#define		RTC_IREG	(( char *) 0x2FC0FL)
#define		CRYSTAL		2

/************************************************************************/

/************************************************************************/
/*				DECLARATIONS				*/
/************************************************************************/
/************************************************************************/
/*				STRUCTURES				*/
/************************************************************************/

typedef	struct	{char	second;	char	minute;	char	hour;} time;
typedef	struct	{char	day;	char	month;	char	year;} date;
typedef struct	{date  DateOfCall;		time  TimeOfCall;
		time  Duration;			char  NoDialled[10];
		char  NoLength;			unsigned int   NoUnits;
		} Phones;
/************************************************************************/
/*				VARIABLES				*/
/************************************************************************/

time		ttest;
bit		key_flag;			/* set by rxd_int	*/
bit		DTMF_flag=0;
char		io_stream;			/* used by putchar	*/
char		lcd_addr= LCD;

/* 				general global variables 		*/
unsigned int 	n,cnt,cn,i,			/* gen counters/timer	*/
		maxindex,			/* latest CallRecord	*/
		ii,r;
unsigned int 	UnitsUsed,UnitPrice;
char 		ch;
int 		r1;
char		dtmf_in;


/*	flags for identifying states in which the program resides	*/
bit		PickUp;				/* phone is off hook	*/
bit		dial;				/* Set during dialling	*/
bit		RingOn;				/* Set during ringing	*/
bit		odd = 0;			/* number dialled odd	*/
int		index;				/* record number for	*/
						/* CallRec (0 - 2000)	*/

/************************************************************************/
/*				FUNCTIONS				*/
/************************************************************************/

void	init ();
void	init_RTC( );
void	set_lcd	( char command );		/* Sets up Command reg	*/
void	init_lcd( );				/* Initialise LCD displ	*/
char	getkey	( );				/* Waits for key_flag	*/
void	Read_Time (time *t );
void	Read_Date (date *cdte);
void	ScrollUp();
void	ScrollDn();
void	Print();

/*		keyboard functions with no restrictions			*/
void	Scrollup();
void	Scrolldn();
void	print();
void	D2DCalc();
/*		END keyboard functions with no restrictions		*/

/*		keyboard functions with password restrictions		*/
void	Password();
/*		Password() controls access to all the following routines*/
bit	ChangeTime();
void	EditPswrd();
void	Baring();				/* program bar numbers	*/
/*		END keyboard functions with password restrictions	*/
/*		Screen functions					*/
void    ShowInfo();
void	PMenu();
/*		END screen functions					*/

/*		Input & verifying functions				*/
void	service_pad	( char in );
/* 	service_pad()		 controlls access to all these functions*/
date	InputDate(date cdate);
void 	D2D();
int	CheckPswd();
int	CheckDate(date cdate);
void	FindDate();
bit	Exist(date cdate);
/* 		END input & verifying functions				*/

/* 		Functions for updating and logging of data		*/
void	UpDateDuration ();
void	CallEstablished ();
/* 		END functions for updating and logging of data		*/

bit 	check_ringing();	/* differentiates off-hook & ringing	*/
void    Dialling ();		/* decodes pulse dialling 	    	*/

/************************************************************************/

/************************************************************************/
/*				DEFINITIONS				*/
/************************************************************************/

void	set_lcd		( char command )	/* Sets up Command reg	*/
{	
	io_stream= LCD_COMMAND;
	putchar	( command );
	io_stream= LCD_DATA;
}

void	init_RTC	( )
{
	*RTC_CON=	5;
	*RTC_IREG=	1;
	*RTC_CON=	0;
}

void	init_lcd	( )			/* Initialise LCD disp	*/
{
	io_stream= LCD_COMMAND;
	putchar	( 0x38 );			/* SET LCD FOR 8 BIT	*/
	putchar	( 0x0C );			/* DISP= ON, CURSOR= OFF*/
	putchar	( 0x06 );			/* AUTO INC, FREEZE	*/
	putchar	( CLEAR );			/* CLEAR SCREEN		*/
	io_stream= LCD_DATA;
}

char	getkey		( )
{	
	while	( !key_flag );
	key_flag=0;
	return( (*KPAD)- 240 );
}


/************************************************************************/
/*LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL*/
/*			FUNCTIONS FOR UPDATING & LOGGING OF DATA	*/
/*LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL*/
/************************************************************************/
void	UpDateDuration ()
{
	Read_Time (&CallRec[index].Duration);
	CallRec[index].Duration.hour =
	 CallRec[index].Duration.hour -	CallRec[index].TimeOfCall.hour;
	CallRec[index].Duration.minute =
	 CallRec[index].Duration.minute - CallRec[index].TimeOfCall.minute;
	CallRec[index].Duration.second =
	 CallRec[index].Duration.second - CallRec[index].TimeOfCall.second;
}

void	CallEstablished ()
{
	Read_Date (&CallRec[index].DateOfCall);	/* initial times	*/
	Read_Time (&CallRec[index].TimeOfCall);
	while (PickUp)
	{
		IE0 = 0;
		UpDateDuration();
		CallRec[index].NoUnits = UnitsUsed;
		ShowInfo();
		PickUp = IE0;
	}
}

void    Dialling ()
{
char	DialledNum[20];
char	LengthNum=	0;
	ii=	0;
	set_lcd(LINE_2);
	while (PickUp && dial)
	{
		EX0	= 0;
		ET0	= 1;
		TR0	= 1;
		PT0	= 1;
		IE0	= 0;
		for 	(n=0; n<=5426; n++);	/* delay ?		*/
		if 	(n>5425 && cn && !DTMF_flag  )
		{
			cn= (cn == 0x0a) ? 0: cn;
			printf("%x",cn);
			DialledNum[ii] = cn;
			ii++;
			LengthNum ++;
			cn=	0;
		}
		if	( DTMF_flag )
		{
			cn= (dtmf_in==10) ? 0: dtmf_in;
			printf("%x",cn);
			DialledNum[ii]=	cn;
			ii++;
			LengthNum++;
			DTMF_flag=	0;
			cn=	0;
		}
		PickUp = IE0;
	}
	if (UnitsUsed > 0)
	{
		index = maxindex++;
		if ( LengthNum & ODD_MASK )	odd = 1;
		LengthNum = LengthNum/2;
		CallRec[index].NoLength = LengthNum;
		for (n =0; n<LengthNum; n++)
		{
			CallRec[index].NoDialled[n] =
				16*DialledNum[2*n]+DialledNum[2*n+1];
		}
		if (odd)
		{
			CallRec[index].NoDialled[++n] = DialledNum[2*n];
			CallRec[index].NoLength += 100;
		}
		odd = 0;
		CallEstablished();
	}
	cn = 0;
	UnitsUsed = 0;
	set_lcd(CLEAR);
	EX0 = 1;
	PT0 = 0;
	TR0 = 0;
}

/************************************************************************/
/*			  INPUT & VERIFY FUNCTIONS			*/
/************************************************************************/

void	service_pad	( char in )
{
	switch	( in )
	{
	case 0x0C:	ScrollUp(); 	break;
	case 0x0D:	ScrollDn(); 	break;
	case 0x0F:	Print();	break;
	case 0x0E:	Password();	break;
	case 0x0A:	D2DCalc();	break;
	}
	key_flag=0;
}

bit	Get_Times()
{
	return 1;
}

void	Read_Time 	( time *t )
{
	t->hour=	(*RTC_HOR & 0x0F )+ (*RTC_THOR & 0x0F )* 16;
	t->minute=	(*RTC_MIN & 0x0F )+ (*RTC_TMIN & 0x0F )* 16;
	t->second=	(*RTC_SEC & 0x0F )+ (*RTC_TSEC & 0x0F )* 16;
}

void	Show_Time	( time *t )
{
	printf	( "%02bX:%02bX:%02bX", t->hour, t->minute, t->second );
}

void	Read_Date (date *cdte)
{
	cdte->day=	(*RTC_DAY & 0x0F)+ (*RTC_TDAY & 0x0F)* 16;
	cdte->month=	(*RTC_MON & 0x0F)+ (*RTC_TMON & 0x0F)* 16;
	cdte->year=	(*RTC_YER & 0x0F)+ (*RTC_TYER & 0x0F)* 16;
}

void	FindDate()
{
}

bit	Exist(date cdate)
{
}

int	CheckPswd()
{
	return 1;
}
/*LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL*/
/************************************************************************/

/************************************************************************/
/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/
/*				SCREEN FUNCTIONS			*/
/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/
/************************************************************************/

void    ShowInfo()
{
	odd = 0;	/* reset odd */
	set_lcd(LINE_1+0);
	printf("%02bX/%02bX/%02bX%02bX:%02bX:%02bX",
		CallRec[index].Duration.hour,
		CallRec[index].Duration.minute,
		CallRec[index].Duration.second,
		CallRec[index].TimeOfCall.hour,
		CallRec[index].TimeOfCall.minute,
		CallRec[index].TimeOfCall.second);
	set_lcd(LINE_2+0);
	if (CallRec[index].NoLength > 100)
	{
		odd =1;
		CallRec[index].NoLength = CallRec[index].NoLength - 100;
	}
	for ( ii=0; ii< CallRec[index].NoLength; ii++)
	{
		printf("%02bX",CallRec[index].NoDialled[ii]);
	}
	if (odd)
	{
		printf("%bX",CallRec[index].NoDialled[++ii]);
		CallRec[index].NoLength += 100;
	}
	set_lcd(LINE_2+12);
	printf("%uc",CallRec[index].NoUnits*UnitPrice);
	odd = 0;	/* reset odd */
}

void	PMenu()
{
}
/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/

/************************************************************************/
/*KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK*/
/*			KEYBOARD FUNCTIONS    RESTRICTIONS		*/
/*KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK*/
/************************************************************************/
void	Password()
{
	if (CheckPswd())
	{
		PMenu();
		ch = getkey();
		switch (ch)
		{
			case 'e': while (!Get_Times());	break;
			case 'p': EditPswrd(); 		break;
			case 'b': Baring(); 		break;
			case 't':
			{
				while	( !ChangeTime() );
				break;
			}
		}
	}
	else return;
}

void	Baring()
{
}

bit	ChangeTime	( )
{
char	idata	in, cursor= 0;
char	tmh,tmm,tms;
char	K_BUF[6];
	set_lcd	( LINE_2 );
	printf	( " Time: HH:MM:SS" );
	set_lcd	( LINE_2+ 7 );
	set_lcd	( 0x0F );
	while	( cursor< 6 )
	{
		while	( (in=	getkey	( )) > 9 );
		K_BUF[ cursor ]= in;
		printf	( "%bX", in );
		if(( cursor== 1 )|| ( cursor== 3 ))
			printf	( ":" );
		cursor++;
	}
	tmh= 10* K_BUF[0]+ K_BUF[1];
	tmm= 10* K_BUF[2]+ K_BUF[3];
	tms= 10* K_BUF[4]+ K_BUF[5];
	if	((tmh <= 23) && (tmm <= 59) && (tms <= 59))
	{
		*RTC_CON=	4;
		*RTC_THOR=	K_BUF[0];	*RTC_HOR=	K_BUF[1];
		*RTC_TMIN=	K_BUF[2];	*RTC_MIN=	K_BUF[3];
		*RTC_TSEC=	K_BUF[4];	*RTC_SEC=	K_BUF[5];
		*RTC_CON=	0;
		set_lcd	( 0x0C );
		return	( 1 );
	}
	return	( 0 );
}

void	EditPswrd()
{
}
/*KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK*/

/************************************************************************/
/************************************************************************/
/*			KEYBOARD FUNCTIONS NO RESTRICTIONS		*/
/************************************************************************/

void	ScrollUp()
{
	set_lcd(CLEAR);
	index++;
	if (index == maxindex) index = maxindex-1;
	ShowInfo();
	for (i=0; i<30000; i++);
	for (i=0; i<30000; i++);	/* delay 800ms */
	return;
}

void	ScrollDn()
{
	set_lcd(CLEAR);
	index--;
	if (index < 0) index = 0;	/* or bottom of stack if overflow */
	ShowInfo();
	for (i=0; i<30000; i++);
	for (i=0; i<30000; i++);
	return;
}

void	D2DCalc()
{
}

void	Print()
{
}
/************************************************************************/

/************************************************************************/
/*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*/
/*				INTERUPT ROUTINES			*/
/*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*/
/************************************************************************/

bit	check_ringing()
{
	for	(i=0; i<=178; i++);	/* delay for 14.6mS  (14-18mS)	*/
	IE0=	0;			/* reset the line status 	*/
					/* IE0 is the line status:	*/
					/* 1= on hook, 0= off hook	*/
					/* read line status, if high,	*/
					/* then ringing, else loop line */
	if	(!IE0 && !PickUp)	/* if Pickup has occured,	*/
					/* then ringing can't occur	*/
	{
					/* RINGING SUBROUTINE:		*/
					/* make sure that the whole of	*/
					/* check_ringing is not	longer	*/
					/* than 20mS or delay routine	*/
					/* might delay past ringing	*/
					/* pulse and will thus see	*/
					/* normal off hook condition	*/
					/* ---______---______---______--*/
					/*    -12mS-8mS-		*/
		r1=	0;
		r=	0;
		RingOn=	1;
		set_lcd (LINE_2+0);
		printf	( "ringing" );
		for(i=0; i<=15000; i++);/* time out 800mS 		*/
		EX0=	1;
		return	1;
	}
	else	return	0;
}

void	DetectPickup()	interrupt 0
{
	EX0=	0;			/* int0 disable			*/
	if	( check_ringing() ) return;
	set_lcd	( LINE_1 );
	cnt++;
	set_lcd	( CLEAR );
	RingOn=	0;
	PickUp=	1;			/* pickup occured, no ringing	*/
					/* can occur after this		*/
	printf	("   Pickup!%d     ",cnt);
	for	( i=0; i<=1000; i++ );	/* delay 84mS 11=5530 2=1000	*/
	EX0=	0;			/* int0 disable			*/
}

void	PulseCount()	interrupt 1
{
	ET0 = 0;
	n=0;
	cn++;
	for (i=0;i<=1000;i++);		 /* delay 90mS 11=5530 2=882	*/
	ET0 = 1;
}

void	meter_int()	interrupt 2
{
	dial = 0;
	UnitsUsed++;
	set_lcd	( CLEAR );
}

void	multi_int()	interrupt 3
{
	if	( P1_5 )	
	{
		DTMF_flag=	1;
		dtmf_in=	(*DTMF & 0x0F);
		n=	5425;
        }
	if	( P1_6 )	key_flag=	1;
}

/************************************************************************/

/************************************************************************/

void init ()
{
	index=		0;
	maxindex=	0;
	dial=		0;
	RingOn=		0;
	PickUp=		0;		/* no pickup occured		*/
	UnitsUsed=	0;
	IT0=		0;		/* int0 level triggered		*/
	EX0=		1;		/* int0 enable			*/
	EX1=		1;		/* int1 enable			*/
	IT1=		1;		/* int1 edge triggered		*/
	ET1=		1;		/* enable DTMF, plug, keypad int*/
	ES=		1;		/* enable rxd interrupt		*/
	SCON=		0x50;		/* set sio mode			*/
	EA=		1;		/* enable all int's		*/
	TH0=		0xFF;		/* timer0 reload value 		*/
	TL0=		0xFF;
	TH1=		0xFF;
	TL1=		0xFF;
	TMOD=		0x66; 	/* timer0 set in mode 2, 8 bit	*/
					/* auto reload counter		*/
					/* timer1 set in mode 1, 16 bit	*/
					/* timer			*/
	TR0=		0;		/* switch off timer 0		*/
	TR1=		1;		/* start timer 1		*/
	init_lcd	( );
	init_RTC	( );
	UnitPrice=	19;
	while	( !ChangeTime() );
}

/************************************************************************/
/*MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/
/*				MAIN ROUTINE				*/
/*MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/
/************************************************************************/
void	main	( )
{
	init	( );
	printf	( " SPM51 .... " );
	while	( 1 )
	{
		if 	( PickUp )
		{
			P1_0=	0;	/* Power up DTMF Chip		*/
			DTMF_flag=0;
			dial=	1;
			Dialling();
			P1_0=	1;	/* Power down DTMF Chip		*/
		}
		while (RingOn)	/* disable keyboard until ringing stops */
		{
			EX1=	0;
			for	( r = 0; r<4; r++ )
			{
				for	( r1 = 0; r1<30002; r1++ )
				{
					if	( r==3 && r1== 30000 )
					{
						RingOn = 0;
						set_lcd(CLEAR);
					}
				}
			}
			EX1 = 1;	/* enable keyboard after ringing */
		}
		if	( key_flag  && !RingOn )
			service_pad	((*KPAD)-240 );
	}
}
