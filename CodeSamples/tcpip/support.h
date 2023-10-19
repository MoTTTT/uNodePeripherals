
/* +++=>>> * %n  Edition: %v  Last changed: %f  By: %w */
/* SUPPORT.H  Edition: 7  Last changed: 11-Aug-94,13:07:10  By: HARRY */
/* +++=>>> '%l' */
/* Currently extracted for edit by: '***_NOBODY_***' */
/*
    SUPPORT.H -- Support Level Definitions for USNET

    Copyright (C) 1993 By
    United States Software Corporation
    14215 N.W. Science Park Drive
    Portland, Oregon 97229

    This software is furnished under a license and may be used
    and copied only in accordance with the terms of such license
    and with the inclusion of the above copyright notice.
    This software or any other copies thereof may not be provided
    or otherwise made available to any other person.  No title to
    and ownership of the software is hereby transferred.

    The information in this software is subject to change without 
    notice and should not be construed as a commitment by United
    States Software Corporation.
*/


/* =========================================================================
   Multitasking support.  As shipped, the macros assume there is no separate
   multitasker.  You can change them to use one. */

/* event numbers, possibly not dependent on the multitasker */
#define SIG_RC(conno) (conno+conno)		/* read connection */
#define SIG_CC(conno) (conno+conno+1)		/* control connection */
#define SIG_RN(netno) (2*netno+2*NCONNS)	/* read network */
#define SIG_WN(netno) (2*netno+2*NCONNS+1)	/* write network */
#define SIG_ARP (2*(NCONNS+NNETS))		/* ARP */
#define SIG_RARP (2*(NCONNS+NNETS)+1)		/* RARP */

#if MT == 0
#define YIELD() \
{ int wnetno; \
    for (wnetno=0; wnetno<NNETS; wnetno++) \
	NetTask(wnetno); \
}
#define TASKFUNCTION void
#define RUNTASK(func, prior, mp) 0, func(mp)   	/* create and run a task */
#define WAITNOMORE(signo) 		      	/* signal */
#define WAITNOMORE_IR(signo) 		      	/* signal in interrupt */
/* wait with timeout */
#define WAITFOR(condition, signo, msec, flag) \
{ unsigned long wwul1; \
    for (flag=0,wwul1=TimeMS()+msec; !(condition); ) { \
	if (TimeMS() >= wwul1) { \
	    flag = 1; \
	    break; \
	} \
	YIELD(); \
}   } 
/* Prevent and restore preempting.  Null if no preempting is used. */
#define BLOCKPREE()
#define RESUMEPREE()
#endif

#if MT == 1
#include "mtcfg.h"
#include "mtlib.h"
#include "mtstdio.h"
#include "mtdata.h"
#define SERV_PRIOR 100
#define CLIENT_PRIOR 100
#define NET_PRIOR 110
/* NOTE: for I386 protected mode, take out the work FAR from the next line!!! */
#define TASKFUNCTION void FAR
#define RUNTASK(func, prior, mp) \
   	runtsk(prior, (void (far *)(void))func, 1500, mp)
#define YIELD() scdtsk()
#define WAITNOMORE(signo) setevt(signo)
#define WAITNOMORE_IR(signo) MTqcmd_c(SETEVT, signo)
#define WAITFOR(condition, signo, msecs, flag) \
for (flag=SUCCESS; ; ) { \
    if (condition) { \
        flag = 0; \
	break; \
    } \
    if (flag!=SUCCESS) \
	break; \
    flag = wteset(signo, (unsigned int)(long)(msecs*CLOCKHZ/1000L)); \
    if (flag == SUCCESS) clrevt(signo); \
}
#define BLOCKPREE() MASK_INTS()
#define RESUMEPREE() UNMASK_INTS()
#undef CLOCKS_PER_SEC
#define CLOCKS_PER_SEC CLOCKHZ
extern unsigned int clocks_per_sec;
#define Nclkinit() clocks_per_sec = (unsigned int)CLOCKS_PER_SEC
#define Nclkterm()
#define clock get_sys_time
#endif


/* =========================================================================
   Macros to simplify coding. */

#ifdef BIG
#define NC2(val) val
#define NC4(val) val
#else
#define NC2(val) (((val&0xff) << 8) | ((unsigned short)val >> 8))
#define NC4(val) ( ((long)val<<24) | (((long)val&0xff00)<<8) | \
    (val>>8)&0xff00 | ((unsigned long)val>>24) )
#endif


/* =========================================================================
   Function prototypes for support functions. */

unsigned short Nchksum(unsigned short *sp, int cnt);
TASKFUNCTION NetTask(int netno);
unsigned short Nportno(void);
void Nputchr(char);
int Nchkchr(void);
int Ngetchr(void);
int Ninitsupp(void);
unsigned long TimeMS(void);
void SetTimeMS(unsigned long);
int Nsprintf(char *buff, char *form, ...);
int Nprintf(char *form, ...);
int Nsscanf(char *buff, char *form, ...);
void Npanic(char *);
