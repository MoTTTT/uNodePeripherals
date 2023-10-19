#include <spminc.c>

void Read_Time (time *ctme);
void Read_Date (date *cdte);
void ScrollUp();
void ScrollDn();
void Print();
/*LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL/
/LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL/
/LLLLLLLLLLLLLLLLLLLLLLLFUNCTIONS FOR UPDATING & LOGGING OF DATALLLLLLLLL*/
void UpDateDuration ()
{
	Read_Time (&CallRec[index].Duration);
	CallRec[index].Duration.hour =
		CallRec[index].Duration.hour -	CallRec[index].TimeOfCall.hour;
	CallRec[index].Duration.minute =
		CallRec[index].Duration.minute - CallRec[index].TimeOfCall.minute;
	CallRec[index].Duration.second =
		CallRec[index].Duration.second - CallRec[index].TimeOfCall.second;
}

void CallEstablished ()
{
Read_Date (&CallRec[index].DateOfCall);	/* initial times */
Read_Time (&CallRec[index].TimeOfCall);

while (PickUp) {
	IE0 = 0;
	UpDateDuration();
	CallRec[index].NoUnits = UnitsUsed;
	ShowInfo();
	PickUp = IE0;

	}
}
Dialling ()
{
char DialledNum[20];
char LengthNum = 0;
ii=0;
set_lcd(LINE_2);
while (PickUp && dial)
	{
	EX0	= 0;
	ET0	= 1;
	TR0	= 1;
	PT0	= 1;
	IE0	= 0;
	for (n=0; n<=30001; n++);
	if (n>30000 && cn !=0)
		{
		if (cn == 0x0a) cn = 0;
		printf("%x",cn);
		DialledNum[ii] = cn;
		ii++;
		LengthNum ++;
		cn = 0;
		}
	PickUp = IE0;
	}
if (UnitsUsed > 0) {
index = maxindex++;

 if ( LengthNum & odd_mask )
	{	/* odd number */
	odd = 1;
	}
 LengthNum = LengthNum/2;
 CallRec[index].NoLength = LengthNum;
 for (n =0; n<LengthNum; n++)
	{
	CallRec[index].NoDialled[n] = 16*DialledNum[2*n]+DialledNum[2*n+1];
	}
 if (odd) {
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
/*LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL/
/LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL*/




/*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII/
/IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII/
/IIIIIIIIIIIIIIIIIIIII  INPUT & VERIFY FUNCTIONSIIIIIIIIIIIIIIIIIIIIIIIII*/
	service_pad	( char in )
{
	switch	( in )
	{
	case 0x0C:	ScrollUp(); 	break;
	case 0x0D:	ScrollDn(); 	break;
	case 0x0F:	Print();	break;
	case 0x0E:	Password();	break;
	case 0x0A:	D2DCalc();	break;
	}
	x1_flag=0;
}
bit Get_Times()
{
return 1;
}
void Read_Time (time *ctme)
{
ctme->second = index;
ctme->minute = index+1;
ctme->hour = index +2;
}
void Read_Date (date *cdte)
{
cdte->day=index;
cdte->month=0;
cdte->year =0;
}
void FindDate()
{
}
bit Exist(date cdate)
{
}
int CheckPswd()
{
return 1;
}
/*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII/
/IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*/




/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS/
/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS/
/SSSSSSSSSSSSSSSSSSSSS  SCREEN FUNCTIONS SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/
void ShowInfo()
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
	if (odd) {
		printf("%bX",CallRec[index].NoDialled[++ii]);
		CallRec[index].NoLength += 100;
		}


	set_lcd(LINE_2+12);
	printf("%uc",CallRec[index].NoUnits*UnitPrice);
	odd = 0;	/* reset odd */
}
void PMenu()
{
}
/*SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS/
/SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS*/




/*KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK/
/KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK/
/KKKKKKKKKKKKKKKKKKKKK  KEYBOARD FUNCTIONS    RESTRICTIONS KKKKKKKKKKKKKK*/
void Password()
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
		case 't': ChangeTime();		break;
		}

	}
 else return;
}
void Baring()
{
}
void ChangeTime()
{
}
void EditPswrd()
{
}
/*KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK/
/KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK*/



