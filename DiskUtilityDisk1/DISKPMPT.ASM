Name             DISKPMPT

Title            Disk_Utility

Subttl           Disk_Prompt

Page 60,132

; **************************************************************************
; *                                                                        *
; *              (C)opyright 1983 Software Laboratories Inc.               *
; *                                                                        *
; *                  Author Cameron L. Wolff                               *
; *                                                                        *
; **************************************************************************

;
; *** Code segment
;

Code_seg        segment public 'code'

                assume cs:code_seg

;
; *** Include file
;

                Include c:diskdata.inc

;
; *** External
;

                extrn   display_message:near,clear_window:near
                extrn   return_key:near,clear_box:near,check_esc_key:near

                extrn   status_message_pointer:word
                extrn   target_drive:byte
                extrn   source_drive:byte

;
; *** Public
;

                public  start_disk_prompt
                public  display_source_prompt
                public  operation_display
                public  display_current_track
                public  modulos_10_byte
                public  side_0_message
                public  side_1_message
                public  track_number
                public  old_track_number
                public  head_number

Page

;
; *** Variables
;

Modulos_10_byte                 db    0ah
Track_number                    db    00h
Old_track_number                db    00h
Mult_three                      db    03h

Head_number                     db    00h

;
; *** Messages
;

Current_disk_message            db    12,'Current Disk'

Source_diskette_message         db    17,' Source Diskette '
Target_diskette_message         db    17,' Target Diskette '

Source_drive_message            db    15,'Source Drive '
Source_drive_number_message     db       'A:'

Target_disk_message             db    15,'Target Drive '
Target_disk_number_message      db       'B:'

Current_side_message            db    12,'Current Side'

Side_0_message              db    08h,' Side 0 '
Side_1_message              db    08h,' Side 1 '

Current_track_message       db    59
                            db    22 dup (196)
                            db    ' Current Track '
                            db    22 dup (196)

Row_1_message db 59
              db '00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19'

Row_2_message db  59
              db '20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39'


Insert_source_message  db  41,'Insert Source Diskette in Source Drive '
Insert_source_number_message  db  ' :'

Insert_target_message  db  41,'Insert Target Diskette in Target Drive '
Insert_target_number_message  db  ' :'

Esc_menu_message       db  21,' Depress ESC to Stop '
Return_message         db  22,'Depress ',11h,0c4h,0d9h,' When Ready'

Current_track_number_message  db  4,221,'  ',222
Old_track_number_message      db  4,'    '

Page

; ==========================================================================
; |                                                                        |
; |                           START DISK PROMPT                             |
; |                                                                        |
; |        Clear screen and generates starting prompt if source drive      |
; |        and target drive are not the same.                              |
; |                                                                        |
; ==========================================================================

Start_disk_prompt proc  near

                push    ds
                push    es

                push    cs
                push    cs

                pop     ds
                pop     es

;
; *** Check ESC key
;

                call    check_esc_key

;
; *** Call clear window
;
                mov     bh,normal_video
                mov     cx,0300h
                mov     dx,094fh
                call    clear_window

;
; *** Generate display in box
;

                call    clear_box

;
; *** Current disk messages
;
                mov     bl,normal_video
                mov     cx,offset current_disk_message
                mov     dx,current_disk_position
                call    display_message

                mov     bl,normal_video
                mov     cx,offset source_diskette_message
                mov     dx,source_diskette_position
                call    display_message

                mov     bl,normal_video
                mov     cx,offset target_diskette_message
                mov     dx,target_diskette_position
                call    display_message

;
; *** Current side message
;

                mov     bl,normal_video
                mov     cx,offset current_side_message
                mov     dx,current_side_position
                call    display_message

                mov     bl,normal_video
                mov     cx,offset side_0_message
                mov     dx,side_0_position
                call    display_message

                mov     bl,normal_video
                mov     cx,offset side_1_message
                mov     dx,side_1_position
                call    display_message

;                
; *** Current track messages
;

                mov     bl,normal_video
                mov     cx,offset current_track_message
                mov     dx,current_track_position
                call    display_message

                mov     bl,normal_video
                mov     cx,offset row_1_message
                mov     dx,row_1_position
                call    display_message

                mov     bl,normal_video
                mov     cx,offset row_2_message
                mov     dx,row_2_position
                call    display_message

                mov     bl,reverse_video
                mov     cx,offset esc_menu_message

                mov     status_message_pointer,cx

                mov     dx,18ffh
                call    display_message

;
; *** Determine if two disk drive prompt is to be given
;

                mov     ah,target_drive
                cmp     ah,source_drive
                je      start_copy_prompt_return

