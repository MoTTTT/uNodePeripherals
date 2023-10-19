
/* +++=>>> * %n  Edition: %v  Last changed: %f  By: %w */
/* NET.H  Edition: 11  Last changed: 10-Aug-94,11:32:46  By: HARRY */
/* +++=>>> '%l' */
/* Currently extracted for edit by: '***_NOBODY_***' */
/*
    NET.H -- General Definitions for USNET

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
   Internal numbers assigned to different protocols.  To leave out a protocol,
   undefine the name.  To add a protocol, choose a name, assign it the next
   free number, write a protocol module (use the existing same level for
   model), and add to Ptable at start of module NET.C. */

#define IP 1		/* Internet Protocol: connectionless */
#define ICMP 2		/* Internet Control Message Protocol */
#define ARP 3		/* Address Resolution Protocol */
#define RARP 4		/* Reverse Address Resolution Protocol */
#define UDP 5		/* User Datagram Protocol: simple connections */
#define TCP 6		/* Transport Control Protocol: full connections */
#define Ethernet 7	/* link control for Ethernet */
#define ARCNET 8	/* link control for ARCNET */
#define SLIP 9		/* Serial Line Internet Protocol: simple async */ 
#define PPP 10		/* Point to Point Protocol: full async */ 
         

/* =========================================================================
   Configuration definitions. */  

#define LHDRSZ 14			/* size of link level header */
#define TOUT_PASSIVE 10000000		/* timeout ms for passive open */
					/* beware of overflows if > 10^7 */
#define MAXTXTOUT 32000			/* maximum timeout ms for transmit */


/* =========================================================================
   Macros and definitions to simplify coding. */

#define Iid_SZ 4
#if Iid_SZ == 4
#define EQIID(id1, id2) (*(long *)&id1 == *(long *)&id2)
#else
#define EQIID(id1, id2) (memcmp(&id1, &id2, Iid_SZ) == 0)
#endif

#define ASCII 0			/* file mode: text */
#define IMAGE 1			/*	      binary */

#define QUEUE_EMPTY(ptr, qname) (ptr->qname.mhead == ptr->qname.mtail)
#define QUEUE_FULL(ptr, qname) \
        (ptr->qname.mhead == (ptr->qname.mtail + 1) & \
	    ((sizeof(ptr->qname.mp)/sizeof(ptr->qname.mp[0]))-1))
#define QUEUE_IN(ptr, qname, mess) \
        ptr->qname.mp[ptr->qname.mtail] = mess; \
        ptr->qname.mtail = (ptr->qname.mtail + 1) & \
	    ((sizeof(ptr->qname.mp)/sizeof(ptr->qname.mp[0]))-1);
#define QUEUE_OUT(ptr, qname, mess) \
        mess = ptr->qname.mp[ptr->qname.mhead]; \
	ptr->qname.mhead = (ptr->qname.mhead + 1) & \
	    ((sizeof(ptr->qname.mp)/sizeof(ptr->qname.mp[0]))-1);
#define MESS_OUT(ptr, mess) \
    	mess = ptr->first; \
    	if ((ptr->first = mess->next) == 0) \
	    ptr->last = (MESS *)&ptr->first; \
	ptr->ninque--; \

#ifndef FARDEF
#define FAR
#define Nfarcpy memcpy
#else
#define FAR FARDEF
void Nfarcpy(char FAR *, char FAR *, int);
#endif

/* =========================================================================
   Structures. */

#define Eid_SZ 6
struct Eid {unsigned char c[Eid_SZ];};	/* external address format */
struct Iid {unsigned char c[Iid_SZ];};	/* internal address format */

struct MESSH {			/* internal message header */
    struct MESSH *next;		/* chain pointer */
    unsigned long timems;	/* time stamp */
    unsigned short mlen;	/* message length */
    unsigned char netno;	/* network number */
    char offset;		/* offset to current level */
    unsigned char confix;	/* network configuration index */
    char conno;			/* connection number */
    short id;			/* message identification */
};
typedef struct MESSH MESS;
#define MESSH_SZ (sizeof(MESS) | 2)
#define bFUTURE 0x7777		/* buffer in future queue */
#define bFREE 0x7676		/* buffer free */
#define bALLOC 0x7575		/* buffer allocated */
#define bWACK 0x7474		/* buffer in wait-for-ack queue */
#define bRELEASE 0x7373		/* buffer to be released */

