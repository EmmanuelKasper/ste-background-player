* GUI Atari ST program STEBPL
* STE background audio player

* Version 0.9


* By P. Putnik ,  March 2011
* PD, open source program
* Feel free to use, spread - 
* until notice origin .  


* File format : WAV based, but ...

* Converted format :

* Header is 32 KB long - to maintain cluster align (on Falcon is biggest)
* Audio data is signed mono or stereo, 25033 or 50066 Hz samplerated

* Need first convert to new format if not in ....

* Extension WAE - WAV for STE


* Playback control via Timer-C rutine
* With help of flags/signals - a lot .

* Main flags:  playOn,  listOn
* stopPl

* Flags by Dialog buttons:  repeat on


* Timer-C code flags:
*  tcFlag - prevents reenter Timer-C disk access if already active
* BiosF - BIOS trap active
* XbiosF - XBios active
* GemDF - GEMDOS active
* above 4 flag in 1 long. If any set, Timer-C will skip to TOS org. code

* phase - for buffer load control











; resource set indices for STEBPL
;
MAINDI   equ 0 ; form/dialog
MAINBOX  equ 0 ; BOX in MAINDI
TITLETXT equ 1 ; BOXTEXT in MAINDI
PLAYFBU  equ 2 ; BUTTON in MAINDI
STOPPLBU equ 3 ; BUTTON in MAINDI
PLAYLIBU equ 4 ; BUTTON in MAINDI
REPBU    equ 5 ; BUTTON in MAINDI
PROGBOX  equ 6 ; BOX in MAINDI
PROGBAR  equ 7 ; BOX in MAINDI
FILEINFT equ 8 ; TEXT in MAINDI
FINAMINF equ 9 ; TEXT in MAINDI
FILEINFC equ 10 ; TEXT in MAINDI
CONVWAVB equ 11 ; BUTTON in MAINDI
COMPPLBU equ 12 ; BUTTON in MAINDI
DELWAVBU equ 13 ; BOXTEXT in MAINDI
VOLTIT   equ 14 ; TEXT in MAINDI
EXITBU   equ 15 ; BUTTON in MAINDI
VOLDBU   equ 16 ; BUTTON in MAINDI
VOLUPB   equ 17 ; BUTTON in MAINDI
DEACTBU  equ 18 ; BUTTON in MAINDI
VOLTXT   equ 19 ; TEXT in MAINDI
AUTHTXT  equ 20 ; TEXT in MAINDI

*ALERT1   equ 0 ; Alert string



  include gemdmacr.s 
  include aes2macr.s




progbeg

 

  lea    stack+564,sp

  bsr    AEScall
  dc.w 10 *APPL INIT

  move.w   intout(pc),ident


  

*Coordinate conversion-needed by integrated RSC
coordc
  moveq #0,d0

obfloop 
  move.w d0,obfia
  move.w d0,-(sp)

  rsrc_obfix
obfia  dc.w 0
  dc.l form1  *begin adress of objects

  move.w (sp)+,d0
  addq.b #1,d0
  cmp.b #rsc_obnum,d0 *
  bne.s obfloop


 *Calling some supervisor test at start by need
  pea supv(pc)
  move.w #38,-(sp)
  trap #14
  addq.l #6,sp 

   
  *Get aktuell drive 
  move.w #25,-(sp)
  trap #1
  addq.l #2,sp

  lea path(pc),a2  
  add.b #"A",d0
  move.b d0,(a2) 



  bsr AEScall
  dc.w 35 *Menu_register
ident  dc.w 0  *Here save
  dc.l    mename
  move.w   intout(pc),menuid


evm
  
  bsr     AEScall
  dc.w    23 *Evnt message
emadr    dc.l emb
  cmp.w    #$28,emb 
  bne.s      evm  
  move.w  emb+8(pc),d1
  cmp.w    menuid(pc),d1
  bne.s     evm


  bsr VDIcall
  dc.w 100,0,6,11,45,0 *open vswt
  dc.w 0,1,1,1,1,1,1,1,4,2,2
* VDI used only for faster mouse click response !



   bsr   mabee
   lea   form1(pc),a0
   bsr   opdial
   bsr    resscp *screen part reserve
   bsr    drdial

   bsr     desel2b
   bsr     mafing

   bsr  mctrl   *program takes maus controll
  
*Main loop of dialog    
mcont


* Instead fodial  here we use   objc_find
* combined with    evnt_button, - VDI instead

*  bsr fodial

  bsr  UserCmnd

  move.w excod(pc),d0

  *Here come actions by button press


  cmp.w #PLAYFBU,d0
  beq  loadfilW

  cmp.w  #PLAYLIBU,d0
  beq   playlist

  cmp.w #STOPPLBU,d0
  beq  stopPl

  cmp.w #REPBU,d0
  beq  toglRep

  cmp.w  #DELWAVBU,d0
  beq   toglDew

   cmp.w   #PROGBOX,d0
   beq    jumpAu

   cmp.w   #CONVWAVB,d0
   beq     convwav


  cmp.w #VOLDBU,d0
  beq  volDown

  cmp.w #VOLUPB,d0
  beq  volUp

  cmp.w  #COMPPLBU,d0
  beq   compPl


*  cmp.w   #DEACTBU,d0
*  beq   deactivate

  cmp.w #EXITBU,d0
  beq cl2



* Display progress

   bsr   progrShow
   bra   mcont






menu
  bsr mafing
*  bsr exobdes  
  bra mcont

cl2  

  bsr   maarr
  bsr   mctab *vrati kontrolu

  bsr noredr *deselect exit button

   bsr backsp

     bsr VDIcall *close vws
    dc.w 101,0,0,0,0,0


    bra  evm



redrdial   



*     bsr mafing
     bsr drdial
     bra menu  *back to dialog



mename  dc.b "  STEBPL",0
  even




volDown
   lea   setVol(pc),a1
   tst.b   (a1)
   beq.s   volExit
   subq.b  #1,(a1)
   bra.s   volCom


volUp  
   lea   setVol(pc),a1
   cmp.b  #40,(a1)
   beq.s   volExit
   addq.b  #1,(a1)

volCom 
* Set in HW and show db

   pea   volSupv(pc)
   move.w  #38,-(sp)
   trap  #14
   addq.l   #6,sp

   bsr  volConv
   
   bsr    del200    * Need delay

   moveq  #VOLTXT,d0
   bsr   obdr




volExit   bra  menu



progrShow


* Handle here deselection too

   bsr   desel2b
  
* To avoid flickering calc and update only if changed (frame)
 
   tst.b  playOn
   beq.s   skipPrsh


toProgs
* Bar max width is 310 px

   move.w  frameCnt(pc),d5
   move.w  frameLeft(pc),d4

   cmp.w   oldFram(pc),d4
   beq.s  skipPrsh

   move.w   d4,oldFram   * Store state for update control
   move.w  d5,d3
   sub.w  d4,d3    * Frames done

   mulu  #310,d3
   divu   d5,d3   * should give width in pixels
   move.w   d3,progW

  moveq  #PROGBOX,d0
  bsr     obdr   * draw with parent

* File info update, show here :

   tst.b  infoUN
   beq.s   skipPrsh

   lea   playFiNam(pc),a1
   bsr   showFile 

   moveq  #FILEINFC,d0
   bsr     obdr  

   clr.b  infoUN




skipPrsh
   rts


oldFram    dc.w  0
jumpFlag   dc.b  0
infoUN      dc.b    0
   even


jumpAu    * Jump on clicked pos in audio :


* Need x mouse pos by click :

   move.w  objcX(pc),d5   * Clicked coord.

   move.w  dialXpos(pc),d4
   addq.w  #4,d4    * 4 - relative position of progbox
* in  d4 x start pos of progbox
* width is 312 px

* Sub  bar x start coord. :
   sub.w  d4,d5    * relative pos clicked :  0-311 

* Get frame :

   move.w   frameCnt(pc),d3
   mulu   d5,d3
   divu  #312,d3

   move.w   frameCnt(pc),d4
   sub.w   d3,d4

  
   ext.l   d3
   lsl.l    #8,d3
   lsl.l     #8,d3
   add.l   #$8000,d3
   move.l   d3,curPos
   move.w  d4,frameLeft

    st   jumpFlag

    bra    menu



desel2b

   tst.b  playOn    
   bne.s    testLiOn
   tst.b    flag1
   beq.s   testLiOn
   move.w  #PLAYFBU,obnu
   bsr  clrstat     

testLiOn 
   tst.b   listOn    
   bne.s    toRtsD
   tst.b    flag3   
   beq.s   toRtsD
   move.w  #PLAYLIBU,obnu
   bsr  clrstat  

toRtsD   rts








deactivate   *  out now
* Stops playback and restores system vectors
* so  may change res.

**   moveq  #DEACTBU,d0
*   bsr   obsel    * Selected state on


  


** Deselect play button and show :

*   tst.b   playOn
*   beq.s   skipDesPb

*    pea  stopPlay(pc)
*   move.w  #38,-(sp)
*   trap   #14
*   addq.l   #6,sp



*   move.w  #PLAYFBU,obnu
*   bsr  clrstat

*skipDesPb

** Restore system vectors : 

*   pea     restSyV(pc)
*   move.w   #38,-(sp)
*   trap      #14
*   addq.l   #6,sp


** Leave button selected !

**   move.w  #DEACTBU,obnu
**   bsr  clrstat

*   bra    menu




del200    *  delay for clicks ...

     bsr AEScall
     dc.w 24 *Evnt timer
     dc.w  200    * Low word  - millisecond count 
     dc.w  0   *  High word
     rts
    






