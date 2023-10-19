/*			Copyright Q Solutions				*/
/*	File:		adc.h						*/
/*	Programmer:	MoT						*/
/*	Module:		Analog to digital converter header file		*/
/*									*/

extern	byte	adc[];			/* ADC results			*/
extern	bit	adc_read;		/* ADC busy flag		*/

void	init_adc	( void );	/* Init Analog->Digital Convert	*/
void	adc_start	( void );	/* Start Reading ADC channels	*/
