Name           DISKLOOK

Title          Drive_Utility

Subttl         Drive_Look

Page           60,132

; *************************************************************************
; *                                                                       *
; *           (C)opyright 1983 Software Laboratories Inc.                 *
; *                                                                       *
; *                Author - Cameron L. Wolff                              *
; *                                                                       *
; *************************************************************************

Code_seg       segment  public 'code'

               assume   cs:code_seg

;
; *** Include
;

               include  c:diskdata.inc

;
; *** Externals
;

               extrn source_drive:byte
               extrn track_number:byte
               extrn old_track_number:byte
               extrn head_number:byte

               extrn disk_io_error:near
               extrn start_disk_prompt:near
               extrn side_display:near
               extrn display_source_prompt:near
               extrn display_current_track:near
               extrn operation_display:near
               extrn check_esc_key:near

;
; *** Public
;

                        public  disk_look

Page

Retry           db      00h

Sector_count    db      00h

Column_count    db      00h                ; column counter

Line_count      db      00h                ; line count

Track_nf_message db    22,'Track '
Track_nf_number  db    00,00,' NOT Formatted'

Side_1_message   db    36,09h,09h,09h,09h,' --- *** --- Side 0 --- *** --- '

Side_2_message   db    36,09h,09h,09h,09h,' --- *** --- Side 1 --- *** --- '

The_end_message  db    37,09h,09h,09h,09h,' --- *** --- The End --- *** --- '

Sectors_on_track_pointer       dw    0000h

Sectors_on_track               db    401 dup (' ')

Print_sectors_pointer           dw    0000h

Print_sectors                   db    401 dup (' ')

Disk_message      db     24,'Printing Sectors of Disk'

Page

; -------------------------------------------------------------------------
; |                                                                       |
; |                            DISK LOOK                                  |
; |                                                                       |
; -------------------------------------------------------------------------

Disk_look       proc    near

                mov     track_number,0
                mov     old_track_number,0

                call    start_disk_prompt

                call    display_source_prompt

                mov     cx,offset disk_message
                call    operation_display

;
; *** Begin
;

                mov     al,0dh
                call    print_out

                mov     al,0ch
                call    print_out

;
; *** Print side 1 message
;

                xor     ch,ch
                mov     cl,side_1_message
                mov     bx,offset side_1_message
                inc     bx

        Side_1_loop:

                mov     al,[bx]
                call    print_out

                inc     bx
                loop    side_1_loop

                mov     al,0dh
                call    print_out

                mov     cx,3

        Side_1_lf_loop:

                mov     al,0ah
                call    print_out

                loop    side_1_lf_loop

                mov     al,0dh
                call    print_out

;
; *** Print side 1
;

                mov     head_number,0
                call    read_id

                mov     al,0ch
                call    print_out

;
; *** Print side 2 message
;

                xor     ch,ch
                mov     cl,side_2_message
                mov     bx,offset side_2_message
                inc     bx

        Side_2_loop:

                mov     al,[bx]
                call    print_out

                inc     bx
                loop    side_2_loop

                mov     al,0dh
                call    print_out

                mov     cx,3

        Side_2_lf_loop:

                mov     al,0ah
                call    print_out

                loop    side_2_lf_loop

                mov     al,0dh
                call    print_out

;
; *** Print side 2
;

                mov     head_number,01h
                call    read_id

;
; *** Print the end message
;

                mov     al,0ah
                call    print_out

                mov     al,0dh
                call    print_out

                xor     ch,ch
                mov     cl,the_end_message
                mov     bx,offset the_end_message
                inc     bx

        The_end_loop:

                mov     al,[bx]
                call    print_out

                inc     bx
                loop    the_end_loop

                mov     al,0ch
                call    print_out

                mov     al,0dh
                call    print_out

                ret

Disk_look       endp

Page

; -------------------------------------------------------------------------
; |                                                                       |
; |                             READ ID                                   |
; |                                                                       |
; -------------------------------------------------------------------------

