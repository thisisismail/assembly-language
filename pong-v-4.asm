IDEAL
MODEL compact
STACK 300h
LOCALS @@
DATASEG
    C1 	    dw 9121
    Ckr1    dw 8609
    D1 	    dw 8126
    Dkr1    dw 7670
    E1 	    dw 7239
    F1 	    dw 6833
    Fkr1    dw 6449
    G1 	    dw 6087
    Gkr1    dw 5746
    A1 	    dw 5423
    Akr1    dw 5119
    B1 	    dw 4831
    C2 	    dw 4560
    Ckr2    dw 4304
    D2 	    dw 4063
    Dkr2    dw 3834
    E2 	    dw 3619
    F2 	    dw 3416
    Fkr2    dw 3224
    G2 	    dw 3043
    Gkr2    dw 2873
    A2 	    dw 2711
    Akr2    dw 2559
    B2 	    dw 2415
    C3 	    dw 2280
    Ckr3    dw 2152
    D3 	    dw 2031
    Dkr3    dw 1917
    E3 	    dw 1809
    F3 	    dw 1715
    Fkr3    dw 1612
    G3 	    dw 1521
    Gkr3    dw 1436
    A3 	    dw 1355
    Akr3    dw 1292
    B3 	    dw 1207
    C4 	    dw 1140


     
    clock equ es:6Ch   
    tone dw ?

isRunning db 1
; konstanta ukuran bola
BsizeX dw 4
BsizeY dw 4
; lokasi mulai paddle kedua pemain pada sumbu vertikal
loc1 dw 75
loc2 dw 75

ctr1Up dw 0
ctr2Up dw 0

; posisi mulai bola PONG
BallX dw 50
BallY dw 120
; deklarasi variabel agar posisi bola tidak di sumbu negatif
BallUp db 1
BallLeft db 1

; deklarasi kecepatan bola
XSpeed dw 2
YSpeed dw 2
; variabel skor pemain
Score1 db 0
Score2 db 0
; deklarasi peningkatan kecepatan bola
shouldIncSpeed dw 0
; pesan ke pemain saat menang
Player1 db "Player 1 won!",10,13,'$'
Player2 db "Player 2 won!", 10, 13, '$'
; deklarasi input pemain
NO_KEY equ 0
UP_CTRL_1 equ 1
DOWN_CTRL_1 equ 2
UP_CTRL_2 equ 3
DOWN_CTRL_2 equ 4
EXIT equ 5

CODESEG
proc pencet
    push bx
    mov bx,cx          
    mov [tone],bx          
    pop bx
    call sounder
endp
proc delay1                 
  push ax               
  mov ax,40h               
  mov es,ax                 
  mov ax,[clock]
  
  Ketukawal:
    cmp ax, [clock]
    mov cx, 2               
    je Ketukawal
  
  Loopdelay1:
    mov ax, [clock]
    ketuk:
       cmp ax,[clock]
       je ketuk
       loop Loopdelay1
       pop ax
    ret
endp delay1   
proc sounder
  push ax
  in al, 61h
  or al, 00000011b          
  out 61h, al 	            
  mov al, 0B6h
  out 43h, al
  mov ax, [tone]        
  out 42h, al         
  mov al, ah
  out 42h, al          
  pop ax
  ret
endp sounder
proc matisuara             
    in al,61h
    and al, 11111100b    
    out 61h, al
    ret
endp matisuara 
proc startup
    ; prosedur deklarasi user interface 
    mov ax, 13h
    int 10h
    ret
endp startup
proc printScores

    ; meletakkan cursor ke tengah layar
    mov  dl, 170  
    mov  dh, 45   
    mov  bh, 0
    mov  ah, 02h  
    int  10h
    ; mencetak nilai
    mov al, [Score1]
    mov bl, 0Fh
    mov bh, 0
    mov ah, 0eh
    add al, '0'
    int 10H

    ; tampilan nilai dengan format A : B
    mov al, ':'
    mov bl, 0Fh
    mov bh, 0
    mov ah, 0eh
    int 10H

    mov al, [Score2]
    mov bl, 0Fh
    mov bh, 0
    mov ah, 0eh
    add al, '0'
    int 10H
    ret
