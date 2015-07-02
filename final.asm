; The third Exprement,ID,Music,Array

;**************************************************************;
data  segment
    ;ID Data
    io8255a        equ 288h
    io8255b        equ 28bh
    io8255c        equ 28ah
    led            db  3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,6fh ;段码
    id             db  1,0,3,1,3,3,3,3,1,3,3,1,7,3,1,7,0,1         ;存放学号
    idindex        db  ?
    idoffs         dw ?
    bit            dw  ?           ;位码
    ;Music Data
    musicio8253a        equ 280h
    musicio8253b        equ 283h
    ;table dw 524,588,660,698,784,880,988,1048;高音的
    tables dw 262,294,330,347,392,440,494,524;低音的
    music db '1','1','5','5','6','6','5','0','4','4','3','3','2','2','1','5','5','4','4','3','3','2','5','5','4','4','3','3','2'
    musicindex db ?
    musicoffs dw ?
    
    ls244 equ 2a0h  ;74LS244为八缓冲器
    protlspeed equ    298h         ;模数转化端口
    speed dw 30h
    
    array db 24h,24h,24h,0dch,0dch,24h,22h,21h,3h,7h,0fh,3h,1fh,7h,3fh,3h,81h,42h,24h,0dch,0dch,24h,24h,24h,3h,3fh,3h,0fh,1h,0ffh,3h,1fh,9h,12h,24h,0dch,0dch,24h,42h,81h,7h,0fh,1fh,3h,3fh,7h,0fh,0ffh
    arrayc db 0ffh,81h,81h,81h,81h,81h,81h,0ffh,0ffh,0c3h,0a5h,99h,99h,0a5h,0c3h,0ffh,81h,83h,85h,89h,91h,0a1h,0c1h,81h
    arrayindex db ?
    arrayoffs dw ?
    arrayoffs2 dw ?
data ends

code  segment
                assume cs:code,ds:data
                
start:          mov ax,data
                mov ds,ax
                ;jmp musicstart
                
                
                
                
                mov musicindex,0
                mov musicoffs,0
                mov arrayindex,0
                mov arrayoffs,0
                mov idindex,0
                mov idoffs,0

;显示学号*******************************************************
                
idstart:        call clear
                mov dx,io8255b            ;将8255设为A口输出
                mov al,80h
                out dx,al
    
idagain:        mov di,offset id      ;设di为显示缓冲区
                add di,idoffs
    
idoutloop:      mov cx,50h               ;循环次数

idinloop:       mov bh,02

twobit:         mov byte ptr bit,bh
                push di
                dec di
                add di, bit
                mov bl,[di]                  ;bl为要显示的数
                pop di
                mov bh,0
                mov si,offset led            ;置led数码表偏移地址为SI
                add si,bx                    ;求出对应的led数码
                mov al,byte ptr [si]
                
                mov dx,io8255a               ;自8255A的口输出
                out dx,al
                mov al,byte ptr bit           ;使相应的数码管亮
                mov dx,io8255c
                out dx,al
                
                
                push cx
                mov cx,100                 
iddelay:        loop iddelay                  ;延时

                pop cx

                mov al,00h
                out dx,al
    
                mov bh,byte ptr bit
                shr bh,1
                jnz twobit
                loop idinloop                  ;循环延时
                
idexit:         mov dx,io8255c
                mov al,1                    ;关掉数码管显示
                out dx,al
    
    
                push ax
                push bx
                push cx
                push dx
                push si
                push di
;播放音乐*******************************************************

musicstart:     call clear
                mov si,offset music
                add si,musicoffs

               

