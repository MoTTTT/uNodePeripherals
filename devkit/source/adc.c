/*			Copyright Q Solutions				*/
/*	File:		adc.c						*/
/*	Programmer:	MoT						*/
/*	Module:		Analog to digital converter routines		*/
/*									*/
/*			History						*/
/* 17:16 27/04/1997   	Written from scratch				*/
/*									*/

/*			Standard Library Header Files			*/
#include	<reg552.h>
/*			ADC Parameters					*/
#define	ADC_INI		0x00		/* ADC Init Control Byte	*/
#define	ADC_INT		0xEF		/* ADC Interrupt Mask		*/
#define	ADC_STA		0x08		/* ADC Start Mask		*/
#define	ADC_CHAN	8		/* Number of channels to read	*/
/*			ADC Variables					*/
typedef	unsigned int uint;		/* Optimise for size & speed:	*/
typedef	unsigned char byte;		/* Use unsigned char and int	*/
byte	adc_chan;			/* Current ADC channel		*/
byte	adc[ADC_CHAN];			/* ADC results			*/
bit	adc_read=	0;		/* ADC busy flag		*/

void	init_adc	( )		/* Init Analog->Digital Convert	*/
{
	ADCON=	ADC_INI;		/* Set up ADC Control Register	*/
	EAD=	1;			/* Enable ADC Interrupt		*/
}

void	adc_start	( )		/* Start Reading ADC channels	*/
{
	adc_read=	1;		/* Set "Reading" Flag		*/
	adc_chan=	0;		/* Start with channel 1		*/
	ADCON=	ADC_STA;		/* Start first channel read	*/
}

void	adc_int	( void ) interrupt 10	/* Analog to Digital interrupt	*/
{
	adc[adc_chan]=ADCH;		/* Copy result to adc buffer	*/
	ADCON&=	ADC_INT;		/* Reset interrupt 		*/
	if	(++adc_chan== ADC_CHAN )/* Read next channel, Done? 	*/
		adc_read=	0;	/* Reset "Reading" flag		*/
	else	ADCON=ADC_STA+ adc_chan;/* Start next channel read	*/
}