endp printScores
proc moveBall
; memindahkan posisi bola (bila bisa bergerak pada sumbu vertikal akan terus naik)
    mov ax, [YSpeed]
    cmp [BallUp], 0
    je @@goUp
    add [BallY], ax
    jmp @@nextX
    @@goUp:
        sub [BallY], ax
    @@nextX:
    ; bila bola bisa bergerak horizontal akan berlanjut ke arah tersebut
    mov bx, [XSpeed]
    cmp [BallLeft], 0
    jne @@moveRight
    sub [BallX], bx
    jmp @@checkNextRender
    @@moveRight:
        add [BallX], bx

    ; debugging posisi bola bila ada di ujung/menabrak dinding
    @@checkNextRender:
    cmp [BallY], 5h
    jg @@noHitWallUp
    mov [BallUp], 1
    jmp @@noHitWallUp
    @@noHitWallUp:
    cmp [BallY], 200d
    jl @@noHitWallDown
    mov [BallUp], 0
    @@noHitWallDown:
    cmp [BallX], 10
    jl @@testCtrlLeft
    cmp [BallX], 310
    jg @@testCtrlRight
    ret
    @@testCtrlLeft:
        mov ax, [loc1]
        jmp @@comp
    @@testCtrlRight:
        mov ax, [loc2]
    @@comp:
    mov bx, [BallY]
    cmp ax, bx
    jle @@fitRDwon
    ret
    @@fitRDwon:
    add ax, 45
    cmp ax, bx
    jge @@inCtrl
    ret
    ; menambahkan kecepatan bola bila terjadi kolisi
    @@inCtrl:
    mov cx, [C3]
    call pencet
    call matisuara
    cmp [shouldIncSpeed], 0
    je @@noInc
    cmp [XSpeed], 7
    je @@noInc
    inc [XSpeed]
    mov [shouldIncSpeed], 0
    jmp @@nextCheck
    @@noInc:
    mov [shouldIncSpeed], 1
    @@nextCheck:
    mov [BallUp], 0
    cmp [BallLeft], 0
    je @@nextL
    mov [BallLeft], 0
    dec [BallX]
    ret
    @@nextL:
    inc [BallX]
    mov [BallLeft], 1
    ret
    
endp moveBall
proc checkScore ;melakukan print bila ada pemain yang mencetak skor
    mov ax, [BallX]
    cmp ax, 2
    js Scored1
    cmp ax, 315
    jg Scored2
    ret
    Scored1:
        ; memeriksa bila sudah ada pemenang
        mov [XSpeed], 2
        inc [Score2]
        mov cx, [C2]
        call pencet
        call matisuara
        cmp [Score2], 3
        je @@p1Won
        jmp @@waitI
        @@p1Won:
        mov [isRunning], 0
        mov bx, 1
        jmp pMsg
    Scored2:
    mov [XSpeed], 2
        inc [Score1]
        mov cx, [C2]
        call pencet
        call matisuara
        cmp [Score1], 3
        je @@p2Won
        jmp @@waitI
        @@p2Won:
        mov [isRunning], 0
        mov bx, 0
    pMsg:
    ; me-reset kecepatan bola
    mov [XSpeed], 2 
    ; melakukan print pesan:
    cmp bx, 0
    je @@msg1
    jne @@msg2
    @@msg1:
        mov [BallLeft], 1
        mov dx, offset Player1
        jmp @@printM
    @@msg2:
        mov [BallLeft], 0
        mov dx, offset Player2
    @@printM:
    mov ah, 13h
    push es
    push bp
    mov bx, ds
    mov es, bx
    mov bp, dx
    mov cx, 15
    xor dx, dx
    mov bl, 0Fh
    int 10h
    pop bp
    pop es
    call lagu
    ; menunggu adanya input dari pemain
    @@waitI:
    mov ah, 1
    int 16h
    jz @@waitI
    ; mengambil input dari pemain;
    mov ah, 0
    int 16h
    cmp al,13d
    jne @@waitI
    ; me-reset posisi bola:
    mov [BallX], 120
    mov [BallY], 150
    ret