#define PTABLE const struct Ptable	/* typedef caused trouble */
struct Ptable {			/* protocol table, at end of each module */
    char name[10];			/* name of protocol */
    int (*init)(int, PTABLE **, char *);	/* initialize */
    void (*shut)(int, PTABLE **);		/* shut */
    int (*screen)(MESS *);			/* screen */
    int (*opeN)(int, PTABLE **, int);		/* open */
    void (*closE)(int, PTABLE **);		/* close */
    MESS *(*reaD)(int, PTABLE **);		/* receive */
    int (*writE)(int, PTABLE **, MESS *);	/* send */
    int Eprotoc;			/* external protocol number */
    unsigned char hdrsiz;		/* header size */
};

struct FIFOQ8 {MESS *mp[8]; int mhead, mtail;};
struct FIFOQ16 {MESS *mp[16]; int mhead, mtail;};
struct NET {			/* structure defining a network */
    int stat;				/* status bits */
    PTABLE *protoc[3];			/* link, driver, adapter protocol */
    unsigned char confix;		/* number in configuration table */
    char sndoff;			/* offset to sender's address */
    unsigned long tout;			/* basic timeout in milliseconds */
    int maxblo;				/* maximum block size for link */
    char cflags;			/* configuration flags */
    char worktodo;			/* flag for network task */
    char null1;				/* alignment */
    unsigned char state;		/* state */
    struct FIFOQ16 arrive;		/* circular list of arrivals */
    MESS *fragmq;			/* linked sorted list of fragments */
    MESS *fragmh;               	/* reassembled message */
    int irno[4];			/* interrupt numbers */
    int port;				/* I/O port */
    char FAR *base[2];			/* for memory-mapped I/O */ 
    struct Eid id;			/* board id */
    unsigned char netno;		/* network number */
    char hwflags;			/* hardware level flags */
    MESS *bufbas;			/* input buffer base */
    MESS *bufbaso;			/* output buffer base */
    struct FIFOQ16 depart;		/* circular list of departures */
    long bps;				/* bits per second */
    unsigned int err[12];		/* error counters */
/* all hardware net structures must fit in SERIAL, use filler if necessary */
    struct SERIAL {			/* hardware net data for serial lines */
    unsigned long ul1;			/* miscellaneous */
    void (*comec)(int, struct NET *);	/* character from driver */    
    int (*goingc)(struct NET *);	/* character to driver */    
    char *bufin;			/* input buffer pointer */
    char *buflim;			/* input buffer upper limit */
    char *bufout;			/* output buffer pointer */
    char baudctl[2];			/* baud rate controls */
    int chsout;				/* output buffer counter */
    unsigned char lastin;		/* last arrived character */
    unsigned char nxtout;		/* next character out */
    MESS *fragmq;			/* linked sorted list of fragments */
    MESS *fragmh;               	/* reassembled message */
    char null1[4]; } hw;
};
    
struct NETDATA {	 	/* network configuration table - ROM */
    char *name;			/* host name */
    char *pname;		/* port name */
    struct Iid Imask;		/* address mask, 0 = host part */
    struct Iid Iaddr;		/* internal (Internet) address */
    struct Eid Eaddr;		/* external (Ethernet) address */
    char flags;			/* configuration flags */
    char lprotoc;		/* link level protocol */
    PTABLE *dprotoc;		/* driver */
    PTABLE *adapter;		/* adapter */
    char *params;		/* pointer to setup parameters */
};
struct NETCONF {	 	/* network configuration table - RAM */
    char *name;			/* host name */
    char *pname;		/* port name */
    struct Iid Inet;		/* network address, host part = 0 */
    struct Iid Iaddr;		/* internal (Internet) address */
    struct Eid Eaddr;		/* external (Ethernet) address */
    char flags;			/* configuration flags */
    unsigned char netno;	/* network number */
    unsigned char hops;		/* number of needed hops */
    unsigned char nexthix;	/* next host index */
};
/* configuration flag bits */
#define NOTUSED 1		/* configured out */
#define BOOTSERVER 2
#define TIMESERVER 4		/* will respond to ICMP time requests */
#define INITDONE 8		/* initialization done */
#define LOCALHOST 0x10		/* this is me */
#define NODE 0x20		/* host has at least 2 networks */
#define DIAL 0x40		/* dial-up line */

