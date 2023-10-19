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


dlkl :
	c:\dosemu\unix dd if=~/nodelib/devkit/test/testkl.bin of=/dev/cua1

dlus :
	-i dd if=~/nodelib/devkit/test/testser.bin of=/dev/cua1

dls :
	c:\dosemu\unix dd if=~/nodelib/devkit/test/testser.bin of=/dev/cua1

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

testmag1.bin : testmag1.hex

testmag1.hex : testmag1.abs

testmag1.abs : testmag1.obj
	bl51 testmag1.obj,nodedev.lib to testmag1.abs ${LFLAGS} XDATA(4200H)

testmag1.obj : testmag1.c;

testmag1 :
	make clear
	del testmag1.bin
	make testmag1.obj
	make testmag1.abs
	make testmag1.hex
	make testmag1.bin
	make clear

testmag2.bin : testmag2.hex

testmag2.hex : testmag2.abs

testmag2.abs : testmag2.obj
	bl51 testmag2.obj,nodedev.lib to testmag2.abs ${LFLAGS} XDATA(4200H)

testmag2.obj : testmag2.c;

testmag2 :
	make clear
	del testmag2.bin
	make testmag2.obj
	make testmag2.abs
	make testmag2.hex
	make testmag2.bin
	make clear
