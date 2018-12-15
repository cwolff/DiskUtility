.Xlist

; *************************************************************************
; |                                                                       |
; |              (C)opyright 1983 Software Laboratories Inc.              |
; |                                                                       |
; |                   Author - Cameron L. Wolff                           |
; |                                                                       |
; *************************************************************************

;
; Equate
;

Esc_key_addr              equ    100h      ; Escape key addres

Video_int                 equ    10h       ; Video interrupt
Equip_det_int             equ    11h       ; Equipment Determination int
Drive_mask                equ    0c0h      ; Mask out drive config bytes
Prompt_line               equ    14ffh     ; Prompt line

F1                        equ    3bh       ; Function key 1
F2                        equ    3ch       ; Function key 2
F3                        equ    3dh       ; Function key 3
Esc                       equ    01h       ; Esc key
Left_arrow                equ    4bh       ; Left arrow key
Right_arrow               equ    4dh       ; Right arrow key
Up_arrow                  equ    48h       ; Up arrow key
Down_arrow                equ    50h       ; Down arrow key
Return                    equ    1ch       ; Return key

Normal_video              equ    07h       ; Normal video
Reverse_video             equ    70h       ; Reverse video
Scroll_up                 equ    06        ; scroll up
Clear                     equ    00        ; Clear screen
Home                      equ    00        ; Home position
Bottom_home               equ    184fh     ; Bottom home position
Menu_box_parameters       equ    0d4ch     ; Box is 7 x 60
Menu_box_position         equ    0a02h     ; Row 16 column 9

Get_key                   equ    00        ; Get key
Key_board_int             equ    16h       ; Get key int
Esc_scan_code             equ    01h       ; Esc key scan code
Return_scan_code          equ    1ch       ; Return key scan code
Esc_key_int               equ    40h       ; Esc key interrupt
Check_for_key             equ    01        ; Check for key
Kb_data                   equ    60h       ; Key board data port
Kb_ctl                    equ    61h       ; Key board control port
Eoi                       equ    20h       ; End of interrupt

Nec_status                equ    42h       ; Offset to NEC status bytes

Version_position          equ    0042h
Current_side_position     equ    0cffh     ; Display side position
Side_0_position           equ    0c0fh     ; Side 0 position
Side_1_position           equ    0c33h     ; Side 1 position
Source_drive_position     equ    0203h     ; Display source drive position
Target_drive_position     equ    023eh     ; Display target drive position
Date_position             equ    0003h     ; Display date position
Are_you_sure_position     equ    181bh     ; Display position
Yes_position              equ    182bh     ; Display yes position
No_position               equ    1831h     ; Display no position

Null_message              equ    00h       ; No message
Center_message            equ    4fh       ; Center message
Center_column             equ    27h       ; Center column
Center_line               equ    13        ; Center line
Column_limit              equ    4fh       ; Column limit
Line_limit                equ    18h       ; Bottom of screen
Set_cursor                equ    02h       ; Set cursor
Page_0                    equ    00h       ; Page 0
One_character             equ    01h       ; One character
Display_screen            equ    09h       ; Display screen
Get_date                  equ    2ah       ; Get date
Dos_function_int          equ    21h       ; Dos function 21
Status_row                equ    1800h     ; Status row
Ascii_convert             equ    30h       ; Asccii 0
Smallest_box              equ    03h       ; Smallest box size
Upper_left_corner         equ    0c9h      ; Upper left corner of box
Upper_right_corner        equ    0bbh      ; Upper right corner of box
One_row                   equ    01        ; One row
Lower_left_corner         equ    0c8h      ; Lower left hand corner
Lower_right_corner        equ    0bch      ; Lower right corner
Horizontal_line           equ    0cdh      ; Horizontal line
Blank                     equ    20h       ; Space
Center_string             equ    4fh       ; Center string
Vertical_line             equ    0bah      ; Vertical line

Current_disk_position     equ    0cffh     ; Current disk position
Source_diskette_position  equ    0e0fh     ; Source diskette position
Target_diskette_position  equ    0e33h     ; Target diskette position
Current_track_position    equ    10ffh     ; Current tack position

Row_1_position            equ    120ah     ; Row 1 position
Row_2_position            equ    140ah     ; Row 2 position
Sector_size               equ    128       ; Size of smallest sector

Use_key_position          equ    0cffh     ; Use key position
Select_source_drive_position equ  0e14h
Select_target_drive_position equ  1014h
Drive_a_column            equ    2fh
Drive_b_column            equ    38h
One_drive_position        equ    18ffh     ; One drive position
Hold_on_position          equ    18ffh     ; Temporary
Selection_complete_position equ  13ffh

Print                     equ    05h       ; Print command

.List
oiin    q  1fh  ;OediepstoHl_npst