struct CONNECT {		/* logical connection structure */
    char txstat;		/* status */
    char rxstat;
    char state;			/* state machine state */
    char sendack;		/* flag to send ACK */
    unsigned char netno;	/* net number */
    unsigned char confix;	/* target configuration index */
    char ninque;		/* number of messages in input queue */
    char null1;
    unsigned long rxtout;	/* timeout value for receive */
    unsigned long txtout;	/* transmission timeout */
    long txvar, txave;		/* values needed to calculate txtout */
    unsigned long txseq;	/* my sequence number */
    unsigned long rxseq;	/* the other sequence number */
    unsigned long ackno;	/* acknowledged up to this */
    unsigned long seqtoack;	/* next we'll ACK this number */
    unsigned long ackdseq;	/* last ACK'd number */
    MESS *first;		/* linked list of arrived messages */
    MESS *last;
    MESS *wackf, *wackl;	/* linked list of messages waiting for ACK */
    int nwacks;			/* number of entries in the WACK queue */
    MESS *future;		/* linked sorted list of future messages */
    PTABLE *protoc[8]; 		/* protocol path */
    int myport;			/* my port number */
    int herport;		/* the other port number */
    struct Iid heriid;		/* the other Internet address */
    struct Eid hereid;		/* the other external (Ethernet) address */
    unsigned int window;	/* how much we can send */
    unsigned int mywindow;	/* size of our window */
    unsigned int maxdat;	/* maximum data size for application */
    unsigned int doffset;	/* user data offset in buffer */
    MESS *istreamb;		/* input stream I/O buffer base */
    int istreamc;		/*              I/O character counter */
    char *istreamp;		/*              I/O character pointer */
    MESS *ostreamb;		/* output stream I/O buffer base */
    int ostreamc;		/*               I/O character counter */
    char *ostreamp;		/*               I/O character pointer */
};
#define S_OPEN  0x01		/* main level stat: connection open */
#define S_MON   0x02		/*   monitor mode */
#define S_FIN   0x04		/*   write end of file */
#define S_PSH   0x08		/*   push */
#define S_CHP   0x10		/*   change port number, done in UDP */
#define S_NOWA  0x20		/*   non-blocking */
#define S_STRM  0x40		/*   stream */
#define PORT    0x80		/*   open different port same host */
#define S_EOF   0x01		/* rx level stat: nothing more to read */
#define S_NOACK 0x02		/*   we failed to get an ack */


/* =========================================================================
   Error codes.  Use values -100, -101 etc. for private codes. */

#define NE_PARAM	-10	/* user parameter error */
#define NE_NOTCONF	-11	/* host or protocol not configured */
#define NE_TIMEOUT	-12	/* timeout */
#define NE_HWERR	-13	/* hardware error */
#define NE_PROTO	-14	/* protocol error */
#define NE_NOBUFS	-15	/* no buffer space */


/* =========================================================================
   Function prototypes. */

void Ninitbuf(int size, int count);
MESS *Ngetbuf(void);
MESS *NgetbufIR(void);
void Nrelbuf(MESS *bufptr);
void NrelbufIR(MESS *bufptr);
void Ncntbuf(void);
void Nroute(void);
int Ninit(void);
int Nterm(void);
int Portinit(char *port);
int Portterm(char *port);
int Nopen(char *to, char *protoc, int myport, int herport, int flags);
int Nclose(int conno);
int Nwrite(int conno, char *mess, int len);
int Nread(int conno, char *mess, int len);
int BOOTPnames(char *host, char *file);
void FAR *BOOTP(char FAR *base, char *host, char *file);
void BOOTPserv(void);
int TFTPserv(void);
int TFTPput(char *host, char *file, int mode);
int TFTPget(char *host, char *file, int mode);
int FTPserv(void);
int FTPgetput(char *host, char *file, int mode);
#define FTPget(host, file, mode) FTPgetput(host, file, mode)
#define FTPput(host, file, mode) FTPgetput(host, file, mode+2)