Read_id         proc    near

                call    side_display

                mov     track_number,0

        Read_next_track:

                call    check_esc_key

                call    display_current_track

                call    track_look

                jnc     display_sectors

                call    track_not_formatted

                jmp     look_at_next_track

        Display_sectors:

                call    order_sectors

                call    print_format

        Look_at_next_track:

                inc     track_number
                cmp     track_number,40
                je      the_end

                jmp     read_next_track

        The_end:

                ret

Read_id         endp

Page

; =========================================================================
; |                                                                       |
; |                          TRACK LOOK                                   |
; |                                                                       |
; =========================================================================

Track_look      proc    near

                push    ds
                push    es

                push    cs
                push    cs
                pop     es
                pop     ds

        Disk_look_error_loop:

                call    clear_buffers

                mov     retry,3

;
; *** Read the current track in order to position disk for
;

        Read_track:

                mov     ah,7
                mov     al,1
                mov     ch,track_number
                mov     cl,1
                mov     dh,head_number
                mov     dl,source_drive
                mov     bx,0

                int     13h

                jnc     read_id_loop

                push    ax

                mov     ax,0
                int     13h

                pop     ax

                cmp     ah,02h
                je      damaged_track_or_not_formated

                call    disk_io_error

                jnc     disk_look_return

                jmp     disk_look_error_loop

        Damaged_track_or_not_formated:

                stc

                jmp     disk_look_return

        Read_track_error:

                call    disk_io_error

                jmp     disk_look_error_loop

        Read_id_loop:

                mov     ah,6
                mov     al,1
                mov     ch,track_number
                mov     cl,1
                mov     dh,head_number
                mov     dl,source_drive
                mov     bx,0

                int     13h

                jnc     get_sector_id

                push    ax

                mov     ah,0
                int     13h

                pop     ax

                call    disk_io_error

                jnc     disk_look_return

                jmp     disk_look_error_loop

        Get_sector_id:

                push    ds

                mov     ax,40h
                mov     ds,ax

                inc     sector_count

                mov     cx,4
                mov     si,nec_status+3
                mov     di,sectors_on_track_pointer

                rep     movsb

                pop     ds

                mov     sectors_on_track_pointer,di

                cmp     sector_count,1
                je      first_pass        ; first time through dont check

                mov     al,sectors_on_track[3]
                cmp     es:[di-2],al
                je      read_all_sectors

                cmp     sector_count,100
                jae     read_all_sectors

        First_pass:

                jmp     read_id_loop

        Read_all_sectors:

                mov     al,sector_count
                dec     al
                mov     sectors_on_track,al

                clc

        Disk_look_return:

                pop     es
                pop     ds

                ret

Track_look      endp

Page

; -------------------------------------------------------------------------
; |                                                                       |
; |                            CLEAR BUFFERS                              |
; |                                                                       |
; -------------------------------------------------------------------------

Clear_buffers   proc    near

                mov     sector_count,0

                mov     ax,offset sectors_on_track
                inc     ax
                mov     sectors_on_track_pointer,ax

                mov     cx,401
                mov     di,offset sectors_on_track
                mov     al,0

                rep     stosb

                mov     cx,401
                mov     di,offset print_sectors
                mov     al,0

                rep     stosb

                ret

Clear_buffers   endp

Page

; =========================================================================
; |                                                                       |
; |                             ORDER SECTORS                             |
; |                                                                       |
; =========================================================================

Order_sectors  proc     near

               push     ds
               push     es

               push     cs
               push     cs
               pop      ds
               pop      es

               xor      ax,ax

               mov      si,offset sectors_on_track
               mov      al,cs:[si]
               inc      si

               mov      di,offset print_sectors
               mov      cs:[di],al
               add      di,5

               dec      al
               jz       only_one_sector

               mov      cl,2
               shl      ax,cl
               mov      cx,ax

               rep      movsb

        Only_one_sector:

               mov      cx,4
               mov      di,offset print_sectors
               inc      di

               rep      movsb

               pop      es
               pop      ds

               ret

Order_sectors  endp

Page

; -------------------------------------------------------------------------
; |                                                                       |
; |                         TRACK NOT FORMATTED                           |
; |                                                                       |
; -------------------------------------------------------------------------

