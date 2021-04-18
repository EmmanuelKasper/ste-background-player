**
** gemdos.i - GEMDOS magic numbers
**
** Copyright (c) 1989,90 HiSoft
**
* 13.12.90	 Updated for TT TOS

p_term0		equ	$00
c_conin		equ	$01
c_conout	equ	$02
c_auxin		equ	$03
c_auxout	equ	$04
c_prnout	equ	$05
c_rawio		equ	$06
c_rawcin	equ	$07
c_necin		equ	$08
c_conws		equ	$09
c_conrs		equ	$0a
c_conis		equ	$0b
d_setdrv	equ	$0e
c_conos		equ	$10
c_prnos		equ	$11
c_auxis		equ	$12
c_auxos		equ	$13
m_addalt	equ	$14
d_getdrv	equ	$19
f_setdta	equ	$1a
super		equ	$20
t_getdate	equ	$2a
t_setdate	equ	$2b
t_gettime	equ	$2c
t_settime	equ	$2d
f_getdta	equ	$2f
s_version	equ	$30
p_termres	equ	$31
d_free		equ	$36
d_create	equ	$39
d_delete	equ	$3a
d_setpath	equ	$3b
f_create	equ	$3c
f_open		equ	$3d
f_close		equ	$3e
f_read		equ	$3f
f_write		equ	$40
f_delete	equ	$41
f_seek		equ	$42
f_attrib	equ	$43
m_xalloc	equ	$44
f_dup		equ	$45
f_force		equ	$46
d_getpath	equ	$47
m_alloc		equ	$48
m_free		equ	$49
m_shrink	equ	$4a
p_exec		equ	$4b
p_term		equ	$4c
f_sfirst	equ	$4e
f_snext		equ	$4f
f_rename	equ	$56
f_datime	equ	$57

EINVFN		equ	-32
EFILNF		equ	-33
EPTHNF		equ	-34
ENHNDL		equ	-35
EACCDN		equ	-36
EIHNDL		equ	-37
ENSMEM		equ	-39
EIMBA		equ	-40
EDRIVE		equ	-46
ENSNAME		equ	-48
ENMFIL		equ	-49
ERANGE		equ	-64
EINTRN		equ	-65
EPLFMT		equ	-66
EGSBF		equ	-67

