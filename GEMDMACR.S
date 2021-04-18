
*GEMDOS macros - simpliest use ,for short programs with few calls.



pterm0  macro
  clr.w -(sp)
  trap #1
  endm
  
  
cconin macro
  move.w #1,-(sp)
  trap #1
  addq.l #2,sp
  endm
  
  
cconout macro
  move.w \1,-(sp)
  move.w #2,-(sp)
  trap #1
  addq.l #4,sp
  endm
  
  
cauxin macro
  move.w #3,-(sp)
  trap #1
  addq.l #2,sp
  endm
  
  
cauxout macro
  move.w \1,,-(sp)
  move.w #4,-(sp)
  trap #1
  addq.l #4,sp
  endm
      
    
cprnout macro
  move.w \1,-(sp)
  move.w #5,-(sp)
  trap #1
  addq.l #4,sp
  endm    
    
    
crawio macro
  move.w \1,-(sp)
  move.w #6,-(sp)
  trap #1
  addq.l #4,sp
  endm      


crawcin macro
  move.w #7,-(sp)
  trap #1
  addq.l #2,sp
  endm 
    
    
cnecin macro
  move.w #8,-(sp)
  trap #1
  addq.l #2,sp
  endm    
      
      
cconws macro
  pea \1
  move.w #9,-(sp)
  trap #1
  addq.l #6,sp
  endm       
     
     
cconrs macro
  pea \1
  move.w #10,-(sp)
  trap #1
  addq.l #6,sp
  endm       
     
     
cconis macro
  move.w #11,-(sp)
  trap #1
  addq.l #2,sp
  endm     
     
     
dsetdrv macro
  move.w \1,-(sp)     
  move.w #14,-(sp)
  trap #1
  addq.l #4,sp
  endm     
     
     
cconos macro
  move.w #16,-(sp)
  trap #1
  addq.l #2,sp
  endm     
     
     
cprnos macro
  move.w #17,-(sp)
  trap #1
  addq.l #2,sp
  endm     
     
     
cauxis macro
  move.w #18,-(sp)
  trap #1
  addq.l #2,sp
  endm     
      
   
cauxos macro
  move.w #19,-(sp)
  trap #1
  addq.l #2,sp
  endm   
      

dgetdrv macro
  move.w #25,-(sp)
  trap #1
  addq.l #2,sp
  endm      
      
      
fsetdta macro
  pea \1
  move.w #26,-(sp)
  trap #1
  addq.l #6,sp
  endm  


super macro
  pea \1
  move.w #32,-(sp)
  trap #1
  addq.l #6,sp
  endm  


tgetdate macro
  move.w #42,-(sp)
  trap #1
  addq.l #2,sp
  endm


tsetdate macro
  move.w \1,-(sp)
  move.w #43,-(sp)
  trap #1
  addq.l #4,sp
  endm


tgettime macro
  move.w #44,-(sp)
  trap #1
  addq.l #2,sp
  endm

      
tsettime macro
  move.w \1,-(sp)
  move.w #45,-(sp)
  trap #1
  addq.l #4,sp
  endm      
      
      
fgetdta macro
  move.w #47,-(sp)
  trap #1
  addq.l #2,sp
  endm      
      
      
sversion macro      
  move.w #48,-(sp)
  trap #1
  addq.l #2,sp
  endm      
      
      
ptermres macro
  move.w \1,-(sp)
  pea \2
  move.w #49,-(sp)
  trap #1
  endm
  
  
dfree macro
  move.w \1,-(sp)
  pea \2
  move.w #54,-(sp)
  trap #1
  addq.l #8,sp
  endm    
  
  
dcreate macro
  pea \1
  move.w #57,-(sp)
  trap #1
  addq.l #6,sp
  endm          
        
        
ddelete macro
  pea \1
  move.w #58,-(sp)
  trap #1
  addq.l #6,sp
  endm        
      
      
dsetpath macro
  pea \1
  move.w #59,-(sp)
  trap #1
  addq.l #6,sp
  endm        
      
      
fcreate macro
  move.w \1,-(sp)
  pea \2
  move.w #60,-(sp)
  trap #1
  addq.l #8,sp
  endm        
      
      
fopen macro
  move.w \1,-(sp)
  pea \2
  move.w #61,-(sp)
  trap #1
  addq.l #8,sp
  endm     
      
      
fclose macro
  move.w \1,-(sp)
  move.w #62,-(sp)
  trap #1
  addq.l #4,sp
  endm      
      
      
fread macro
  pea \1
  pea \2
  move.w \3,-(sp)
  move.w #63,-(sp)
  trap #1
  lea 12(sp),sp
  endm      
      
      
fwrite macro
  pea \1
  pea \2
  move.w \3,-(sp)
  move.w #64,-(sp)
  trap #1
  lea 12(sp),sp
  endm      
      
      
fdelete macro
  pea \1
  move.w #65,-(sp)
  trap #1
  addq.l #6,sp
  endm
  
  
fseek macro
  move.w \1,-(sp)
  move.w \2,-(sp)
  pea \3
  move.w #66,-(sp)
  trap #1
  lea 10(sp),sp
  endm
  
  
fattrib macro
  move.w \1,-(sp)
  move.w \2,-(sp)
  pea \3
  move.w #67,-(sp)
  trap #1
  lea 10(sp),sp
  endm
            
      
fdup macro
  move.w \1,-(sp)
  move.w #69,-(sp)
  trap #1
  addq.l #4,sp
  endm
  
        
fforce macro         
  move.w \1,-(sp)
  move.w \2,-(sp)
  move.w #70,-(sp)
  trap #1
  addq.l #6,sp
  endm
        
        
dgetpath macro
  move.w \1,-(sp)
  pea \2
  move.w #71,-(sp)
  trap #1
  addq.l #8,sp
  endm
        
        
malloc macro
  pea \1
  move.w #72,-(sp)
  trap #1
  addq.l #6,sp
  endm
        
        
mfree macro
  pea \1
  move.w #73,-(sp)
  trap #1
  addq.l #6,sp
  endm
        
        
mshrink macro
  pea \1
  pea \2
  clr.w -(sp)
  move.w #74,-(sp)
  trap #1
  lea 12(sp),sp
  endm
  
  
pexec macro
  pea \1
  pea \2
  pea \3
  move.w \4,-(sp)
  move.w #75,-(sp)
  trap #1
  lea 16(sp),sp
  endm
  
  
pterm macro
  move.w \1,-(sp)
  move.w #76,-(sp)
  trap #1
  endm
  
  
fsfirst macro
  move.w \1,-(sp)
  pea \2
  move.w #78,-(sp)
  trap #1
  addq.l #8,sp
  endm
  
  
fsnext macro
  move.w #79,-(sp)
  trap #1
  addq.l #2,sp
  endm
  
  
frename macro
  pea \1
  pea \2
  clr.w -(sp)
  move.w #86,-(sp)
  trap #1
  lea 12(sp),sp
  endm
  
  
fdatime macro
  move.w \1,-(sp)
  move.w \2,-(sp)
  pea \3
  move.w #87,-(sp)
  trap #1
  lea 10(sp),sp
  endm
  
  
  
          


      
  
          
          
          
        
        
        
        
      
      
      
      