stopPl

* Set flag for list abort :
    tst.b    listOn
   beq.s  listDeal3
 
   st   listAbortF

listDeal3

   tst.b   playOn
   beq   menu

   pea  stopPlay(pc)
   move.w  #38,-(sp)
   trap   #14
   addq.l   #6,sp




* Deselect play button and show :

desPlayB
   move.w  #PLAYFBU,obnu
   bsr  clrstat


* Deselect list  play button and show :

desListPB

  
   move.w  #PLAYLIBU,obnu
   bsr  clrstat
   clr.b   listOn

  
   bra   menu





loadfilW   

  tst.b  playOn   * Avoid trouble !
  bne   menu

  bsr mabee
  lea initst(pc),a1
  bsr putext  *put initial extension
*Call fileselector:
pfilesel
  lea fsloadm(pc),a1
  bsr filesel
  tst.b buffr+100
  beq redrdial  *dialog if nothing selected

*  bsr mabee
*  bsr drdial



   lea   buffr+100(pc),a1
   lea   playFiNam(pc),a2
   move.w  #180,d1
endSl2
   move.b  (a1),(a2)+    * Copy name in meantime 
   tst.b  (a1)+
   beq.s   foundE2
   dbf   d1,endSl2
   bra   filerr

foundE2   subq.l  #2,a1
   cmp.b  #"E",(a1)
   beq     playIt    *
   bra     menu




convwav

  bsr    mabee
  lea    initstV(pc),a1
  bsr    putext  *put initial extension

*Call fileselector:

  lea     fsloadmV(pc),a1
  bsr     filesel
  tst.b   buffr+100
  beq     redrdial  *dialog if nothing selected



  bsr   drdial


* Copy selected filename (w. path) :
  lea buffr+100(pc),a1
  lea  convFiNam(pc),a2
  moveq  #44,d1
.co  move.l  (a1)+,(a2)+
  dbf  d1,.co



* Load org WAV file and convert it 

*Open selected file
  move.w #0,-(sp)
*  pea buffr+100(pc)
  pea  convFiNam(pc)
  move.w #61,-(sp) *open file
  trap #1
  addq.l #8,sp
*Error check
  tst.w d0
  bmi filerr
*  bmi redrdial  *no error message so!
  move.w d0,handlV


* Load WAV header and do some checks :

   pea    headbuf(pc)
  pea   44    * WAV Header len - always 44 by PCM WAV ?
  move.w handlV(pc),-(sp)
  move.w #63,-(sp)
  trap #1
  lea 12(sp),sp
  tst.l d0
  bmi filerrClV    

* Test for format, samplerate, etc :

* WAV first signo :
  lea   headbuf(pc),a1
  cmp.l  #"RIFF",(a1)
  bne   formErrCl 



* Samplerate :

  move.w  24(a1),d1
  ror.w  #8,d1
  cmp.w  #25033,d1
  beq.s   writSamr
  cmp.w   #50066,d1
  bne   formErrCl 

writSamr   move.w  d1,sampRat

* PCM bit count :

  cmp.b  #8,34(a1)
  bne   formErrCl 

  move.b  22(a1),d1
  cmp.b  #1,d1
  beq.s   writSteMon
  cmp.b   #2,d1
  bne   formErrCl

writSteMon  move.b  d1,SteMon

* Write out file infos
*   lea     buffr+100(pc),a1
   lea  convFiNam(pc),a1
   bsr   showFile

* Now parameters and duration :

* Need to show samplerate and  mono/stereo 

   lea   sho25k(pc),a1
   cmp.w  #25033,sampRat
   beq.s   .s1
   lea   sho50k(pc),a1

.s1
  lea   text14(pc),a2
  moveq  #7,d0
.co2  move.b  (a1)+,(a2)+
  dbf  d0,.co2

  lea  shoMon(pc),a1
  cmp.b  #1,SteMon
  beq.s   .s2
  lea  shoSte(pc),a1
  
.s2  
    lea   text14+8(pc),a2
    moveq  #5,d0
.co3  move.b  (a1)+,(a2)+
  dbf  d0,.co3

  move.b  #" ",(a2)

  * Get filelen with fseek
* not really necessary ?

  move.w #2,-(sp)  *from end mode
  move.w handlV(pc),-(sp) *handle
  clr.l -(sp)  *end
  move.w #66,-(sp)
  trap #1
  lea 10(sp),sp

  move.l d0,filelen  


* Calc duration  in  min.sec  :

  sub.l   #44,d0   * Audio data len

* by  mono, 25033 Hz data rate is :
* 25033 bytes/sec

  divu  #25033,d0

  cmp.b  #1,SteMon
  beq.s  .d1
  lsr.w  #1,d0   * div by 2

.d1
  cmp.w  #25033,SampRat
  beq.s  .d2
  lsr.w  #1,d0   * div by 2

.d2   * Now show duration in seconds in d0

  ext.l   d0
  divu   #60,d0

  move.w  d0,d6   * minutes
  swap   d0    * seconds
  move.w   d6,d1
  move.w  d0,d6
  lea   text14+15(pc),a1
  bsr   hexdec2

*  move.b  #" ",(a1)+
  move.b  #"m",(a1)+
  move.b  #" ",(a1)+

  move.w  d6,d1
*  lea   text14+18(pc),a1
  bsr   hexdec2

*  move.b  #" ",(a1)+
  move.b  #"s",(a1)+


* Show infobox2 :

  moveq  #FILEINFC,d0
  bsr    obdr



*Back to audio data begin :
  clr.w -(sp)  *from start mode
  move.w handlV(pc),-(sp) *handle
*  clr.l -(sp)  *start
  pea   44   *  always ?
  move.w #66,-(sp)
  trap #1
  lea 10(sp),sp



* If no play active may use buf1 :

   tst.b  playOn
   sne   mallocD
   bne.s  doMalloc
   move.l   #buf1,d0
   bra.s   ramCoEn

doMalloc

* Need to work with separate buffer
* if want perform conversion during playback
* so, malloc :

   pea   $10000
   move.w  #72,-(sp)
   trap   #1
   addq.l   #6,sp

   tst.l  d0
   bgt.s   ramCoEn

   bsr   closfileV

   lea    alertNoRam(pc),a0
   bsr   doalert
   bra   menu



ramCoEn
   move.l   d0,convR   * 64KB long buffer addr.




* Set convbutton selected:

   moveq  #CONVWAVB,d0
   bsr   obsel






* Create output file :

* Name :

*   lea   buffr+100(pc),a0
   lea  convFiNam(pc),a0
   lea   buffr+300(pc),a1
   moveq   #45,d1
namCl   move.l  (a0)+,(a1)+
   dbf    d1,namCl

* Replace V at end with E :

   lea   buffr+300(pc),a1
   move.w  #180,d1
endSl  tst.b  (a1)+
   beq.s   foundE
   dbf   d1,endSl
   bra   filerrClV

foundE   subq.l  #2,a1
   move.b  #"E",(a1)


 
   clr.w  -(sp)
   pea    buffr+300(pc)
   move.w   #60,-(sp)
   trap   #1
   addq.l    #8,sp
   tst.w d0
   bmi filerrClV

   move.w   d0,Ohan

* First goes 32K long header
* Size serves cluster align purpose

* Fill header with proper data :

    move.l  convR(pc),a1

   move.l  #"STEW",(a1)+   * Signo
   move.w  sampRat(pc),(a1)+
   move.b   SteMon(pc),(a1)+
   move.b  #" ",(a1)+

* Now copy info txt in header too :
   
  lea   text14(pc),a2
  moveq  #21,d1
.co   move.b  (a2)+,(a1)+
  dbf  d1,.co





*  pea    buf1(pc)
  move.l  convR(pc),-(sp)
  pea   $8000    * Header len
  move.w Ohan(pc),-(sp)
  move.w #64,-(sp)
  trap #1
  lea 12(sp),sp
  tst.l d0
  bmi filerrCl2V    
   cmp.l  #$8000,d0  *check for loaded len
  bne filerrCl2V
  

   move.l   filelen(pc),d1
   sub.l   #44,d1
   move.l  d1,oLen
   move.l  d1,remLen







* Conv loop :

convLoop

  move.l   #$10000,d7
  move.l   remLen(pc),d1
  sub.l   #$10000,d1
  bpl.s   notMinus
  clr.l    d1
  move.l   remLen(pc),d7

notMinus 
  move.l   d1,remLen     


* Load frame :
*  pea    buf1(pc)
  move.l  convR(pc),-(sp)
  move.l    d7,-(sp) 
  move.w handlV(pc),-(sp)
  move.w #63,-(sp)
  trap #1
  lea 12(sp),sp
  tst.l d0
  bmi filerrCl2V    
  cmp.l d7,d0  *check for loaded len
  bne filerrCl2V


* Do conversion and padding by need :

   move.l    d7,d2
   addq.l    #3,d2
   and.b     #$FC,d2   * Make dividable by 4
   move.l   #$10000,d1
   sub.l       d2,d1   * see for padding size
   
   move.l  #$80808080,d4
*   lea     buf1(pc),a1
   move.l  convR(pc),a1

convLl
   eor.l   d4,(a1)+   * Change bits 7 in all bytes
   subq.l   #4,d2
   bne.s   convLl

   tst.l   d1
   beq.s   noPad

paDl   clr.l   (a1)+    * Insert silence at end
   subq.l	#4,d1
   bne.s  paDl


noPad



* Save frame :

