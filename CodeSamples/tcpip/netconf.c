
/* +++=>>> * %n  Edition: %v  Last changed: %f  By: %w */
/* NETCONF.C  Edition: 6  Last changed: 8-Mar-94,13:34:54  By: HARRY */
/* +++=>>> '%l' */
/* Currently extracted for edit by: '***_NOBODY_***' */

#include "net.h"
#include "drvconf.h"

#ifndef Ethernet
#define Ethernet 0
#endif
#ifndef SLIP
#define SLIP 0
#endif
#ifndef PPP
#define PPP 0
#endif

#define A {0xff,0x00,0x00,0x00}		/* standard network masks */
#define B {0xff,0xff,0x00,0x00}
#define C {0xff,0xff,0xff,0x00}
#define EA0 {0,0,0,0,0,0}		/* zero external (Ethernet) address */

/* Leave in only valid entries.  Trying to initialize non-existant hardware
   usually causes a crash.  Fields:
      - host name
      - port or network name
      - network class
      - Internet address
      - Ethernet address, only needed in RARP servers, and when Ethernet board
	has no address ROM
      - flags: 0 or NOTUSED
      - link layer: Ethernet, ARCNET, SLIP, PPP
      - driver, see README.TXT for selection
      - adapter, such us PCMCIA, 0 if none
      - driver initialization data, use data below as model

For external hosts, like a UNIX workstation, the last 3 fields are unused and
can be given as 0.
*/

const struct NETDATA netdata[]={
"none", "nnet", C, {192,9,201,1}, EA0, 0, Ethernet, WD8003, 0, "IRNO=5 PORT=0x280 BUFFER=0xd0000",
"none", "com2", C, {192,9,202,1}, EA0, 0, SLIP, I8250, 0, "IRNO=3 PORT=0x2f8 CLOCK=115200 BAUD=38400",
"none", "tnet", C, {192,9,200,12}, EA0, 0, Ethernet, NE2100, 0, "IRNO=4 PORT=0x340, DMA=5",
"test", "nnet", C, {192,9,201,2}, EA0, 0, Ethernet, NE2000, 0, "IRNO=5 PORT=0x300",
"test", "com2", C, {192,9,202,2}, EA0, 0, SLIP, I8250, 0, "IRNO=3 PORT=0x2f8 CLOCK=115200 BAUD=38400",
"test", "tnet", C, {192,9,200,2}, EA0, 0, Ethernet, EXP16, 0, "IRNO=4 PORT=0x340",
"test2", "nnet", C, {192,9,201,3}, EA0, 0, Ethernet, WD8003, 0, "IRNO=5 PORT=0x300 BUFFER=0xca000",
"test2", "com4", C, {192,9,202,3}, EA0, NOTUSED, SLIP, I8250, 0, "IRNO=3 PORT=0x2e8 CLOCK=115200 BAUD=38400",
"test2", "tnet", C, {192,9,200,3}, EA0, 0, Ethernet, NE2000, 0, "IRNO=10 PORT=0x320",
"z180", "z180", C, {192,9,202,4}, EA0, NOTUSED, SLIP, H64180, 0, "PORT=0 IRNO=7 BAUD=9600",
"hc16", "hc16", C, {192,9,202,5}, EA0, NOTUSED, SLIP, HC16SCI, 0, "IRNO=64 BAUD=9600",
"hc11", "hc11", C, {192,9,202,6}, EA0, NOTUSED, SLIP, HC11SCI, 0, "BASE=0x1000 IRNO=0xc4 BAUD=9600",
"m68k", "2681", C, {192,9,202,7}, EA0, NOTUSED, SLIP, D2681, 0, "IRNO=70 BASE=0xb00000 BAUD=9600 PORT=B H230=3 BASE230=0xc01000",
"m68k", "tnet", C, {192,9,200,8}, {0,0,0,69,103,137}, 0, Ethernet, EN360, 0, "BASE=0x22000 IRNO=0x60",
"mips", "2681", C, {192,9,202,9}, EA0, NOTUSED, SLIP, D2681, 0, "IRNO=5 BASE=0xbfe00000 BAUD=9600 PORT=B",
"sparc", "tnet", C, {192,9,200,10}, {1,2,3,4,5,6}, 0, Ethernet, MB86960, 0, "BASE=0x20000000 IRNO=14",
"sun", "tnet", C, {192,9,200,1}, EA0, 0, 0, 0, 0, 0,
};

#define NN sizeof(netdata)/sizeof(struct NETDATA)
const int confsiz=NN;
struct NETCONF netconf[NN];
