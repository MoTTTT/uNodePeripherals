
/* +++=>>> * %n  Edition: %v  Last changed: %f  By: %w */
/* DRIVER.H  Edition: 3  Last changed: 29-Oct-93,14:18:46  By: HARRY */
/* +++=>>> '%l' */
/* Currently extracted for edit by: '***_NOBODY_***' */
/*
    DRIVER.H -- Driver Level Definitions for USNET

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
   Driver and interrupt related support. */

void IRinstall(int irno, int netno, void (*irhan)(int netn));
void IRrestore(int irno);
char FAR *mapioadd(unsigned long flat);
unsigned long map24bit(char *addr);
void enableDMA(unsigned int chan);
void disableDMA(unsigned int chan);

/* clear interrupt controller */
#define CLEARIR(irno) _outb(0x20, 0x60+irno)
#define CLEARIR2(irno) _outb(0xa0, 0x58+irno), _outb(0x20, 0x62)

/* external output byte and word, input byte */
#define _outb(p,v) outp(p,v)
#define _outw(p,v) outpw(p,v)
#define _inb(p)	inp(p)
#define _inw(p)	inpw(p)

#define BLOCKINb(ptr, port, len)  Ninbrep(ptr, port, len); ptr += (len + 1)/2
void Ninbrep(short *ptr, int port, int len);
#define BLOCKOUTb(ptr, port, len)  Noutbrep(ptr, port, len)
void Noutbrep(short *ptr, int port, int len);
#define BLOCKINw(ptr, port, len)  Ninwrep(ptr, port, len)
#define BLOCKIN(ptr, port, len)  Ninwrep(ptr, port, len); ptr += (len + 1)/2
void Ninwrep(short *ptr, int port, int len);
#define BLOCKOUTw BLOCKOUT
#define BLOCKOUT(ptr, port, len)  Noutwrep(ptr, port, len)
void Noutwrep(short *ptr, int port, int len);

/* disable and enable interrupts */
#include <dos.h>
#define DISABLE() _disable()
#define ENABLE() _enable()