*  pea       buf1(pc)
  move.l  convR(pc),-(sp)
  pea	$10000    * Always whole frame ! 
  move.w  Ohan(pc),-(sp)
  move.w #64,-(sp)
  trap #1
  lea 12(sp),sp
  tst.l d0
  bmi filerrSCl2V
  cmp.l  #$10000,d0  *check for saved len
  bne filerrSCl2V


  tst.l   remLen
  bne   convLoop

   bsr   closFile2   * Output file close
   bsr   closFileV   * Converting input file


* Back RAM :

   tst.b   mallocD
   beq.s   delWavQ   * skip if ...

   move.l  convR(pc),-(sp)
  move.w   #73,-(sp)
  trap  #1
  addq.l  #6,sp

* Delete src WAV if checked :

delWavQ
   tst.b  flag7
   beq.s  skipDelW


   pea buffr+100(pc)
   move.w   #65,-(sp) *delete file
   trap       #1
   addq.l    #6,sp



skipDelW

   move.w  #CONVWAVB,obnu
   bsr  clrstat


* If playback stopped during conversion need to desel.
* play button too :

   tst.b  mallocD
   beq.s   skipPBS

   tst.b   playOn
   bne.s   skipPBS

   move.w  #PLAYFBU,obnu
   bsr  clrstat



skipPBS


   bra redrdial
*   bra menu

mallocD   dc.w  0   * Flag




filerrCl2
  bsr  closfile2
filerrCl
  bsr closfile
filerr
  lea alertde(pc),a0
  bsr doalert
*  bra menu 

  bra redrdial



filerrCl2V
  bsr  closfile2
filerrClV
  bsr closfileV
filerrV
  lea alertde(pc),a0
  bsr doalert
*  bra menu 

  bra redrdial




formErrCl2
  bsr  closfile2
formErrCl  
  bsr closfileV
  lea  alertFoe(pc),a0
  bsr  doalert
  bra  redrdial


filerrSCl2V   * Save error 

  bsr  closfile2
filerrSClV
   bsr closfileV
filerrSV
  lea alertse(pc),a0
  bsr doalert

   move.w  #CONVWAVB,obnu
   bsr  clrstat

   bra   redrdial



filerrLCl
  bsr closfileL

  bra menu 

*  bra redrdial



toglRep    * toggle Repeat button check state

    lea    flag4(pc),a1 
toglCom    eor.b   #4,(a1)
    bsr      obdr
    bsr    del200    * Need delay
    bra    mcont





toglDew    * toggle Del WAV after ... button check state

    lea    flag7(pc),a1 
    bra.s  toglCom

*    eor.b   #4,(a1)
*    bsr      obdr
*    bsr    del200    * Need delay
*    bra    mcont












* New concept :
* Watching all BIOS, XBIOS, GEMDOS trap usage ...



* Playback control :

timCen    * Timer-C interrupt entry point

     tst.l    tcFlag    * 4 bytes in block !
     bne    OrgTimC   * if busy skip following

* Depending on phase :

* If  phase=0   playing frame 1, so load frame 2 needed

* But start load only when in frame 1 really
* DMA counter must be in first half


    move.l   d0,-(sp)
    
*getDma pos. :

    moveq   #0,d0
    move.b  $FFFF8909.w,d0
    swap    d0
    move.b   $FFFF890B.w,d0
    lsl.w   #8,d0
    move.b   $FFFF890D.w,d0
   

    tst.b    phase
    bne    phas2   

    cmp.l  #buf2,d0
    bcc     BOrgTimC

    
* Now load   frame 2 in buf2 :

   st   tcFlag
   st   phase
   move.l   #buf2,d0   * Prep address
   bra.s   saveMany

phas2   
    cmp.l  #buf2,d0
   bcs    BOrgTimC


* Now load   frame1 in buf1 :

   st   tcFlag
   sf   phase
   move.l   #buf1,d0   * Prep address


saveMany
   move.w   sr,srSto2

   move.w  4(sp),srSto   * sr state of interrupted - d0 is pushed in meantime
   
   move.l   sp,Orgsp
   lea   stack2+756,sp
   movem.l   d1-d7/a0-a6,-(sp)
    


   * Allow Timer-C to work normal :
   move.b   #$DF,$FFFFFA11.w

* IRQ level to level at IRQ moment :
   move.w  srSto(pc),d1

* If IR level is below 3 set it to 3 !!! 
* It fixes fast H-bl activation ...

*   move.w  d1,d2
*   and.w  #$0700,d2
*   cmp.w  #$0300,d2
*   bcc.s    forcSu1
*   or.w  #$0300,d1
*   move.w   d1,srSto   * Fixed Hbl stoopidity !
*forcSu1
   or.w  #$2000,d1   * Supervisor 
   move.w  d1,sr    


* Check is Current App changed
* if yes, need to reopen file

* This means lot of unclosed files
* in case of many APP start/exit !
* Possible to add code to solve it
* By remembering more stuff.
* maybe later ....

 
   move.l   curApPo(pc),a1
   move.l   (a1),d1
   cmp.l   OpenfAp(pc),d1
   bne.s   reOpenF   

* Check for jump command

   tst.b   jumpFlag
   beq.s   LoadFrame
   clr.b   jumpFlag
   move.l  d0,-(sp)
   bra  setPos


LoadFrame
  move.l   d0,-(sp)
framLoad  pea    $10000
  move.w   handl(pc),-(sp)
  move.w  #63,-(sp)
  trap    #1    ***** condit


* For Falc vector offset too !!!!
*   tst.w  $59E.w
*   beq.s   putReta1

*   move.w  #$84,-(sp)

putReta1
*   pea  retOwT(pc)    * reta
*   move.w  sr,-(sp)
*   bra   orgTrap1
  
retOwT
  lea     12(sp),sp
   bra  frameSub   


reOpenF
  move.l  d0,-(sp)
  clr.w  -(sp)
*  pea buffr+100(pc)
  pea   playFiNam(pc)
  move.w #61,-(sp) *open file
  trap #1
  addq.l #8,sp
  move.w d0,handl

* Remember CurApp BP pointer :

   move.l   curApPo(pc),a1
   move.l  (a1),OpenfAp

* Set pos : 
setPos
   clr.w -(sp)  *from start mode
   move.w handl(pc),-(sp) *handle
   move.l   curPos(pc),-(sp)
   move.w #66,-(sp)
   trap #1
   lea 10(sp),sp

   move.l  (sp)+,d0
   bra     LoadFrame

 

frameSub    * sub 1 frame and see is last 

   add.l   #$10000,curPos
   subq.w  #1,frameLeft
   bne.s   waitTc

* End of file reached :

* Is list play on ?

*    st  fromTc  - no need

    tst.b  listOn
*    bne  ListNextAu
  beq.s  repeatIsOn

   bsr  closfile
   bra   ListNextAu


* Repeat  on ?
repeatIsOn
    btst     #2,flag4
    beq.s   PlayBoff

* Fseek to audio data begin, reload frameLeft :

   move.w  frameCnt(pc),frameLeft

   clr.w -(sp)  *from start mode
   move.w handl(pc),-(sp) *handle
   pea    $8000
   move.w #66,-(sp)
   trap #1
   lea 10(sp),sp

   move.l  #$8000,curPos

   bra.s  waitTc


* Playback off - just set loop off
PlayBoff
   and.b  #$FD,$FFFF8901.w

   bsr   closfile   
  
   bsr  restTimC   * Deactivate this Timer-C handler 
   sf   PlayOn
   sf   ListOn

waitTc

* Some corrections in own stack top, for correct Timer-C exec :
* 14 regs on stack currently !

* Ensure ret in sp restorer :
   move.l     #timCReta,58(sp)
   move.w   #$84,62(sp)   * for  68030 case
   move.w   srSto(pc),d1
   or.w 	  #$2000,d1    * Supervisor ret needed
   move.w   d1,56(sp)

 

   movem.l   (sp)+,d1-d7/a0-a6

* Keep still own stack for case of nested Timer-C IRQ !

*   move.l   OrgSp(pc),sp


   move.w   srSto2(pc),sr   * Back increased sr
   bra.s  OrgTimC


BOrgTimC    move.l  (sp)+,d0   * Only from after testing DMA pos !
OrgTimC    jmp   0     *  Will be set


timCReta
    move.l   OrgSp(pc),sp
    move.l  (sp)+,d0
    clr.b    tcFlag  
    rte
  



stopPlay
   
   and.b  #$FC,$FFFF8901.w    * Loop off , play off


   bsr   closfile 
   bsr  restTimC   * Deactivate this Timer-C handler 
       

   sf   PlayOn
   sf    listOn
   
   rts








srSto   dc.w   0
srSto2   dc.w   0


tcFlag   dc.b   0
BiosF   dc.b  0   * This 4 makes long !
XbiosF   dc.b  0
GemDF   dc.b  0    * Keep together them !

phase   dc.b   0
  even
frameLeft   dc.w    990   * Max 65535 frames
* It means about : many hours :-)

frameCnt   dc.w   1000    * Preset them because of progress bar

curPos    dc.l   0

curApPo   dc.l  0
OpenfAp   dc.l  0

orgSp     dc.l   0





restTimC
   move.l  orgTimC+2(pc),$114.w


*   move.l   orgHbl(pc),$68.w

* Restore traps too : - not !

*  move.l   orgTrap1+2(pc),$84.w
*  move.l   orgTrap13+2(pc),$B4.w
*  move.l   orgTrap14+2(pc),$B8.w

  
   rts






playIt     * Playback of WAE  file :

* 1 load header and do some checks, settings ...
* todo ...

   
*Open selected file
  move.w #0,-(sp)
*  pea buffr+100(pc)
  pea   playFiNam(pc)
  move.w #61,-(sp) *open file
  trap #1
  addq.l #8,sp