endp checkScore

proc draw_pixle
; deklarasi variabel untuk paddle dan bola
    push bp
    mov bp, sp
    
    mov ax, [bp + 4]
    mov bl, 0 
    mov cx, [bp + 6]
    mov dx, [bp + 8]
    mov ah, 0ch
    int 10h

    pop bp
    retn 6
endp draw_pixle

proc draw_line
    push bp
    mov bp ,sp

    mov ax, [bp + 4]
    mov bx, [bp + 6]
    mov cx, [bp + 8]
    mov dx, [bp + 10]

    @@loop:
        push ax
        push bx
        push cx
        push dx
        ;menggambar objek di lokasi yang ditentukan
        push ax
        push bx
        push dx
        call draw_pixle

        pop dx
        pop cx
        pop bx
        pop ax

        inc ax 
        loop @@loop
    pop bp
    ret

endp draw_line

proc draw_ball
    ;menggambar objek bola
    push bp
    mov bp, sp

    mov ax, [bp + 4]
    mov bx, [bp + 6]
    mov dx, [bp + 8]
    mov cx, [BsizeX]
    @@loop:
        push ax
        push bx
        push cx

        push dx
        push [BsizeY]
        push bx
        push ax 
        ;menggambar objek paddle
        call draw_line
        pop ax
        pop bx
        pop ax
        pop bx
        pop cx
        pop bx
        pop ax
        inc bx
    loop @@loop


    pop bp
    ret
endp draw_ball


proc draw_ctrl
    ;menampilkan paddle kedua player
    push bp
    mov bp, sp

    mov ax, [bp + 4]
    mov bx, [bp + 6]
    mov cx, 2
    @@loop:
        push ax
        push bx
        push cx

        push 15 ; variabel warna
        push 40 ; variabel ukuran
        push bx
        push ax
        call draw_line
        pop ax
        pop bx
        pop ax
        pop bx
        pop cx
        pop bx
        pop ax
        inc bx
    loop @@loop
    pop bp
    ret
endp draw_ctrl

proc shutdown
    ; mengembalikan mode game ke mode text
    mov ah, 00
    mov al, 2
    int 10h
    ret
endp shutdown
proc refrash
    ; mengosongkan layar

    mov AH, 06h
    xor AL, AL
    xor CX, CX
    mov DX, 184FH 
    mov BH, 00
    int 10H
    ret
endp refrash
proc getInput
    ; prosedur pengambilan input dari pemain
    mov ah, 1
    int 16h
    jz next_k
    mov ah, 0
    int 16h

    ; melakukan input parsing:
    cmp ah, 1 ; input tombol [ESC]
    je esc_pressed
    cmp ah, 1bh
    je esc_pressed
    cmp ah, 48h ; input panah atas
    je up_pressed
    cmp ah, 50h ; input panah bawah
    je down_pressed
    cmp al, 'w'
    je w_pressed
    cmp al, 's'
    je s_pressed
    ret
    ; mendeklarasi tindakan saat menerima input
    esc_pressed:
        mov ax, EXIT
        ret
    up_pressed:
        mov ax, UP_CTRL_2
        ret
    down_pressed:
        mov ax, DOWN_CTRL_2
        ret
    w_pressed:
        mov ax, UP_CTRL_1
        ret
    s_pressed: 
        mov ax, DOWN_CTRL_1
        ret
    next_k:
        ret
endp getInput

