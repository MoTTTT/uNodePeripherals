/*
    LOCAL.H -- Local Configuration for USNET
    Copyright (C) 1993 United States Software Corporation

    This is the Intel x86 16-bit version.
*/

#define MAXBUF 1532		/* message buffer size */
#define NNETS 4			/* maximum number of networks */
#define NCONNS 5		/* maximum number of connections */
#define NBUFFS 15		/* number of message buffers */

#define MT 0			/* multitasking: 0 = none */
				/*       	 1 = US Software MultiTask! */

#define chksum_INASM		/* for speed we do checksum in assembler */

#define FRAGMENTATION		/* accept and do message fragmentation */

/* local host name and login password */

#define HOSTNAME(val) \
    if (getenv("HOST")) strcpy(val,getenv("HOST")); \
    else strcpy(val, "none")
#define USERID "test"		/* userid for login to FTP etc. */
#define PASSWD "hmo"

/* local initialization and termination code for Ninit() and Nterm() */

extern unsigned int clocks_per_sec;
#define LOCALSETUP() 0, clocks_per_sec = 18
#define LOCALSHUTOFF() 
unsigned long clock(void);