*Error check
  tst.w d0
  bmi filerr
  move.w d0,handl

* Remember CurApp BP pointer :

   move.l   curApPo(pc),a1
   move.l  (a1),OpenfAp


* Get filelen & calc frame count :

  move.w #2,-(sp)  *from end mode
  move.w handl(pc),-(sp) *handle
  clr.l -(sp)  *end
  move.w #66,-(sp)
  trap #1
  lea 10(sp),sp

  sub.l   #$8000,d0    * Header len less
  lsr.l   #8,d0
  lsr.l   #8,d0    * div by $10000

  
  move.w   d0,frameCnt   * 
  subq.w  #1,d0
  move.w   d0,frameLeft

* Back to file begin :
  clr.w -(sp)  *from start mode
  move.w handl(pc),-(sp) *handle
  clr.l -(sp)  *start
*  pea   44
  move.w #66,-(sp)
  trap #1
  lea 10(sp),sp




  pea    buf1(pc)
  pea    $8000    * Header len
  move.w   handl(pc),-(sp)
  move.w  #63,-(sp)
  trap    #1
  lea     12(sp),sp


* Checks, settings according to header !

   lea   buf1(pc),a1

   cmp.l   #"STEW",(a1)+

* Invalid file alert here and break !

* todo !



   move.w  (a1)+,sampRatP
   move.b  (a1),SteMonP

  addq.l   #2,a1

* Copy infos :

   lea   text14(pc),a2
   moveq  #20,d1
.co   move.b  (a1)+,(a2)+
   dbf  d1,.co



* Preload frame 1 in buf1 :

  pea    buf1
  pea    $10000    * frame len
  move.w   handl(pc),-(sp)
  move.w  #63,-(sp)
  trap    #1
  lea     12(sp),sp





* Flags for case of loosing handle :
* What happens when started in APP
* and exit to desktop - due to closing all handles
* or on Falcon at regular APP start ...


   move.l  #$18000,curPos



   clr.l    tcFlag
   clr.b   phase




* Now start DMA : 


   pea   dmaSupP(pc)
   move.w   #38,-(sp)
   trap   #14
   addq.l   #6,sp


   st  PlayOn    * flag


* Set playbutton selected:

   moveq  #PLAYFBU,d0
   bsr   obsel


* Show infos about file beeing played :

   lea   playFiNam(pc),a1
   bsr   showFile 


* Now parameters and duration :

* Need to show samplerate and  mono/stereo 



* params & duration  in  min.sec  :

* Best to get it from header :
* done above


  * Show infobox2 :

*  moveq  #FILEINFC,d0
*  bsr    obdr
* No need - redrdial coming







   bra redrdial    * Needed after fileselector






*  Filename show :
* called from 2 place

showFile
*   lea     buffr+100(pc),a1
   move.w   #180,d1
   moveq   #0,d2    * counter
endSl5    addq.w  #1,d2
   tst.b    (a1)+
   beq.s   foundE5
   dbf      d1,endSl5
   bra    filerrClVS 

foundE5  
* See back backslash until  counted bytes :

seekBs   cmp.b  #"\",-(a1)
   beq.s   foundE4bs
   subq.w  #1,d2
   bne.s    seekBs
   bra    filerrClVS     * in ROOT ???? !!!! - test !

foundE4bs  addq.l  #1,a1

* Copy name to info box and show :
* but must padd end with spaces
* to cover possible longer previous

  lea    text13(pc),a2
  moveq     #11,d0
.co  move.b    (a1)+,d1
  beq.s     fneR
  move.b   d1,(a2)+ 
  dbf     d0,.co
  bra.s   showFn

fneR  move.b  #" ",(a2)+
  dbf  d0,fneR


showFn
  moveq  #FINAMINF,d0
  bsr    obdr
  rts


filerrClVS
   addq.l  #4,sp    * drop caller
   bra  filerrClV





















dmaSupP

   bsr   sndinit

 
    move.b   #3,$FFFF8901.w    * start DMA, loop mode

   * Set Timer-C handler active :

   move.l   $114.w,orgTimC+2
   move.l  #TimCen,$114.w

   

   rts



* Must disable disk access etc. while background ld. active !
* No need - just set flags and take care of nesting !


newTr1

   st   GemDF   * busy right now
    

* Pexec needs special processing :

* Test for command - is Pexec :

   btst   #5,(sp)    * Caller status ?
   bne.s  supTr1c
* User call :
   move.l   usp,a0
   bra.s   isPex

supTr1c  lea 6(sp),a0    *  8 for 68030 !

isPex   * But only modes 0 and 4 - where starts !
   cmp.w  #75,(a0)+
   bne.s   notPex
   tst.w   (a0)
   beq.s   pexecLoRu
   cmp.w  #4,(a0)
   bne.s  notPex

pexecLoRu
   move.l   nestPo(pc),a1
   move.l   2(sp),(a1)+
   move.l   a1,nestPo
   move.l   #retTfTrP1,2(sp)    * Here ret after APP exit 

*   bra.s  baOrTr1A

* Try with not putting org Tr1 after Pexec det. 
* For Falcon :
   bra.s   orgTrap1


* Change reta in stack :

notPex   

* Catch  Desktop res. change
* by looking memfree command :

   cmp.w  #73,-(a0)
   beq   memFree
 


notMfree

   move.l  2(sp),tr1reta+2    
   move.l   #retTfTr1,2(sp)


* Only 1 level supported - and enough !
* So, back org Trap #1 value :

baOrTr1A
  move.l  orgTrap1+2(pc),$84.w  * For nested calls


orgTrap1   jmp   0    * Will be set

* Set own Trap #1 again :

retTfTr1
    lea    newTr1,a1   * a1,a2 random after Trap call !
    lea    $84.w,a2
    trap  #3     * Ensure supervisor mode while write !
*    clr.b   GemDF    * clr not good - some apps look Z flag after Trap ret !!!!

    sf  GemDF

tr1reta   jmp   0   * will be set


retTfTrP1  
   
    lea    newTr1,a1   * a1,a2 random after Trap call !
    lea    $84.w,a2
    trap  #3     * Ensure supervisor mode while write !
    
    sf  GemDF

tr1Pexreta  *  jmp   0   * This supports only 1 level of Pexec !
* More level support :

   move.l  nestPo(pc),a1
   move.l  -(a1),a2
   move.l   a1,nestPo
*   tst.l	d0      * For some cases, likely not needed after Pexec ...
   jmp   (a2)



nestPo   dc.l   nestBuf    * initial
* place for 10 level nested Pexecs



newTr13

  st    BiosF

* Change reta in stack :
  
   move.l   2(sp),tr13reta+2    
   move.l   #retTfTr13,2(sp)


* Here should be no nested calls  ?
* They are !
   * So, back org Trap #13 value :

   move.l  orgTrap13+2(pc),$B4.w  * For nested calls

orgTrap13   jmp   0    * Will be set

retTfTr13
    lea    newTr13,a1   * a1,a2 random after Trap call !
    lea    $b4.w,a2
    trap  #3     * Ensure supervisor mode while write !
*    clr.b   BiosF   * free it
   sf  BiosF

tr13reta    jmp   0   * will be set



trap3code   move.l  a1,(a2)
   rte





newTr14

  st    XBiosF

* Change reta in stack :
  
   move.l   2(sp),tr14reta+2    
   move.l   #retTfTr14,2(sp)

* Here should be no nested calls  ?
* They are !
   * So, back org Trap #14 value :

   move.l  orgTrap14+2(pc),$B8.w  * For nested calls

orgTrap14   jmp   0    * Will be set

retTfTr14
    lea    newTr14,a1   * a1,a12 random after Trap call !
    lea    $b8.w,a2
    trap  #3     * Ensure supervisor mode while write !
*    clr.b   XBiosF   * free it
   sf  XBiosF

tr14reta    jmp   0   * will be set




* Solution for res. change :

memFree
  lea  progBeg-256(pc),a1
  cmp.l  2(a0),a1    * Release ACC's mem ?

   bne   notMfree
  
* Stop playback, restore vectors

   tst.b   playOn
   beq.s   backSyV   * Needed ?

   bsr  stopPlay

backSyV
   bsr  restSyV 


   bra   orgTrap1  * Will not restore own Trap #1 -
* reta not changed here !













PlayOn   dc.w  0


**  ????

*orgHbl    dc.l    0


* Following works not on Falcon ! - must check it's TOS 
* Not using it at all :

*HblCod    
* Same as in TOS 2.06 :

*   move.w   d0,-(sp)
*   move.w   2(sp),d0
*   and.w     #$700,d0
*   bne.s   notZerHb
*   or.w     #$0300,2(sp)

*notZerHb   move.w  (sp)+,d0
** + clear GemDos busy flag
*   clr.b   GemDF    *  otherwise stuck in PRG, TOS APP ...  
** But on Falcon it works not (TOS 4.0x) 

** + own trap #1 again
*   move.l  #newTr1,$84.w   -  not good  ???

** Likely solution is to do support for nested Pexecs !
** right - done .

*   rte    



volConv
* convert chain 0-40 to -80 - 0 , step 2, respective

  clr.w   d2
  move.b  setVol(pc),d2
  lsl.b  #1,d2    * x 2
  moveq  #80,d1
  sub.b  d2,d1  * That's it
  move.b  d1,setDb   * Not really needed

* Show immed :
   lea   text17+1(pc),a1
   

*   rts    
* Ret via :


hexdec2  moveq #10,d2
  moveq #1,d4
hex2  moveq #10,d3
  move.b #-$10,d5 *Space code prepare
