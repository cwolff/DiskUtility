Name               DISKERR

Title              Disk_Utility

Subttl             Disk_Error

Page 60,132

; **************************************************************************
; |                                                                        |
; |                 (C)opyright 1983 Software Laboratories Inc.            |
; |                                                                        |
; |                 Author Cameron L. Wolff                                |
; |                                                                        |
; **************************************************************************

;
; *** Code segment
;

Code_seg        segment public 'code'

                assume  cs:code_seg

;
; *** Include
;

                Include c:diskdata.inc

;
; *** Externals
;

                extrn display_message:near,clear_window:near,return_key:near

                extrn status_message_pointer:word

;
; *** Public
;

                public disk_io_error

Page

Drive_not_ready_message   db  58,' Drive NOT Ready -- Please Fix -- Depress '
                          db     11h,0c4h,0d9h,' to Continue '

Seek_failed_message       db  40,' Seek Failed -- Depress ',11h,0c4h,0d9h
                          db     ' to Continue '

Nec_failed_message        db  47,' NEC Controller Bad -- Depress '
                          db     11h,0c4h,0d9h,' to Continue '

Crc_data_error_message    db  52,' CRC Error in Data Field -- Depress '
                          db      11h,0c4h,0d9h,' to Continue '

Crc_id_error_message      db  50,' CRC Error in ID Field -- Depress '
                          db     11h,0c4h,0d9h,' to Continue '

Dma_boundry_error_message db  46,' DMA Boundry Error -- Depress '
                          db     11h,0c4h,0d9h,' to Continue '

Dma_overrun_error_message db  46,' DMA Overrun Error -- Depress '
                          db     11h,0c4h,0d9h,' to Continue '

Sector_not_found_message  db  45,' Sector NOT Found -- Depress '
                          db     11h,0c4h,0d9h,' to Continue '

Diskette_write_prot_message db 67,' Diskette Write Protected -- Please '
                            db    'Fix -- Depress ',11h,0c4h,0d9h
                            db    ' to Continue '

Track_not_formatted_message db 48,' Track NOT Formatted -- Depress '
                            db    11h,0c4h,0d9h,' to Continue '

Bad_command_message         db 40,' Bad Command -- Depress '
                            db    11h,0c4h,0d9h,' to Continue '

Page

; -------------------------------------------------------------------------
; |                                                                       |
; |                             DISK_IO_ERROR                             |
; |                                                                       |
; |               Display disk error for read operation                   |
; |                                                                       |
; |                                                                       |
; |       Input:                                                          |
; |              AH - error value                                         |
; |              80 = attachment failed to responed                       |
; |              40 = seek operation failed                               |
; |              20 = NEC controller failed                               |
; |              10 = bad CRC on disk read                                |
; |              09 = attempt to DMA across 64k boundry                   |
; |              08 = DMA overrun on operation                            |
; |              04 = requested sector not found                          |
; |              03 = write attempted on write protected disk             |
; |              02 = address mark not found                              |
; |              01 = bad command to disk I/O                             |
; |                                                                       |
; |        Output:                                                        |
; |                CY - 0 go on to next sector                            |
; |                CY - 1 retry same sector                               |
; |                                                                       |
; -------------------------------------------------------------------------

Disk_io_error   proc    near

                push    ax
                push    bx
                push    cx
                push    dx
                push    ds
                push    es

                push    cs
                push    cs

                pop     ds
                pop     es

                push    status_message_pointer

        Not_ready_error:

                test    ah,80h
                jz      seek_failed_error

                mov     cx,offset drive_not_ready_message

                stc

                jmp     display_disk_error

        Seek_failed_error:        

                test    ah,40h
                jz      nec_failure_error

                mov     cx,offset seek_failed_message

                clc

                jmp     display_disk_error

        Nec_failure_error:

                test    ah,20h
                jz      crc_error

                mov     cx,offset nec_failed_message

                clc

                jmp     display_disk_error

        Crc_error:

                test    ah,10h
                jz      dma_boundry_error

;
; *** Crc error determine if in ID field or DATA field
;

                push    ds

                mov     dx,40h
                mov     ds,dx

                mov     bx,nec_status

                mov     dl,[bx+2]

                pop     ds

                test    dl,00100000b
                jz      crc_id_error

        Crc_data_error:

                mov     cx,offset crc_data_error_message

                clc

                jmp     display_disk_error

        Crc_id_error:

                mov     cx,offset crc_id_error_message

                clc

                jmp     display_disk_error

        Dma_boundry_error:

                test    ah,10h
                jz      dma_overrun_error

                mov     cx,offset dma_boundry_error_message

                clc

                jmp     display_disk_error

        Dma_overrun_error:

                cmp     ah,09h
                jne     sector_not_found_error

                mov     cx,offset dma_overrun_error_message

                clc

                jmp     display_disk_error

        Sector_not_found_error:

                test    ah,04
                jz      diskette_write_protected_error

                mov     cx,offset sector_not_found_message

                clc

                jmp     display_disk_error

        Diskette_write_protected_error:

                cmp     ah,03h
                jne     track_not_formatted_error

                mov     cx,offset diskette_write_prot_message

                stc

                jmp     display_disk_error

        Track_not_formatted_error:

                test    ah,02h
                jz      bad_command_error

                mov     cx,offset track_not_formatted_message

                clc

                jmp     display_disk_error

        Bad_command_error:

                mov     cx,offset bad_command_message

                clc

        Display_disk_error:

                pushf

;
; *** Clear status line
;

                push    cx

                mov     cx,1800h
                mov     dx,184fh
                mov     bh,normal_video
                call    clear_window

                pop     cx

;
; *** Display message
;

                mov     status_message_pointer,cx

                mov     bl,reverse_video
                mov     dx,18ffh
                call    display_message

;
; *** Get return key
;

                call    return_key

                popf

                pop     status_message_pointer

                pushf

;
; *** Clear status line
;

                 mov    cx,1800h
                 mov    dx,184fh
                 mov    bh,normal_video
                 call   clear_window

;
; *** Check to see if there is a status message to display
;

                 cmp    status_message_pointer,0ffffh
                 je     disk_io_error_return

;
; *** Display esc_menu_message
;

                 mov    bl,reverse_video
                 mov    cx,status_message_pointer
                 mov    dx,18ffh
                 call   display_message

;
; *** Return to caller
;

        Disk_io_error_return:

                 popf

                 pop    es
                 pop    ds
                 pop    dx
                 pop    cx
                 pop    bx
                 pop    ax

                 ret

Disk_io_error    endp

Code_seg         ends

                 end     eDs_oerr  np

oesg    ed         n  esor n
os  e      o 
s    s s ss   o  c         o  b         o  a                ÿ¶¶          ~ ÿ¶¶        