Track_not_formatted proc near

                push    ax
                push    bx
                push    cx

                mov     al,0ah
                call    print_out

                mov     al,0dh
                call    print_out

                mov     al,track_number
                call    convert_hex

                mov     bx,offset track_nf_number

                mov     [bx],ah
                mov     [bx+1],al

                xor     ch,ch
                mov     cl,track_nf_message

                mov     bx,offset track_nf_message
                inc     bx

        Print_nf_loop:

                mov     al,[bx]
                inc     bx
                call    print_out

                loop    print_nf_loop

                mov     al,0ah
                call    print_out

                mov     al,0dh
                call    print_out

        Tnf_return:

                pop     cx
                pop     bx
                pop     ax

                ret

Track_not_formatted endp

Page

; ------------------------------------------------------------------------
; |                                                                      |
; |                            PRINT FORMAT                              |
; |                                                                      |
; |        Print 7 status byte as they come back from the NEC            |
; |                                                                      |
; |                                                                      |
; ------------------------------------------------------------------------

Print_format    proc    near

                push    ax
                push    bx
                push    cx

                mov     al,0ah
                call    print_out

                mov     al,0dh
                call    print_out

                mov     bx,offset print_sectors
                mov     al,[bx]
                inc     bx

        Next_sector:

                push    ax

                mov     cx,4

        Print_loop:

                mov     al,[bx]
                inc     bx
                call    convert_hex

                push    ax

                mov     al,ah

                call    print_out

                pop     ax

                call    print_out

                mov     al,20h
                call    print_out

                mov     al,20h
                call    print_out

                loop    print_loop

                mov     al,20h
                call    print_out
 
                mov     al,20h
                call    print_out

                pop     ax

                dec     al
                jnz     next_sector

;
; *** Cr Line feed
;

                mov     al,0ah
                call    print_out

                mov     al,0dh
                call    print_out

        Print_return:

                pop     cx
                pop     bx
                pop     ax

                ret

Print_format    endp

Page

; -------------------------------------------------------------------------
; |                                                                       |
; |                             CONVERT HEX                               |
; |                                                                       |
; |       Input  AL - number to convert to assci hex                      |
; |                                                                       |
; |       Output AH,AL converted number                                   |
; |                                                                       |
; -------------------------------------------------------------------------

Convert_hex     proc    near

                push    cx

                mov     ch,al

                and     al,0f0h
                mov     cl,4
                shr     al,cl
                cmp     al,0ah
                jge     alpha_1st
                add     al,30h
                jmp     save_1st

        Alpha_1st:

                add     al,37h

        Save_1st:

                mov     ah,al

                mov     al,ch
                and     al,0fh
                cmp     al,0ah
                jge     alpha_2nd
                add     al,30h
                jmp     save_2nd

        Alpha_2nd:

                add     al,37h

        Save_2nd:

                pop      cx

                ret

Convert_hex     endp

Page

; -------------------------------------------------------------------------
; |                                                                       |
; |                             PRINT OUT                                 |
; |                                                                       |
; |          Input                                                        |
; |                al - character to output                               |
; |                                                                       |
; -------------------------------------------------------------------------

Print_out       proc    near

                push    ax
                push    cx
                push    dx

                mov     cl,al

                cmp     cl,0ah
                jnz     check_cr
                inc     line_count
                jmp     print_1

        Check_cr:

                cmp     cl,0dh
                jnz     check_ff
                mov     column_count,0ffh

        Check_ff:

                cmp     cl,0ch
                jnz     print_1
                mov     line_count,0
                mov     column_count,0ffh
 
        Print_1:

                mov     ah,print
                mov     dl,cl
                int     21h

; Check if time for line feed

                inc     column_count

                mov     al,column_count
                cmp     al,108
                jb      check_form_feed

                mov     column_count,0
                mov     ah,print
                mov     dl,0ah
                int     21h

                mov     ah,print
                mov     dl,0dh
                int     21h
                inc     line_count

; Check if time for form feed

        Check_form_feed:

                cmp     line_count,60
                jb      print_out_return

                mov     line_count,0
                mov     ah,print
                mov     dl,0ch
                int     21h

        Print_out_return:

                pop     dx
                pop     cx
                pop     ax

                ret

Print_out       endp

Code_seg        ends

                end
   l