sing:           
                mov al, [si]
    
                sub al,31h
                shl al,1             ;转为查表偏移量
                mov bl,al            ;保存偏移到bx
                mov bh,0
    
                mov ax,4240H         ;计数初值 = 1000000 / 频率, 保存到AX
                mov dx,0FH
                div word ptr[tables+bx]
                mov bx,ax
    
                mov dx,musicio8253b          ;设置8253计时器0方式3, 先读写低字节, 再读写高字节
                mov al,00110110B
                out dx,al

                mov dx,musicio8253a         
                mov ax,bx
                out dx,al            ;写计数初值低字节
    
                mov al,ah
                out dx,al            ;写计数初值高字节
    
                mov dx,io8255b          ;设置8255 A口输出
                mov al,10000000B
                out dx,al
    
    
                call musicdelay
                mov dx,io8255a            
                mov al,80h
                out dx,al            ;置PA1PA0 = 11(开扬声器)
                call musicdelay           ;延时
                mov al,0h
                out dx,al            ;置PA1PA0 = 00(关扬声器)

                
                push ax
                push bx
                push cx
                push dx
                push si
                push di
;点阵操作*******************************************************

arraystart:     call clear

                call speedcontrol
agn:            mov    cx,speed                       ;循环次数。一屏重复显示80H次（十进制数128次），控制这段程序 d2<->loop d2 执行80H次。
                                                    ;这个值的大小影响到 '年' 字显示停留的时间，起着显示 速度 控制作用

d2:             mov    bx,offset array            ;行码偏移地址首地址
                add    bx,arrayoffs

                mov    ah,01h                    ;循环次数。列码（列信号），8X8点阵，01H=00000001B表示8列灯状态，其中只有右边第一列
                                       ;灯亮，其余灯灭；'1'亮灯，'0'灭灯。每个列码中只能有一个为'1'，其余'0'。
                                       ;那为什么'年'字能在8X8点阵上显示出来呢？原因是延迟造成的。    
       
                push   cx                        ;计数器 cx 压栈，这个 cx 旳值是对指令 loop d2 来说的
                mov    cx,0008h                  ;初值，8行信息计数，控制这段程序 next <-> loop next 执行8次，读取并显示8行信息，
                                       ;即显示一屏

               
next: 
                mov    al,[bx]                   ;取行码->al

                mov    dx,280h                  ;行地址->dx
                out    dx,al                     ;输出行码

                mov    al,ah                     ;列码 ah->al
                mov    dx,288h                 ;红灯地址->dx
                out    dx,al                     ;红灯显示一行信息

                mov    al,00                     ;灭灯。亮下列灯前，先关闭前列灯，否则，亮下列灯的信息时，其也会在前列灯中显示输出
                out    dx,al

                shl    ah,01                     ;列码（列信号）左移一位，将'1'移到下一位，为显示下列灯亮做准备

                inc    bx                        ;bx+1 为取下个行码做准备

                loop   next                      ;next <-> loop next 显示一屏信息     
         
                pop    cx                        ;恢复指令 loop d2 计数器 cx 的值

                loop   d2                        ;程序段 d2 <-> loop d2 重复显示一屏信息
                

;*******************************************************************************************************
                ;call selectarray
                add arrayoffs,8
                inc arrayindex
                cmp arrayindex,6
                je arrayreset
                jne pop1
                
arrayreset:     mov arrayindex,0
                mov arrayoffs,0
                
pop1:           pop di
                pop si
                pop dx
                pop cx
                pop bx
                pop ax
                
                inc musicoffs
                inc musicindex
                cmp musicindex,29
                je musicreset
                jne pop2
                
musicreset:     mov musicindex,0
                mov musicoffs,0

pop2:           pop di
                pop si
                pop dx
                pop cx
                pop bx
                pop ax
                
                
                add idoffs,02
                inc idindex
                cmp idindex,09
                jne goon
                je  idreset
                
                
idreset:        mov idindex,0
                mov idoffs,0                
                
                
    


goon:           mov ah,06           ;是否有键按下
                mov dl,0ffh
                int 21h
                jnz controlarray
                jmp idstart
                
;********************************************************************
;K control the array
                