;
; *** Give two drive prompt
;

                mov     al,source_drive
                add     al,'A'
                mov     insert_source_number_message,al

                mov     bl,normal_video
                mov     cx,offset insert_source_message
                mov     dx,04ffh
                call    display_message

                mov     al,target_drive
                add     al,'A'
                mov     insert_target_number_message,al

                mov     bl,normal_video
                mov     cx,offset insert_target_message
                mov     dx,06ffh
                call    display_message

                mov     bl,normal_video
                mov     cx,offset return_message
                mov     dx,08ffh
                call    display_message

                call    return_key

;
; *** Start copy prompt return
;

        Start_copy_prompt_return:

                pop     es
                pop     ds

                ret

Start_disk_prompt endp

Page

; =========================================================================
; |                                                                       |
; |                     DISPLAY SOURCE PROMPT                             |
; |                                                                       |
; =========================================================================

Display_source_prompt proc near

                push    ds
                push    es

                push    cs
                push    cs

                pop     ds
                pop     es

;
; *** Check if ESC key been hit
;

                call    check_esc_key

;
; *** Clear Window
;

                mov     bh,normal_video
                mov     cx,0300h
                mov     dx,094fh
                call    clear_window

;
; *** Determine if a source prompt is necessary
;

                mov     ah,source_drive
                cmp     ah,target_drive
                jne     source_display

                mov     ah,source_drive
                add     ah,'A'
                mov     insert_source_number_message,ah

                mov     bl,normal_video
                mov     cx,offset insert_source_message
                mov     dx,05ffh
                call    display_message

                mov     bl,normal_video
                mov     cx,offset return_message
                mov     dx,07ffh
                call    display_message

                call    return_key

;
; *** Update current disk display
;

        Source_display:

                mov     bl,reverse_video
                mov     cx,offset source_diskette_message
                mov     dx,source_diskette_position
                call    display_message

                mov     bl,normal_video
                mov     cx,offset target_diskette_message
                mov     dx,target_diskette_position
                call    display_message

        Display_source_prompt_return:
 
                pop     es
                pop     ds

                ret

Display_source_prompt endp

Page

; =========================================================================
; |                                                                       |
; |                               OPERATION DISPLAY                       |
; |                                                                       |
; |             Input:                                                    |
; |                                                                       |
; |                   CX - address of message to display                  |
; |                                                                       |
; =========================================================================

Operation_display proc near

                push    ds
                push    es

                push    cs
                push    cs

                pop     ds
                pop     es

;
; *** Check for ESC key
;

                call    check_esc_key

;
; *** Clear window
;

                push    cx

                mov     bh,normal_video
                mov     cx,0300h
                mov     dx,094fh
                call    clear_window

                pop     cx

                mov     bl,normal_video
                mov     dx,04ffh
                call    display_message

                pop     es
                pop     ds

                ret

Operation_display endp

Page

; -------------------------------------------------------------------------
; |                                                                       |
; |                         DISPLAY CURRENT TRACK                         |
; |                                                                       |
; -------------------------------------------------------------------------

Display_current_track proc near

                mov     bx,offset current_track_number_message

                mov     al,track_number

                cbw

                div     modulos_10_byte

                add     ah,'0'
                mov     [bx+3],ah
                add     al,'0'
                mov     [bx+2],al

;
; *** Calculate old track message
;

                mov     bx,offset old_track_number_message

                mov     al,old_track_number

                cbw

                div     modulos_10_byte

                add     ah,'0'
                mov     [bx+3],ah
                add     al,'0'
                mov     [bx+2],al

;
; *** Display old track first (normal video)
;

        Old_track_display:

                cmp     old_track_number,19
                ja      second_row_old

                mov     al,old_track_number
                mov     dx,120ah
                jmp     track_output_old

        Second_row_old:

                mov     ah,20
                mov     al,old_track_number
                sub     al,ah
                mov     dx,140ah

        Track_output_old:

                push    dx

                cbw

                mul     mult_three

                pop     dx

                add     dx,ax

                mov     bl,normal_video
                mov     cx,offset old_track_number_message
                dec     dl
                call    display_message

;
; *** Display current track (reverse video)
;

        Current_track_display:

                cmp     track_number,19
                ja      second_row_current

                mov     al,track_number
                mov     dx,120ah
                jmp     track_output_current

        Second_row_current:

                mov     ah,20
                mov     al,track_number
                sub     al,ah
                mov     dx,140ah

        Track_output_current:

                push    dx

                cbw

                mul     mult_three

                pop     dx

                add     dx,ax

                mov     bl,reverse_video
                mov     cx,offset current_track_number_message
                dec     dl
                call    display_message

                mov     al,track_number
                mov     old_track_number,al

                ret

Display_current_track endp

Code_seg        ends

                end
   ltaknme        mv  odtaknme,l

        eDslycrettakedCd_e    ed        ed
  tk