hdlp ext.l d1
  divu d2,d1
  beq.s less
  clr.b d5
  bra.s moretz
less tst.b d4  *If is 0!
  bne.s skip
  clr.b d5
skip  move.b d5,d1
moretz add.b #$30,d1
  move.b d1,(a1)+
  swap d1
  divu d3,d2
  dbf d4,hdlp
  rts










setDb   dc.b   10    * Initial value  - 10 db
setVol  dc.b  35




* Volume control, supervisor part 
* setting master volume, by calced value in byte



volSupv
   tst.b   isFalc
   bne   skipVof

   move.w $FFFF8922.w,old
   move.w $FFFF8924.w,om


   move.w #$7FF,$FFFF8924.w

   clr.w   d1
   move.b   setVol(pc),d1      * 6 bits, but max 40, so   $0 - $28
   or.w  #$04C0,d1
   move.w   d1,$FFFF8922.w  *master

wVol
   move.w    old(pc),d1
   cmp.w   $FFFF8922.w,d1
   nop
   bne.s     wVol

   move.w    om(pc),$FFFF8924.w




skipVof
   rts






sndinit

	tst.b  isfalc
	bne   setadma

  *Setting mixer, volumes:

   move.w $FFFF8922.w,old
   move.w $FFFF8924.w,om

   move.w #$7FF,$FFFF8924.w
   move.w #$401,$FFFF8922.w  *mixer - corrected PSG level !

w1
   move.w old(pc),d1
   cmp.w $FFFF8922.w,d1
   nop
   bne.s w1 

   move.w $FFFF8922.w,old
   
   move.w #$7FF,$FFFF8924.w

*   move.w #$4E8,$FFFF8922.w  *master
   clr.w   d1
   move.b   setVol(pc),d1      * 6 bits, but max 40, so   $0 - $28
   or.w  #$04C0,d1
   move.w   d1,$FFFF8922.w  *master


w2
   move.w old(pc),d1
   cmp.w $FFFF8922.w,d1
   nop
   bne.s w2

   move.w $FFFF8922.w,old
   
   move.w #$7FF,$FFFF8924.w
   move.w #$574,$FFFF8922.w  *left

w3
   move.w old(pc),d1
   cmp.w $FFFF8922.w,d1  
   nop
   bne.s w3

   move.w $FFFF8922.w,old
    
   move.w #$7FF,$FFFF8924.w
   move.w #$534,$FFFF8922.w   *right

w4
   move.w old(pc),d1
   cmp.w $FFFF8922.w,d1
   nop
   bne.s w4

   move.w  om(pc),$FFFF8924.w
  

*begin
setadma

   clr.b    $FFFF8901.w   * off

    * Writing DMA begin address
   lea           buf1(pc),a1
   move.l      a1,d1
   
   swap        d1
   move.b    d1,$FFFF8903.w   * Order important, first Hi-byte !
   swap        d1
   clr.l           d2
   move.b     d1,d2
   lsr.w          #8,d1
   move.b      d1,$FFFF8905.w
   move.b      d2,$FFFF8907.w


  *Writing DMA end address
  
  add.l       #$20000,a1 * 128KB long buffer 
  move.l     a1,d1
   
   swap        d1
   move.b     d1,$FFFF890F.w
   swap         d1
*   clr.l           d2
   move.b     d1,d2
   lsr.w         #8,d1
   move.b     d1,$FFFF8911.w
   move.b     d2,$FFFF8913.w

  *Mode set - later may need more choices !

*   or.b         #$81,$FFFF8921.w   *mono , 25033 Hz


   cmp.w  #25033,sampRatP
   bne.s   set50kp
   or.b     #$02,$FFFF8921.w   * 25033 Hz
   and.b  #$FE,$FFFF8921.w 
   bra.s    seeSterMon2

set50kp
   or.b     #$03,$FFFF8921.w   * 50066 Hz

seeSterMon2
   cmp.b   #1,SteMonP
   bne.s  setSterP
   
   or.b  #$80,$FFFF8921.w    * Mono
   bra.s    finDMAset


setSterP
   and.b   #$7F,$FFFF8921.w      *  stereo 

finDMAset

*   and.b     #$FD,$FFFF8921.w  *reset bit 1

   rts
	

old    ds.w 1
om    ds.w 1
isfalc   dc.w  0





*stopT   dc.b  "STOP",0,0

*playTxt  dc.b   "Play file",0

*  even









supv   *move.l $42e.w,orgphyst

  

 *get TOS version too here
*Good because of different fileselector possible

  move.l 4.w,d1
  clr.b d1  *on round address always
  move.l d1,a1
  move.b 2(a1),d0  *TOS ver major
  move.b 3(a1),d1  *TOS ver minor

* Get cur APP basepage pointer :
   move.l  $28(a1),curApPo

   cmp.b #2,d0
   blt.s itstos1

* 68030  fix :

   cmp.b  #3,d0

   blt.s   not68030


   lea   supTr1c(pc),a1
   lea   FalcCor1(pc),a2
   move.l   (a2)+,(a1)+    * 4 bytes
*   move.w   (a2),(a1)




* Falcon snd init needed too   !
* At least on TOS 4.02 for sure
 
   cmp.b  #4,d0
   bne.s   notFalc
    
   st   isFalc

* Setting Falcon sound, so will have STE DMA audio  (TOS 4.02 only need it ? )

    move.w  #1,-(sp)
    clr.l   -(sp)
    move.w  #8,-(sp)
    clr.w  -(sp)
    move.w  #$8B,-(sp)
    trap   #14
    lea   12(sp),sp

* Here need to disable Volume controls too !!!



notFalc


not68030
*  rts  *ret immed if TOS 2 or more
  bra.s   setVecs

itstos1 cmp.b #4,d1
  blt.s under14
  bra.s  setVecs

under14   st oldtos


setVecs

* Vectors, H-blank permanently set :
  
    
* Install Trap #3 handler :

   move.l  #trap3code,$8C.w


*  By APP start H/blank activates - it is good
* to clear GemDos busy flag as no Trap #1 real exit !!!


* H-blank handler not used now :

*   move.l   $68.w,orgHbl

** Not on Falcon
*   tst.b   isFalc
*   bne.s  skipHblCh
*   move.l   #HblCod,$68.w
*skipHblCh   

* Trap #13  - must it too, as is used by hard disk access

   move.l   $B4.w,orgTrap13+2
   move.l  #newTr13,$B4.w

* Trap #14  -  too

   move.l   $B8.w,orgTrap14+2
   move.l  #newTr14,$B8.w



* Trap #1
   move.l   $84.w,orgTrap1+2
   move.l  #newTr1,$84.w
   
 

  rts



FalcCor1     lea 8(sp),a0   * 4 bytes




restSyV    
   move   #$2700,sr

*   move.l   orgHbl(pc),$68.w

   move.l   orgTrap1+2(pc),$84.w
   move.l   orgTrap13+2(pc),$B4.w
   move.l   orgTrap14+2(pc),$B8.w
 
   addq.l  #2,$8C.w    * This disables vector write via trap #3 
  
   move  #$2300,sr
   rts





playlist  

  tst.b  playOn   * Avoid trouble !
  bne   menu

  tst.b   listOn
  bne   menu 


* Here need to check List abort flag and
* ask about continue if is set !!!
* to do !


   tst.b     listAbortF   * Is list play aborted ?
   sf   listAbortF
   beq.s    listFils  

   lea      alertLsb(pc),a0
   bsr      doalert
*   tst.w   intout
   cmp.w  #2,intout
   beq.s  listFils

   
   st  listOpen    * flag that not from Timer-C control ...
   move.l   listCont(pc),listPo
   moveq  #PLAYLIBU,d0
   bsr   obsel
   bra   ListNextAu



listFils  
  bsr     mabee
  lea    initLst(pc),a1
  bsr    putext  *put initial extension
*Call fileselector:
  lea     fsloadL(pc),a1
  bsr     filesel
  tst.b   buffr+100
  beq    redrdial  *dialog if nothing selected

   st  listOpen    * flag that not from Timer-C control ...


   lea    listFiNam(pc),a1
   lea    buffr+100(pc),a0
   moveq   #44,d1
.co   move.l  (a0)+,(a1)+
   dbf    d1,.co


  *Open selected file
  move.w #0,-(sp)
  pea   listFiNam(pc)
  move.w #61,-(sp) *open file
  trap   #1
  addq.l    #8,sp
*Error check
  tst.w    d0
  bmi       filerr
  move.w d0,handLst

* Len max  1024 bytes !

* Load in :

  pea    ListBuf(pc)
  pea    1024    * max len
  move.w   handLst(pc),-(sp)
  move.w  #63,-(sp)
  trap    #1
  lea     12(sp),sp
  
  move.l  d0,listLen
  ble     filerrLCl

  bsr   closfileL


* Set play list button selected:

   moveq  #PLAYLIBU,d0
   bsr   obsel





repeatList

* Set list end pointer :

  move.l  listLen(pc),d0
  add.l  #listBuf,d0
  move.l  d0,listEnd

  move.l  #listBuf,listPo


* List play main loop :

listMainL  

* get filename :

ListNextAu

  


* Seek  CR and/or Newline :

   move.l   listPo(pc),a1
   move.l   listEnd(pc),a5   * end here, for limit

   cmp.l  a1,a5
   ble   reachLe


crseekL  cmp.b  #13,(a1)
   beq.s  nlFou
   cmp.b  #10,(a1)
   beq.s  crFou
   addq.l  #1,a1
   cmp.l  a1,a5
   ble   reachLe
   bra.s   crseekl