controlarray:   call clear
                mov arrayoffs2,0
                ;call selectarray
                ;call musicdelay
                mov dx,ls244
                in al,dx
                mov ah,0
                mov arrayoffs2,ax
                ;mov dl,al          ;将所读数据保存在DL中
                ;mov ah,02
                ;int 21h
                ;mov dl,0dh         ;显示回车符
                ;int 21h
                ;mov dl,0ah         ;显示换行符
                ;int 21h
    
                ;cmp al,'4'
                ;je array1
                ;jne cmp2
;array1:         ;mov arrayoffs2,0
                ;jmp light
;cmp2:           cmp al,'6'
                ;je array2
                ;jne cmp3
;array2:         mov arrayoffs2,8
                ;jmp light
;cmp3:           cmp al,8
                ;je array3
                ;jne light
;array3:         mov arrayoffs2,16

light:          mov    cx,100h                       ;循环次数。一屏重复显示80H次（十进制数128次），控制这段程序 d2<->loop d2 执行80H次。
                                                    ;这个值的大小影响到 '年' 字显示停留的时间，起着显示 速度 控制作用
dd2:            mov    bx,offset arrayc            ;行码偏移地址首地址
                add    bx,arrayoffs2

                mov    ah,01h                    ;循环次数。列码（列信号），8X8点阵，01H=00000001B表示8列灯状态，其中只有右边第一列
                                       ;灯亮，其余灯灭；'1'亮灯，'0'灭灯。每个列码中只能有一个为'1'，其余'0'。
                                       ;那为什么'年'字能在8X8点阵上显示出来呢？原因是延迟造成的。    
       
                push   cx                        ;计数器 cx 压栈，这个 cx 旳值是对指令 loop d2 来说的
                mov    cx,0008h                  ;初值，8行信息计数，控制这段程序 next <-> loop next 执行8次，读取并显示8行信息，
                                       ;即显示一屏

               
nextss: 
                mov    al,[bx]                   ;取行码->al

                mov    dx,280h                  ;行地址->dx
                out    dx,al                     ;输出行码

                mov    al,ah                     ;列码 ah->al
                mov    dx,290h                 ;红灯地址->dx
                out    dx,al                     ;红灯显示一行信息

                mov    al,00                     ;灭灯。亮下列灯前，先关闭前列灯，否则，亮下列灯的信息时，其也会在前列灯中显示输出
                out    dx,al

                shl    ah,01                     ;列码（列信号）左移一位，将'1'移到下一位，为显示下列灯亮做准备

                inc    bx                        ;bx+1 为取下个行码做准备

                loop   nextss                      ;next <-> loop next 显示一屏信息     
         
                pop    cx                        ;恢复指令 loop d2 计数器 cx 的值

                loop   dd2                        ;程序段 d2 <-> loop d2 重复显示一屏信息
                
                call clear
                
                mov ah,06           ;是否有键按下
                mov dl,0ffh
                int 21h
                jnz allend
                jmp controlarray

                


    
allend:         mov ah,4ch                  ;返回
                int 21h
                
                
;子程序
clear proc near
    sub ax,ax
    sub bx,bx
    sub cx,cx
    sub dx,dx
    sub si,si
    sub di,di
    ret
clear endp

musicdelay proc near          ;延时子程序
    push cx
    push ax
    mov ax,100
x1: mov cx,0ffffh
x2: dec cx
    jnz x2
    dec ax
    jnz x1
    pop ax
    pop cx
    ret
musicdelay endp

speedcontrol proc near                 ;速度控制程序
    push ax
    push bx
    push cx
    push dx

    mov  dx,protlspeed ;启动A/D转换器
    out  dx,al

    mov  cx,0ffh       ;延时，缓冲
delayinspeed:     loop delayinspeed

    in   al,dx         ;读取A/D转换器数据存到al
    mov cl, al
    mov ch, 0
    mov speed, cx
    pop dx
    pop cx
    pop bx
    pop ax
    ret
speedcontrol endp

code ends
    end start
