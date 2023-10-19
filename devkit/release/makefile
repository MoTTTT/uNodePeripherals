all :
	make testser
	make testadc
	make testrtc
	make testkl

clear :
	del *.obj
	del *.abs
	del *.hex
	del *.lst

clean :
	del *.obj
	del *.abs
	del *.hex
	del *.bin
	del *.lst

testser.bin : testser.hex

testser.hex : testser.abs

testser.abs : testser.obj
	bl51 testser.obj,nodedev.lib to testser.abs ${LFLAGS} XDATA(4200H)

testser.obj : testser.c;

testser :
	make clear
	del testser.bin
	make testser.obj
	make testser.abs
	make testser.hex
	make testser.bin
	make clear

testadc.bin : testadc.hex

testadc.hex : testadc.abs

testadc.abs : testadc.obj
	bl51 testadc.obj,nodedev.lib to testadc.abs ${LFLAGS} XDATA(4200H)

testadc.obj : testadc.c;

testadc :
	make clear
	del testadc.bin
	make testadc.obj
	make testadc.abs
	make testadc.hex
	make testadc.bin
	make clear

testrtc.bin : testrtc.hex

testrtc.hex : testrtc.abs

testrtc.abs : testrtc.obj
	bl51 testrtc.obj,nodedev.lib to testrtc.abs ${LFLAGS} XDATA(4200H)

testrtc.obj : testrtc.c;

testrtc :
	make clear
	del testrtc.bin
	make testrtc.obj
	make testrtc.abs
	make testrtc.hex
	make testrtc.bin
	make clear

testkl.bin : testkl.hex

testkl.hex : testkl.abs

testkl.abs : testkl.obj
	bl51 testkl.obj,nodedev.lib to testkl.abs ${LFLAGS} XDATA(4200H)

testkl.obj : testkl.c;

testkl :
	make clear
	del testkl.bin
	make testkl.obj
	make testkl.abs
	make testkl.hex
	make testkl.bin
	make clear