nlFou  
   move.l   a1,a2   * store end loc
   addq.l  #1,a1
   cmp.b  #10,(a1)
   bne.s  nextNamB
   addq.l   #1,a1
   bra.s   nextNamB

crFou
   move.l   a1,a2   * store end loc
   addq.l  #1,a1
   cmp.b  #13,(a1)
   bne.s  nextNamB
   addq.l   #1,a1
  
nextNamB
   

  move.l   a1,listNext

* copy name to play part :

*  If only filename need to add PLS file's path too !

   move.l   listPo(pc),a1
   cmp.b  #"\",(a1)   * 
   beq.s   withPath
   cmp.b  #":",1(a1)
   beq.s  withPath


* Get list File  path :

   lea   listFiNam(pc),a1
* Seek end terminator :

   move.w  #179,d1

.ll   tst.b  (a1)+
   beq.s   liFnEnr   
   dbf  d1,.ll
   bra   filerrLClTc    *** !


* seek backslash backwards :
liFnEnr  
   move.w  #179,d1
.lb  cmp.b  #"\",-(a1)
  beq.s  liFbSl
  dbf  d1,.lb
  bra   filerrLClTc   * Abort in such case


* Copy path : 
liFbSl
   lea   listFiNam(pc),a4
   lea   playFiNam(pc),a3
.cop  move.b  (a4)+,(a3)+
   cmp.l   a4,a1
   bne.s  .cop

   move.b  (a4)+,(a3)+
   move.l   listPo(pc),a1
   bra.s    colFP


withPath
    move.l   listPo(pc),a1
    lea   playFiNam(pc),a3
colFP  move.b  (a1)+,(a3)+
    cmp.l  a1,a2
    bne.s   colFP

   clr.b  (a3)

   move.l   listPo(pc),listCont   * for continue case

   move.l   listNext(pc),listPo    * prepare next

   st   listOn   * Play from list flag


* Now start with playback
* silently if dialog not opened (on screen)


*Open  actual file from list

*



  move.w #0,-(sp)
  pea   playFiNam(pc)
  move.w #61,-(sp) *open file
  trap #1
  addq.l #8,sp
*Error check
  tst.w d0
  bmi filerr
  move.w d0,handl

* Remember CurApp BP pointer :

   move.l   curApPo(pc),a1
   move.l  (a1),OpenfAp


* Get filelen & calc frame count :

  move.w #2,-(sp)  *from end mode
  move.w handl(pc),-(sp) *handle
  clr.l -(sp)  *end
  move.w #66,-(sp)
  trap #1
  lea 10(sp),sp

  sub.l   #$8000,d0    * Header len less
  lsr.l   #8,d0
  lsr.l   #8,d0    * div by $10000

  
  move.w   d0,frameCnt   * 
  subq.w  #1,d0
  move.w   d0,frameLeft

* Back to file begin :
  clr.w -(sp)  *from start mode
  move.w handl(pc),-(sp) *handle
  clr.l -(sp)  *start
  move.w #66,-(sp)
  trap #1
  lea 10(sp),sp




  pea    buf1(pc)
  pea    $8000    * Header len
  move.w   handl(pc),-(sp)
  move.w  #63,-(sp)
  trap    #1
  lea     12(sp),sp


* Checks, settings according to header !

   lea   buf1(pc),a1

   cmp.l   #"STEW",(a1)+

* Invalid file alert here and break !

* todo !



   move.w  (a1)+,sampRatP
   move.b  (a1),SteMonP

  addq.l   #2,a1

* Copy infos :

   lea   text14(pc),a2
   moveq  #21,d1
.co   move.b  (a1)+,(a2)+
   dbf  d1,.co



* Preload frame 1 in buf1 :

  pea    buf1
  pea    $10000    * frame len
  move.w   handl(pc),-(sp)
  move.w  #63,-(sp)
  trap    #1
  lea     12(sp),sp



* Flags for case of loosing handle :
* What happens when started in APP
* and exit to desktop - due to closing all handles
* or on Falcon at regular APP start ...


   move.l  #$18000,curPos



*   clr.l    tcFlag
   clr.b   phase




* Now start DMA : 
* Without Timer-C set if not from listopen

   lea   dmaSupP(pc),a1

   tst.b   listOpen
   bne.s   fromLopS

   lea   dmaSupP2(pc),a1

fromLopS
   pea   (a1)
   move.w   #38,-(sp)
   trap   #14
   addq.l   #6,sp


   st  PlayOn    * flag



* Show infos about file beeing played :
* What when dialog not shown ????


* If from Timer-C control can not use AES calls !!!!

* Best that progress show code take care about
* updating info boxes !

   st   infoUN    * flag that info update needed   




*   lea   playFiNam(pc),a1
*   bsr   showFile 






   tst.b   listOpen
* if not by list opening then was called from control

*  bne.s   toClrLoFl

  beq   waitTc   * called from Timer-C handler code

   
*   bra   waitTc



toClrLoFl
   clr.b   listOpen
   bra redrdial    * Needed after fileselector
* Leave  Play list button selected !


listOpen  dc.b  0
listOn    dc.b   0
listAbort   dc.b  0
*fromTc    dc.b  0
listAbortF   dc.b   0

  even

listCont    dc.l   0



dmaSupP2

   clr.b   $FFFF8901.w
   bsr   sndinit
 
    move.b   #3,$FFFF8901.w    * start DMA, loop mode

    rts






















reachLe     * list end reached - stop or again from start
* depending on checked endless box

  
* Repeat  on ?

    btst     #2,flag4
    beq.s  listPlayEnd


   bra    repeatList



filerrLClTc

   tst.b  listOpen
   bne.s    listPlayEnd

   clr.b  listOn
   clr.b  playOn
   bra    waitTc



listPlayEnd  

* If not first ...  !!!


* Deselect button etc.
 
   clr.b   listOn
   clr.b  playOn

   

   tst.b  listOpen    * should never happen that is set here !
   bne   menu

    and.b  #$FD,$FFFF8901.w

   bsr  restTimC   * Deactivate  Timer-C handler 

   bra   waitTc



* Composing   playlist
compPl

* For now simpler part :  put all WAE files
* in selected DIR into selected/given PLS file
* with Fsfirst, Fsnext functions  :


* Needs  new  buffer of 1024 bytes,
* space to store cur DIR for restoring at end

   move.w  #25,-(sp)   * Get current partition
   trap    #1
   addq.l  #2,sp
   move.w   d0,curDrv

   clr.w   -(sp)    * Cur drv.
   pea   curPath(pc)    * Get cur path
   move.w  #71,-(sp)   
   trap    #1
   addq.l  #8,sp

* Now fileselector :

   bsr     mabee
   lea    initLst(pc),a1
   bsr    putext  *put initial extension
*Call fileselector:
   lea     fsPlFnam(pc),a1
   bsr     filesel
   tst.b   buffr+100
   beq    redrdial  *dialog if nothing selected

* Check for correct extension :

   cmp.b   #".",-4(a1)
   bne.s   noExt1
   cmp.b   #"P",-3(a1)
   bne.s   noExt1
   cmp.b   #"L",-2(a1)
   bne.s   noExt1
   cmp.b   #"S",-1(a1)
   beq.s   copyCpN1

noExt1   lea  initLst+1(pc),a0
   moveq  #4,d2
.co  move.b  (a0)+,(a1)+   * add reg. extension
  dbf  d2,.co
* Maybe little more check needed, for now OK .


copyCpN1
   lea    compFiNam(pc),a1
   lea    buffr+100(pc),a0
   moveq   #44,d1
.co   move.l  (a0)+,(a1)+
   dbf    d1,.co


* Need to set path of selected/given as current :

   lea   buffr+100(pc),a1
* Seek end terminator :

   move.w  #179,d1

.ll   tst.b  (a1)+
   beq.s   liPEnr   
   dbf  d1,.ll
   bra   restCurDP   


* seek backslash backwards :
liPEnr  
   move.w  #179,d1
.lb  cmp.b  #"\",-(a1)
  beq.s  liPbSl
  dbf  d1,.lb
  bra   restCurDP   * Abort in such case
  




liPbSl   * set it as current :
    clr.b  (a1)

   clr.w    d2
   move.b   buffr+100(pc),d2
   sub.b   #"A",d2 
   move.w  d2,-(sp)
   move.w  #14,-(sp)   
   trap    #1
   addq.l  #6,sp



    pea   buffr+102(pc)   * Skip C: 
   move.w  #59,-(sp)   
   trap    #1
   addq.l  #6,sp

   move.w  #47,-(sp)   * Get DTA adr.
   trap    #1
   addq.l  #2,sp
   move.l   d0,dtaAdr
 
   move.l  #listCompB,nextLCi



* Start seek   

   clr.w   -(sp)
   pea   initst(pc)   * WAE
   move.w  #78,-(sp)    * Fsfirst
   trap    #1
   addq.l  #8,sp
   tst.w   d0
   bne   restCurDP   * out if nothing found

   bsr    putNnam
   tst.b   d0
   bne.s   saveNList


listComLoop
* test for end reached :


   move.w  #79,-(sp)   * Fsnext
   trap    #1
   addq.l  #2,sp
    tst.w   d0
    bne.s   saveNList
    bsr    putNnam
    tst.b   d0
    bne.s   saveNList
   
    bra.s   listComLoop

saveNList

   clr.w   -(sp)
   pea    compFiNam(pc)
   move.w  #60,-(sp)     * Fcreate - kills existing if .. , without warn !
   trap    #1
   addq.l  #8,sp
   move.w   d0,d7
