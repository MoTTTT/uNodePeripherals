tall:
	make clean
	make lobj
	make llib
	make tinstall
	make clean

all:
	make clean
	make lobj
	make llib
	make install
	make clean

lobj:
	c51 adc.c LA
	a51 iicdriv.a51
	c51 iic.c LA
	c51 rtc.c LA
	c51 nodelcd.c LA
	c51 nkey.c LA
	c51 serial.c LA
	c51 wdog.c LA
	c51 time.c LA

llib:
	del nodedev.lib
	lib51 create nodedev.lib
	lib51 add iic.obj, iicdriv.obj, nkey.obj to nodedev.lib
	lib51 add nodelcd.obj, rtc.obj, wdog.obj to nodedev.lib
	lib51 add adc.obj, serial.obj, time.obj to nodedev.lib

clean:
	del *.obj
	del *.lst
	del nodedev.lib

tinstall:
	copy nodedev.lib ..\test\nodedev.lib

install:
	copy nodedev.lib ..\..\lib\nodedev.lib
	copy nodedev.lib ..\lib\nodedev.lib
	copy nodedev.lib ..\test\nodedev.lib
