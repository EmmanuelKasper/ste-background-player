* Equates for accessing the Atari XBIOS
* (c) HiSoft 1990 

initmous	equ	0
ssbrk		equ	1
physbase	equ	2
logbase		equ	3
getrez		equ	4
setscreen	equ	5
setpallete	equ	6
setpalette	equ	6
setcolor	equ	7
floprd		equ	8
flopwr		equ	9
flopfmt		equ	10
midiws		equ	12
mfpint		equ	13
iorec		equ	14
rsconf		equ	15
keytbl		equ	16
random		equ	17
protobt		equ	18
flopver		equ	19
scrdmp		equ	20
cursconf	equ	21
settime		equ	22
gettime		equ	23
bioskeys	equ	24
ikbdws		equ	25
jdisint		equ	26
jenabint	equ	27
giaccess	equ	28
offgibit	equ	29
ongibit		equ	30
xbtimer		equ	31
dosound		equ	32
setprt		equ	33
kbdvbase	equ	34
kbrate		equ	35
prtblk		equ	36
vsync		equ	37
supexec		equ	38
puntaes		equ	39
floprate	equ	41
dmaread		equ	42
dmawrite	equ	43
bconmap		equ	44
nvmaccess	equ	46
blitmode	equ	64
esetshift	equ	80
egetshift	equ	81
esetbank	equ	82
esetcolor	equ	83
esetpalette	equ	84
egetpalette	equ	85
esetgray	equ	86
esetsmear	equ	87