!Ã!Ä!Å!Æ!Ç!È!É!Ê!Ë!Ì!Í!Î!Ï!Ğ!Ñ!Ò!Ó!Ô!Õ!Ö!×!Ø!Ù!Ú!Û!Ü!İ!Ş!ß!à!á!â!ã!ä!å!æ!ç!è!é!ê!ë!ì!í!î!ï!ğ!ÿÿ  ó!ô!õ!ö!÷!ø!ù!ú!û!ü!ÿÿş!ÿ! " nŒ F_LXMUL@ êˆ  à% nŒ F_LXLSH@ ñˆ  à% nŒ _nets Nˆ  ã'NET3ˆ  ã*Ptable) .‰ˆ	  ã+ 
 ;ˆ  ã-   # 2ˆ
  ã,  - ˆ  ã/   # 3ˆ
  ã.  / ˆ  ã1   # .ˆ
  ã0  1 ˆ  ã3   # ,ˆ
  ã2  3 ˆ  ã5   # -ˆ
  ã4  5 ˆ  ã7   # ˆ
  ã6  7 ˆ  ã9   # &ˆ
  ã8  9  ˆ
  ã)  * ˆ	  ã(  )ˆ  ã:FIFOQ16D 9Íˆ	  ã; @ ßˆ	  ã<  *ˆ	  ã=  ˆ  ã>Eid =Õˆ	  ã?  %ˆ	  ã@  