*   tst.w   d0
   bmi   restCurDP

   pea   listCompB(pc)
   move.l   nextLCi(pc),d1
   sub.l   #listCompB,d1
   move.l  d1,-(sp)
   move.w   d7,-(sp)
   move.w  #64,-(sp)   * Get current partition
   trap    #1
   lea    12(sp),sp

* Some check ? 

   move.w   d7,-(sp)
   move.w  #62,-(sp)
   trap  #1
   addq.l   #6,sp










restCurDP

* Restore cur drv and path :

   move.w  curDrv(pc),-(sp)
   move.w  #14,-(sp)   
   trap    #1
   addq.l  #6,sp

   pea   curPath(pc)
   move.w  #59,-(sp)   
   trap    #1
   addq.l  #6,sp


    bra redrdial    * Needed after fileselector






putNnam
* filename from DTA to list under making

   move.l  dtaAdr(pc),a0
   lea   30(a0),a0   * filename here
   move.l   nextLCi(pc),a1

  moveq  #13,d3
.con   move.b  (a0)+,(a1)+
   beq.s  dtaNamE
   dbf   d3,.con
   bra.s  finList

dtaNamE
  subq.l  #1,a1  * no need for 0 term.
  move.b  #13,(a1)+
  move.b  #10,(a1)+

  cmp.l  #listCompB+1024,a1
  bgt.s  finList

  move.l  a1,nextLCi
  clr.b    d0   * OK flag
    rts

finList  
  moveq  #5,d0   * list end flag
  rts 



nextLCi   dc.l   0




closfile2  move.w Ohan(pc),-(sp)
  move.w #62,-(sp)
  trap #1
  addq.l #4,sp
  rts
  


closfile  move.w handl(pc),-(sp)
  move.w #62,-(sp)
  trap #1
  addq.l #4,sp
  rts



closfileV  move.w handlV(pc),-(sp)
  move.w #62,-(sp)
  trap #1
  addq.l #4,sp
  rts

closfileL  move.w handLst(pc),-(sp)
  move.w #62,-(sp)
  trap #1
  addq.l #4,sp
  rts
	

*AES dialog subrutines


*DRAW DIALOG SUBRUTINE
*In parameter:a0-tree adress

opdial *put tree adress on all places where needed 
  lea fca(pc),a1 
  move.l a0,(a1)
*  move.l a0,oda-fca(a1)
  move.l a0,fda-fca(a1)
  move.l a0,oca-fca(a1)
  move.l a0,oda2-fca(a1)
  move.l a0,oda2f-fca(a1)
  move.l a0,oda3-fca(a1)
*  move.l a0,oboff+2-fca(a1)
*centre objekt
  
  form_center
fca ds.l 1
*Enter coords
  lea cost(pc),a1 
  lea intout+2(pc),a0
  bsr.s copint2
  bsr.s copints
*  lea odp(pc),a1 
*  bsr.s copints
  lea odp2+4(pc),a1
  bsr.s copints
  lea fdf+2(pc),a1
  bsr.s copints
  bsr.s copints
  lea obnu+4(pc),a1
  
copints lea cost(pc),a0
copint2 moveq #3,d0
copil move.w (a0)+,(a1)+
  dbf d0,copil
  rts



*Reserve screen part
resscp
  form_dial
  dc.w 0
cost ds.w 8 
  rts



drdial 
  moveq #0,d0
  bra obdr  *ret via



   








userCmnd    * Watching for user command

* Some slow reaction after entering dialog from Desk menu
* ??

* What we need is mouse pos and button state :

   bsr VDIcall
   dc.w 124,0,1,0,1,0

   tst.w  vintout
   beq.s  exCmd 

   move.l   vptsout(pc),objcX   * Can both at once

   objc_find
   dc.w    0   * Start obj. #
   dc.w    1   * Depth 
objcX     dc.w  0  ***   
objcY     dc.w  0  ***
objcAdr  dc.l   form1
      
   move.w intout(pc),excod  *Save exit button
   rts

exCmd  
    clr.w  excod
    rts



VDIcall  move.l (sp),a1  * control block
  lea vcontr(pc),a2
  move.l a1,a0
  moveq #5,d0  *copy 6 words
cbmov  move.w (a1)+,(a2)+
  dbf d0,cbmov 
  lea VDIPB(pc),a2
  lea 12(a0),a1
  move.l a1,8(a2)
  move.w 2(a0),d0  *# of ptsin
  lsl.w #2,d0  
  add.l d0,a1  *adress of intin
  move.w 6(a0),d0
  beq.s nointin
  move.l a1,4(a2)
  lsl.w #1,d0  *mult by 2
  add.l d0,a1 
nointin  move.l a1,(sp)  *Skip datas!
  move.l a2,d1
  moveq #115,d0
  trap #2  *Call VDI function
  rts


VDIPB    dc.l vcontr
pintv      dc.l 0
ptsin       dc.l 0
vioadr    dc.l vintout
vptsadr   dc.l  vptsout





*Object exit rutine "Form do"
  
fodial
  form_do
  dc.w 0
fda ds.l 1
  move.w intout(pc),excod  *Save exit button
  rts

cldial  bsr.s noredr

*Back screenpart
backsp
  form_dial
fdf dc.w 3
  ds.w 8

  rts

obsel move.w d0,obnu
  move.w #1,status
  bra.s ochl
obdes move.w d1,obnu
  bra.s clrstat

noredr  clr.w status+2  *No redraw by leave dialog
exobdes
  move.w excod(pc),obnu
clrstat  clr.w status  *normal status
ochl 
  objc_change
obnu dc.w 0,0,0,0,0,0
status  dc.w  0,1
oca   ds.l   1
  move.w #1,status+2 * redraw needed after again
  rts



doalert
  move.l a0,ala
  form_alert
  dc.w 1  *Default
ala  dc.l 0 
  move.w intout(pc),d0
  cmp.w #1,d0 *test pressed key
  rts



obdr    move.w   d0,odp2
  objc_draw
odp2    dc.w   0,2 *depth=2 used
    ds.w 4
oda2   ds.l    1
  rts


clobdr  *startobject is mainbox 
  objc_draw
odp3 dc.w 0,2 *depth=2 used
clip3  ds.w 4
oda3 ds.l 1
  rts

obdrf move.w d0,odp2f
  bsr AEScall
  dc.w 42
odp2f dc.w 0,0
  ds.w 4
oda2f ds.l 1
  rts


mctrl
  wind_update
  dc.w 3
  rts

mctab
  wind_update
  dc.w 2
  rts

mafing moveq #3,d1
  bra.s grafmo
maarr moveq #0,d1
  bra.s grafmo
mabee moveq #2,d1
grafmo move.w d1,mousf
  graf_mouse
mousf dc.w 3
  dc.l 20000 *not used
  rts    






*Central rutine for param. adress serve etc.
AEScall  move.l (sp),a1  *reta
  move.w (a1)+,d0 *function number, a1 now hold intinadr (or reta)
  lea AESct-5(pc),a3
funsrl addq.l #5,a3
  cmp.b (a3),d0
  bne.s funsrl
  moveq #4,d1
  clr.l d0
  lea contrl(pc),a2
  move.l a2,a0
fuccl move.b (a3)+,d0
  move.w d0,(a2)+
  dbf d1,fuccl  
  
  lea AESPB(pc),a2
  move.l a1,8(a2) *pintin
  move.w 2(a0),d0  *# of intin
  lsl.w #1,d0  
  add.l d0,a1  *adress of addrin
  move.w 6(a0),d0
  beq.s noadrin
  move.l a1,16(a2) *paddrin
  lsl.w #2,d0  *mult by 4
  add.l d0,a1 
noadrin  move.l a1,(sp)  *Skip datas! -prepare retadress
  move.l a2,d1
  move.w #200,d0
  trap #2  *Call AES function
  rts


AESPB dc.l contrl  * pcontrol
pglobal dc.l global
pintin ds.l 1
pintout dc.l intout
paddrin ds.l 1
paddrout dc.l addrout

*Tables with AES control blocks of (only) used functions
AESct *must content all in prg. used functions
  dc.b 10,0,1,0,0  *APPL init
  dc.b 19,0,1,0,0  *APPL exit
  dc.b 21,3,5,0,0  *EVNT button
  dc.b 23,0,1,1,0  *Evnt message
  dc.b 24,2,1,0,0  * Evnt timer  
  dc.b 35,1,1,1,0  *Menu register
  dc.b 42,6,1,1,0  *Objc draw
  dc.b 43,4,1,1,0  *Objc find
  dc.b 44,1,3,1,0  *Objc offset
  dc.b 47,8,1,1,0  *Objc change
  dc.b 50,1,1,1,0  *Form do (dialog)
  dc.b 51,9,1,0,0  *Form dial
  dc.b 52,1,1,1,0  *Form alert
  dc.b 54,0,5,1,0  *Form center
  dc.b 78,1,1,1,0  *Graf mouse
  dc.b 79,0,5,0,0  *Graf mkstate
  dc.b 90,0,2,2,0  *Old Fsel for TOS 1.02 and 1.00
  dc.b 91,0,2,3,0  *Fsel input
  dc.b 107,1,1,0,0 *Wind update
  dc.b 114,1,1,1,0 *RSRC obfix
  dc.b 0
  even


filesel  clr.l buffr 
     


   tst.b oldtos    * Not possible on STE and later !
  bne.s fiselold

  move.l a1,fsmadr

* Here needs released mouse button !

*grafMS   graf_mkstate  
*   move.w   intout+6(pc),d1      * Button pressed ?
*   and.w   #3,d1   * Only 2 bits relevant
*   bne.s    grafMS 

   evnt_button  
   dc.w   0
   dc.w   1
   dc.w   0



  fsel_i  