/*************************************************************************/
/*************************************************************************/
/***********************KEYBOARD FUNCTIONS NO RESTRICTIONS****************/
void ScrollUp()
{
	set_lcd(CLEAR);
	index++;
	if (index == maxindex) index = maxindex-1;
	ShowInfo();
	for (i=0; i<30000; i++);
	for (i=0; i<30000; i++);	/* delay 800ms */
	return;
}
void ScrollDn()
{
	set_lcd(CLEAR);
	index--;
	if (index < 0) index = 0;	/* or bottom of stack if overflow */
	ShowInfo();
	for (i=0; i<30000; i++);
	for (i=0; i<30000; i++);
	return;
}
void D2DCalc()
{
}
void Print()
{
}
/*************************************************************************/
/*************************************************************************/





/*IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII/
/IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII/
/IIIIIIIIIIIIIIIIIIIII  INTERUPT ROUTINES IIIIIIIIIIIIIIIIIIIIIIIIIIIIIII*/
meter_int()	interrupt 7
{
ECT1 = 0;
dial = 0;
UnitsUsed++;
for (i=0; i<10000; i++);
for (i=0; i<30000; i++);	/* delay 800mS, fastest meterpulse is 1.5sec */
CTI1 = 0;	/* reset int */
set_lcd(CLEAR);
ECT1 = 1;
}


bit check_ringing()
{
for (i=0; i<=900; i++);	/* delay for 14.6mS  (14-18mS)*/
IE0 = 0;		/* reset the line status */
			/* IE0 is the line status:
				1 is on hook and 0 is off hook*/
			/* read line status, if its high,
			then ringing, else loop line */
if (!IE0 && !PickUp) {	/*if Pickup has occured, then ringing can't occur*/
		/* RINGING SUBROUTINE HERE */
		/* make sure that the whole of check_ringing is not
			longer than 20mS or the delay routine might delay
			right pass the ringing pulse and will thus see a
			normal off hook condition
		---______---______---______---
			-12mS-8mS-                    */
		r1 = 0;
		r  = 0;
		RingOn = 1;
		set_lcd (LINE_2+0);
		printf("ringing");
		for (i=0; i<=23677; i++);
		for (i=0; i<=24577; i++);	/* time out 800mS */

		EX0 = 1;
		return 1;
		}
	else { return 0; }
}

	PulseCount () interrupt 1
{
	ET0 = 0;
	n=0;
	cn++;
/*	set_lcd (LINE_2);
	printf("   Count!%x     ",cn);	 /*	delay 90mS
*/	for (i=0;i<=5530;i++);
	ET0 = 1;
}

DetectPickup() interrupt 0
{
EX0 = 0;	/* int0 disable */
if (check_ringing())  return;
set_lcd(LINE_1);
cnt++;
set_lcd(CLEAR);
RingOn = 0;
PickUp = 1;		/*pickup occured, no ringing can occur after this*/
printf("   Pickup!%d     ",cnt);
for (i=0; i<=5530; i++);
EX0 = 0;		/* int0 disable */
}
/*************************************************************************/
/*************************************************************************/



void init ()
{
	index 		= 0;
	maxindex	= 0;
	dial		= 0;
	RingOn		= 0;
	PickUp		= 0;	/* no pickup occured */
	CTCON		= 0x08;	/* CT1I (interrupt3) meter int is falling edge*/
	ECT1		= 1;	/* enable CTI1 */
	UnitsUsed	= 0;
	B		= 0;	/* init reg B */
	IT0		= 0;	/* interrupt control bit level triggered*/
	EX0		= 1;	/* int0 enable*/
	EA		= 1;	/* enable all int's*/
	TH0		= 0xFF; /* timer0 reload value */
	TL0		= 0xFF;
	TMOD		= 0x06; /* timer0 set in mode 2, 8bit auto reload counter*/
	TR0 		= 0;	/* switch off timer 1			*/
	PT0		= 0;
	init_lcd( );
	EX1		= 1;
	UnitPrice 	= 19;
	ChangeTime();
}


/*MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/
/*MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/
/*MMMMMMMMMMMMMMMMMMMMMMMMMMMAIN ROUTINE MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/
	main		( )
{
	init	( );
	while	( 1 )
	{
	if (PickUp) {
		dial = 1;
		Dialling();
		}
	while (RingOn) {	/* disable keyboard until ringing stops */
	EX1 = 0;
	for (r = 0; r<4; r++)
		for (r1 = 0; r1<30002; r1++)
		{
		if (r==3 && r1== 30000)
			{
			RingOn = 0;
			set_lcd(CLEAR);
			}
		}
	EX1 = 1;	/* enable keyboard after ringing */
	}

	if	( x1_flag  && !RingOn)
		service_pad	((*KPAD)-240 );
	}


}
