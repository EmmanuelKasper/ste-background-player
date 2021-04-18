  
  
  *AES functions macros for AEScall2
  
  
appl_init macro
  bsr AEScall
  dc.w  10
  endm
appl_read macro
  bsr AEScall
  dc.w 11
  endm
appl_write macro
  bsr AEScall
  dc.w 12
  endm
appl_find macro
  bsr AEScall
  dc.w 13
  endm
appl_tplay macro
  bsr AEScall
  dc.w 14
  endm
appl_trecord macro
  bsr AEScall
  dc.w 15
  endm
appl_exit macro
  bsr AEScall
  dc.w 19
  endm

evnt_keybd macro
  bsr AEScall
  dc.w 20
  endm
evnt_button macro
  bsr AEScall
  dc.w 21
  endm
evnt_mouse macro
  bsr AEScall
  dc.w 22
  endm
evnt_mesag macro
  bsr AEScall
  dc.w 23
  endm
evnt_timer macro
  bsr AEScall
  dc.w 24
  endm
evnt_multi macro
  bsr AEScall
  dc.w 25
  endm
evnt_dclick macro
  bsr AEScall
  dc.w 26
  endm

menu_bar macro
  bsr AEScall
  dc.w 30
  endm
menu_icheck macro
  bsr AEScall
  dc.w 31
  endm
menu_ienable macro
  bsr AEScall
  dc.w 32
  endm
menu_tnormal macro
  bsr AEScall
  dc.w 33
  endm
menu_text macro
  bsr AEScall
  dc.w 34
  endm
menu_register macro
  bsr AEScall
  dc.w 35
  endm
  
objc_add macro
  bsr AEScall
  dc.w 40
  endm
objc_delete macro
  bsr AEScall
  dc.w 41
  endm
objc_draw macro
  bsr AEScall
  dc.w 42
  endm
objc_find macro
  bsr AEScall
  dc.w 43
  endm
objc_offset macro
  bsr AEScall
  dc.w 44
  endm
objc_order macro
  bsr AEScall
  dc.w 45
  endm
objc_edit macro
  bsr AEScall
  dc.w 46
  endm
objc_change macro
  bsr AEScall
  dc.w 47
  endm
  
form_do macro
  bsr AEScall
  dc.w 50
  endm
form_dial macro
  bsr AEScall
  dc.w 51
  endm
form_alert macro
  bsr AEScall
  dc.w 52
  endm
form_error macro
  bsr AEScall
  dc.w 53
  endm
form_center macro
  bsr AEScall
  dc.w 54
  endm
form_keybd macro
  bsr AEScall
  dc.w 55
  endm
form_button macro
  bsr AEScall
  dc.w 56
  endm
  
graf_rubberbox macro
  bsr AEScall
  dc.w 70
  endm
graf_dragbox macro
  bsr AEScall
  dc.w 71
  endm
graf_movebox macro
  bsr AEScall
  dc.w 72
  endm
graf_growbox macro
  bsr AEScall
  dc.w 73
  endm
graf_shrinkbox macro
  bsr AEScall
  dc.w 74
  endm
graf_watchbox macro
  bsr AEScall
  dc.w 75
  endm
graf_slidebox macro
  bsr AEScall
  dc.w 76
  endm
graf_handle macro
  bsr AEScall
  dc.w 77
  endm
graf_mouse macro
  bsr AEScall
  dc.w 78
  endm
graf_mkstate macro
  bsr AEScall
  dc.w 79
  endm
  
scrp_read macro
  bsr AEScall
  dc.w 80
  endm
scrp_write macro
  bsr AEScall
  dc.w 81
  endm
  
fsel_input macro
  bsr AEScall
  dc.w 90
  endm
fsel_i macro
  bsr AEScall
  dc.w 91  *For new TOS!
  endm
  
wind_create macro
  bsr AEScall
  dc.w 100
  endm
wind_open macro
  bsr AEScall
  dc.w 101
  endm
wind_close macro
  bsr AEScall
  dc.w 102
  endm
wind_delete macro
  bsr AEScall
  dc.w 103
  endm
wind_get macro
  bsr AEScall
  dc.w 104
  endm
wind_set macro
  bsr AEScall
  dc.w 105
  endm
wind_find macro
  bsr AEScall
  dc.w 106
  endm
wind_update macro
  bsr AEScall
  dc.w 107
  endm
wind_calc macro
  bsr AEScall
  dc.w 108
  endm

rsrc_load macro
  bsr AEScall
  dc.w 110
  endm
rsrc_free macro
  bsr AEScall
  dc.w 111
  endm
rsrc_gaddr macro
  bsr AEScall
  dc.w 112
  endm
rsre_saddr macro
  bsr AEScall
  dc.w 113
  endm
rsrc_obfix macro
  bsr AEScall
  dc.w 114
  endm

shel_read macro
  bsr AEScall
  dc.w 120
  endm
shel_write macro
  bsr AEScall
  dc.w 121
  endm
shel_get macro
  bsr AEScall
  dc.w 122
  endm
shel_put macro
  bsr AEScall
  dc.w 123
  endm
shel_find macro
  bsr AEScall
  dc.w 124
  endm
shel_envrn macro
  bsr AEScall
  dc.w 125
  endm
  
  
  
  
                                                                           
              
                    
  
  
  