ˆ  ãASERIAL* ?øˆ  ãC   # ˆ
  ãB  C ìˆ  ãE   # ˆ
  ãD  E èˆ	  ãF  (ˆ	  ãG  %ˆ	  ã&   '%ˆ  à& mŒ _connblo ˆ  ãICONNECTŒ M4ˆ	  ãJ   )ßˆ  ãKIid tˆ	  ãL  ˆ	  ãH   Iáˆ  àH KŒ _Nsscanf 6ˆ  ãM   #ˆ  àM FŒ _Nprintf !ˆ  ãN   #ˆ  àN EŒ 	_Nsprintf ¬ˆ  ãO   #ˆ  àO DŒ
 _TimeMS Õˆ  ãP   # ˆ  àP CŒ _Nportno ˆ  ãQ   #
 ˆ  àQ BŒ _NetTask Hˆ  ãR   # ˆ  àR AŒ	 _Nread ˆ  ãS   # ˆ  àS @Œ
 _Nwrite ‹ˆ  ãT   # ˆ  àT ?Œ
 _Nclose  ˆ  ãU   # 
ˆ  àU >Œ	 _Nopen ˆ  ãV   # 	ˆ  àV =Œ _Nrelbuf 4ˆ  ãW   # ˆ  àW <Œ _Ngetbuf 7ˆ  ãX   # óˆ  àX ;Œ
 _fwrite sˆ  ãY   #
  ˆ  àY :Œ	 _fread ˆ  ãZ   #
 ÿˆ  àZ 9Œ	 _fopen îˆ  ã[   # îˆ  à[ 8Œ
 _fclose ˆˆ  ã\   # ˆ  à\ 7  _TFTPgetŠ	 èˆ  ã]   # ˆ  á]   _TFTPput' 5ˆ  ã^   # ˆ  á^   	_TFTPserv$ Ğˆ  ã_   #  ˆ  á_ ˆ  ã`   # ˆ  ãa   # ˆ‹  æTFTPrx` z TFTPtxa    MESS FILE fpos_t size_t
 CONNECTI SERIALA NET' FIFOQ16: Ptable* MESSH IidK Eid> µˆF  â next timems mlen
 netno offset confix conno idÀ   şˆM  â level flags
 fd hold bsize buffer curp istemp
 tokenÀ   OˆÒ  â stat protoc( confix sndoff tout maxblo cflags worktodo null1 state arrive: fragmq fragmh irno< port base= id> netno hwflags bufbas bufbaso depart: bps err@ hwAÀ  ¬ˆW  â name+ init, shut. screen0 opeN2 closE4 reaD6 writE8 Eprotoc hdrsizÀ)   xˆ  â mp; mhead mtailÀD   3ˆ  â c?À   !ˆx  â ul1 comecB goingcD bufin buflim bufout baudctlF chsout lastin nxtout fragmq fragmh null1GÀ*   âˆe â txstat rxstat state sendack netno confix ninque null1 rxtout txtout txvar txave txseq rxseq ackno seqtoack ackdseq first last wackf wackl nwacks future protocJ myport herport heriidK hereid> window
 mywindow
 maxdat
 doffset
 istreamb istreamc istreamp ostreamb ostreamc ostreampÀŒ   ¡ˆ  â cLÀ      U‹ìƒìlVWÇFğ  ÇFî  ¿ Ä^&ŠG˜‹ğš    P‹ÆºŒ ÷ê‹ØX‰‡b ¸ PÄ^&ŠG˜‹VĞƒÂÿvRš    ƒÄ‰Vì‰Fê‹FêFìuéû‹ÆºŒ ÷ê‹ØŠ‡ ´ º÷ê‹Ø‹‡ ‹— P‹Æ»Œ R÷ë‹ØXZ‰—
 ‰‡ ‹F‹VƒÂ‰Fø‰VöÄ^ö&Ç š    ‰Vô‰Fòÿvìÿvê¸ P¸ P‹Fö ÿvøPš    ƒÄ‰Fúƒ~ú }é± ‹Ç%ÿ ±Óà‹×±ÓêÂÄ^ö&‰G‹Fú™FîVğÇFü  ër‹Fú PÿvøÿvöVš    ƒÄ¸P PF”PVš    ƒÄ‰Fşƒ~ş ~>~” u‹F–%ÿ ±Óà‹V–±ÓêÂ;Çuë*ƒÿu~” u¸ P¸  PVš    ƒÄÿFüƒ~ü|ˆéÉ G~ú }ëé#ÿÇFş  š    P‹Æ»Œ R÷ë‹Ø‹—
 ‹‡ ±š    [YÈÚ‰^è‰Næš    ;Vèru;FærÇFş ëÇFä  ëÿväš    YÿFäƒ~ä|îëÍš    +FòVô‰Vô‰Fò‹FòFôt@‹FîFğt8ÿvôÿvò‹Nğ‹^î3Ò¸èš    RPš    RPÿvôÿvòÿvğÿvî¸ Pš    ƒÄÿvìÿvêš    YYVš    Yÿvÿvš    YY_^‹å]ËU‹ìƒìVWÇFğ 3À‰Fò™‰Vê‰FèÄ^&ŠG˜‹ğš    P‹ÆºŒ ÷ê‹ØX‰‡b ¸/ PÄ^&ŠG˜‹VĞƒÂÿvRš    ƒÄ‰Væ‰Fäÿvÿvš    YY‹FäFæué'š    ‰Vî‰Fì‹ÆºŒ ÷ê‹ØŠ‡ ´ º÷ê‹Ø‹— ‹‡ ±š    P‹Æ»Œ R÷ë‹ØX‰‡
 X‰‡ ¸ PFğPVš    ƒÄ‰Fşƒ~ş é·ÇFú ÇFø  ‹ÆºŒ ÷êB PV‹ÆºŒ ÷ê‹ØÄŸB &ÿ_ƒÄ‰V‰F‹FFuƒ~ø téérÄ^&ŠG˜‹V‹^Ø‰Vö‰^ôÄ^ô&? tÿvÿvš    YYƒ~ø téã é9Ä^ô&‹G%ÿ ±ÓàÄ^ô&‹W±ÓêÂ‰FüÄ^ô&‹G‰Fò‹Fü;Fút)œÉ Ï¿VÇuÇeÏ@VÇ3Ç.ÏVÇÇÇÎñV	ÎßVÎËVÆ³Æ¯ÎV
