del node.lib
lib51 create node.lib
lib51 add cbkey.obj, iic.obj, iicdriv.obj, nkey.obj to node.lib
lib51 add nodelcd.obj, portlcd.obj, rtc.obj, wdog.obj to node.lib
lib51 add rlcdpad.obj, adc.obj to node.lib
copy node.lib .\lib\node.lib
del *.lst