*  bsr AEScall
*  dc.w 91,0,2,3,0 *Only for new TOS!!!
  dc.l path
  dc.l buffr
fsmadr ds.l 1  
  tst.w intout
  beq.s fisend
  tst.w intout+2
  beq.s fisend
  
fsok  lea buffr+100(pc),a1
  lea path(pc),a0
  bsr.s pdcopy
*Now drop attributes of select
droat 
  subq.l #1,a0
  cmp.b #"\",-(a1)  *is subdir end marker
  bne.s droat
  addq.l #1,a1  *move forward
  lea 2(a0),a2  *store ext (with . ) begin from path

  lea buffr(pc),a0
  tst.b (a0) *check for nothing selected or written
  beq.s fis2
  bra.s pdcopy
  
fisend 
fis2  clr.l buffr+100
  rts


fiselold  *AES 90 for older TOS

  fsel_input
  dc.l path
  dc.l buffr

  tst.w intout
  beq.s fisend
  tst.w intout+2
  beq.s fisend
  bra.s fsok



pdcopy 
  tst.b (a0)
  beq.s pdret 
  move.b (a0)+,(a1)+
  bra.s pdcopy

pdret move.b (a0),(a1)  *For case that longer was there prior
  rts


*Insert extension on path end
*a1 - pointer
putext lea path(pc),a0
searz  tst.b (a0)+
  bne.s searz
*Now search back for \
searbs cmp.b #"\",-(a0)
  bne.s searbs
  addq.l #1,a0

  moveq #5,d1  *copy 4-5 chars and zero term.
initc move.b (a1)+,(a0)+
  dbf d1,initc
  clr.b (a0)
  rts  


*The RSC integrated - ASM source made with RSCTOASM


rsc_obnum   equ   21

* rsc_obs	 dc.w	20	* 21 objects in RSC *

form1	dc.w	-1,1,20
	dc.w	20,0,16		*0*
	dc.l	$21113
dialXpos	dc.w	1,0,40,12

	dc.w	2,-1,-1
	dc.w	22,0,0		*1*
	dc.l	ted1
	dc.w	$304,$300,32,1

	dc.w	3,-1,-1
	dc.w	26,5
	dc.b	0
flag1	dc.b	0		*2*
	dc.l	text1
	dc.w	$401,2,$409,$401

	dc.w	4,-1,-1
	dc.w	26,5
	dc.b	0
flag2	dc.b	0		*3*
	dc.l	text2
	dc.w	$50C,2,$609,$401

	dc.w	5,-1,-1
	dc.w	26,5
	dc.b	0
flag3	dc.b	0		*4*
	dc.l	text3
	dc.w	$617,2,$409,$401

	dc.w	6,-1,-1
	dc.w	26,5
	dc.b	0
flag4	dc.b	0		*5*
	dc.l	text4
	dc.w	$622,$102,4,$201

	dc.w	8,7,7
	dc.w	20,0,0		*6*
	dc.l	$FF1101
	dc.w	$400,$104,39,$600


* Progress bar :

	dc.w	6,-1,-1
	dc.w	20,0,0		*7*
	dc.l	$11D2
	dc.w	$100,$100
progW	dc.w	7,$400   * Will be converted in pix !




	dc.w	9,-1,-1
	dc.w	21,0,0		*8*
	dc.l	ted2
	dc.w	2,$305,$707,$600

	dc.w	10,-1,-1
	dc.w	21,0,0		*9*
	dc.l	ted3
	dc.w	$40A,$305,9,$600

	dc.w	11,-1,-1
	dc.w	21,0,0		*10*
	dc.l	ted4
	dc.w	$614,$305,18,$600

	dc.w	12,-1,-1
	dc.w	26,5
	dc.b	0
flag5	dc.b	0		*11*
	dc.l	text5
	dc.w	$502,$706,$20B,$201

	dc.w	13,-1,-1
	dc.w	26,5
	dc.b	0
flag6	dc.b	0		*12*
	dc.l	text6
	dc.w	$714,7,$410,1

	dc.w	14,-1,-1
	dc.w	22,5
	dc.b	0
flag7	dc.b	0		*13*
	dc.l	ted5
	dc.w	$600,$608,$410,$600

	dc.w	15,-1,-1
	dc.w	21,0,0		*14*
	dc.l	ted6
	dc.w	$615,$708,$205,1

	dc.w	16,-1,-1
	dc.w	26,5
	dc.b	0
flag8	dc.b	0		*15*
	dc.l	text7
	dc.w	$120,$509,$107,$501

	dc.w	17,-1,-1
	dc.w	26,5
	dc.b	0
flag9	dc.b	0		*16*
	dc.l	text8
	dc.w	$612,10,2,$201

	dc.w	18,-1,-1
	dc.w	26,5
	dc.b	0
flag10	dc.b	0		*17*
	dc.l	text9
	dc.w	$21C,10,2,$201

	dc.w	19,-1,-1
*	dc.w	26,5
	dc.w 	26,$0080     * Hidden
	dc.b	0
flag11	dc.b	0		*18*
	dc.l	text10
	dc.w	12,$20A,$302,1

	dc.w	20,-1,-1
	dc.w	21,0,0		*19*
	dc.l	ted7
	dc.w	$315,$20A,6,1

	dc.w	0,-1,-1
	dc.w	21,32,0		*20*
	dc.l	ted8
	dc.w	$700,$60A,$208,1

		* Tedinfo blocks *

ted1	dc.l	text11,null,null
	dc.w	3,6,2,$1180
	dc.w	0,0,28,1

ted2	dc.l	text12,null,null
	dc.w	5,6,0,$1180
	dc.w	0,-1,11,1

ted3	dc.l	text13,null,null
	dc.w	5,6,0,$1180
	dc.w	0,-1,13,1

ted4	dc.l	text14,null,null
	dc.w	5,6,0,$1180
	dc.w	0,-1,25,1

ted5	dc.l	text15,null,null
	dc.w	5,6,2,$1180
	dc.w	0,-1,23,1

ted6	dc.l	text16,null,null
	dc.w	5,6,0,$1180
	dc.w	0,-1,8,1

ted7	dc.l	text17,null,null
	dc.w	3,6,2,$1180
	dc.w	0,-1,7,1

ted8	dc.l	text18,null,null
	dc.w	5,6,0,$1180
	dc.w	0,-1,12,1

		* Text data *

text1	dc.b	'Play file',0
text2	dc.b	'Stop play',0
text3	dc.b	'Play list',0
text4	dc.b	'  ß ',0
text5	dc.b	'Convert WAV',0
text6	dc.b	'Compose playlist',0
text7	dc.b	'EXIT',0
text8	dc.b	'',0
text9	dc.b	'',0
text10	dc.b	'ê',0
text11	dc.b	'STE background audio Player v0.9',0
text12	dc.b	'File info:',0
text13	dc.b	'            ',0
text14	dc.b	'                        ',0
text15	dc.b	'  delete WAV when done',0
text16	dc.b	'Volume:',0
text17	dc.b	'-10 db',0
text18	dc.b	'By PP, 2011',0
null	dc.b	0,0





* Free string / Alert data *

alertFoe	dc.b	'[3][ |Invalid file][OK]',0

alertde	dc.b	'[3][Load error !][Damn!]',0 

alertNoRam   dc.b    '[3][No free RAM|for operation][OK]',0

alertse	dc.b	'[2][Save error !][Check]',0 

alertLsb   dc.b        '[1][|Continue last|list play ?][Yes|No]',0 


   even




initst      dc.b    "*.WAE",0
initstV   dc.b    "*.WAV",0
initLst    dc.b    "*.PLS",0


fsloadm   dc.b "LOAD WAE..",0
fsloadmV dc.b "LOAD WAV..",0
fsloadL    dc.b  "LOAD PLS ..",0  

fsPlFnam   dc.b  "Playlist file",0


   even

steMon   dc.w  0
sampRat  dc.w  0

steMonP   dc.w  0
sampRatP  dc.w  0

sho25k   dc.b  "25033Hz "  
sho50k   dc.b  "50066Hz "

shoMon   dc.b  "Mono  "
shoSte   dc.b  "Stereo"

  







   even

oldtos dc.w 0
errflag ds.w 0

*Put here current drive.... :
path dc.b  "D:\*.*",0,0,0

  even

  SECTION BSS

  ds.b 512  *place for path

excod ds.w 1
menuid ds.w 1

contrl ds.w 5
global ds.l 16  
intout ds.w 7  *max 7
addrout ds.l 2  *max 2
emb ds.w 8  


filelen   ds.l 1
handl   ds.w 1
handlV  ds.w 1
Ohan   ds.w 1
handLst   ds.w 1
oLen   ds.l   1
remLen  ds.l  1
convR    ds.l   1
listLen   ds.l   1
listPo   ds.l   1
listEnd   ds.l  1
listNext   ds.l  1
curDrv    ds.w  1
dtaAdr    ds.l  1

nestBuf   ds.b  40   *

vcontr ds.w 12
vintout ds.w 50
vptsout ds.w 12

buffr ds.b 512
*buffrV ds.b 512

playFiNam  ds.b  180
convFiNam  ds.b  180
listFiNam    ds.b  180
compFiNam   ds.b  180
curPath   ds.b  180

headbuf   ds.b  64

listBuf   ds.b  1024   * Limit load to this !
listCompB   ds.b  1050

buf1    ds.b $10000  *for frame 1
buf2    ds.b $10000  *for frame 2

stack  ds.b 568

stack2  ds.b 768

fin