proc handle_input
    ; handler input, akan merefresh hingga menerima input
    push bp
    mov bp, sp
    mov ax, [bp + 4] ; input
    pop bp
    cmp ax, EXIT
    je die
    cmp ax, UP_CTRL_1
    je up1
    cmp ax, UP_CTRL_2
    je up2
    cmp ax, DOWN_CTRL_1
    je down1
    cmp ax, DOWN_CTRL_2
    je down2
    ; bila tidak ada input, akan return ke awal
    ret
    die:
        mov [isRunning], 0
        ret
    ; gerakan pemain 1 & 2:
    up1:
        ; memastikan pemain 1 bisa bergerak vertikal ke atas
        cmp [loc1], 5h
        js nu1
        sub [loc1], 5
        nu1:
        ret
    up2:
        ; memastikan pemain 2 bisa bergerak vertikal ke atas
        cmp [loc2], 5h
        js nu2
        sub [loc2], 5
        nu2:
        ret
    down1:
        ; memastikan pemain 1 bisa bergerak vertikal ke bawah
        cmp [loc1], 155d
        jg nd1
        add [loc1], 5
        nd1:
        ret
    down2:
        ; memastikan pemain 2 bisa bergerak vertikal ke bawah
        cmp [loc2], 155d
        jg nd2
        add [loc2], 5
        nd2:
        ret
    ret
endp handle_input

proc draw_board
    ; prosedur yang menampilkan interface game
    push bp
    mov bp, sp
    push ax
    ; menampilkan skor board
    call printScores
    ; menampilkan bola
    @@draw_ball:
        ; variabel warna bola
        push 6
        push [BallX]
        push [BallY]
        call draw_ball
        pop ax
        pop ax
        pop ax
    ; menampilkan paddle 1
    @@draw_1:
    ;warna paddle 1
        push 500
        push 2
        push [loc1]
        call draw_ctrl
        pop ax
        pop ax
        pop ax
    ; menampilkan paddle 2
    @@draw_2:
    ;warna paddle 2
        push 500
        push 315
        push [loc2]
        call draw_ctrl
        pop ax
        pop ax
        pop ax
    pop ax
    pop bp
    ret
endp draw_board

proc delay
; delay program sebesar 0.125 detik, untuk debugging
    mov cx, 00
    mov dx, 08235h
    mov al, 0
    mov ah, 86h
    int 15h
    ret
endp delay

proc lagu
    mov cx, [Gkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [G3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara 
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Ckr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Gkr2]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [A3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [A3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Gkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [G3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Ckr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Ckr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Gkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Gkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [G3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara 
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Ckr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Ckr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [C3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [C3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [C3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Ckr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Ckr3]
    call pencet
    call delay1
    call matisuara 
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [A3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [A3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Gkr3]
    call pencet
    call delay1
    call matisuara 
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [A3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Gkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Gkr3]
    call pencet
    call delay1
    call matisuara 
    
    mov cx, [Gkr3]
    call pencet
    call delay1
    call matisuara
       
    mov cx, [Gkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [G3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara 
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Ckr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Gkr2]
    call pencet
    call delay1
    call matisuara
    
    
    
    mov cx, [Gkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [G3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara 
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Ckr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Gkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [F3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Gkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [F3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Gkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Gkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [A3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [B2]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [B2]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Gkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [A2]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [A2]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [E3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Fkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Dkr3]
    call pencet
    call delay1
    call matisuara
    
    mov cx, [Ckr3]
    call pencet
    call delay1
    call matisuara
endp
start:
    ; fungsi main
	mov ax, @data
	mov ds, ax
	call startup

    game_l:
        call draw_board 
        call getInput
        push ax
        call handle_input
        pop ax
        call moveBall

        call checkScore
        call delay
        call refrash
        ;jika isRunning masih aktif, maka program akan terus berjalan
    cmp [isRunning], 0
    jne game_l
    ; menutup game:
	call shutdown
	mov ax, 4c00h
	int 21h
END start