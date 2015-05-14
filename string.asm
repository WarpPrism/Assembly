;输入一个仅含字母和数字的字符串，然后统计它的长度以及字母，数字的个数。

DISPLAY MACRO STRING
    MOV AH,09
    ;MOV DX,OFFSET STRING
    LEA DX,STRING
    INT 21H
ENDM

INPUT MACRO BUF
    MOV AH,0AH
    LEA DX,BUF
    INT 21H
ENDM

SHOWCHAR MACRO CHAR
    MOV AH,02
    MOV DL,CHAR
    INT 21H
ENDM


DATAS SEGMENT
    PROMP1 DB "Please input a string:", '$'
    PROMP2 DB "Input Done!", '$'
    PROMP3 DB "Length: ", '$'
    PROMP4 DB "Letters: ", '$'
    PROMP5 DB "Numbers: ", '$'
    LETTER DW (0)
    NUMBER DW (0)
    LENGTH DW (0)
    CRLF   DB 0DH,0AH,'$'
    
    BUF    DB 30
           DB (0)
           DB 30 DUP ('$')
DATAS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS
    
START:
        MOV AX,DATAS                   
        MOV DS,AX                      
        
        DISPLAY PROMP1
        DISPLAY CRLF
        INPUT BUF
        DISPLAY CRLF
        DISPLAY PROMP2
        DISPLAY CRLF
        
        MOV CL,BUF + 1
        LEA SI,BUF + 2
        
NEXT:   MOV AL,[SI]
        CMP AL,2FH
        JA  CMP1

CMP1:   CMP AL,3AH
        JB ADDNUM
        JA CMP2
        
ADDNUM: INC NUMBER
        INC LENGTH
        JMP GOON

CMP2:   CMP AL,40H
        JA CMP3
        
CMP3:   CMP AL,5BH
        JB ADDLET
        JA CMP4
        
ADDLET: INC LETTER
        INC LENGTH
        JMP GOON

CMP4:   CMP AL,60H
        JA CMP5
        
CMP5:   CMP AL,7BH
        JB ADDLET

GOON:   INC SI
        DEC CL
        JZ STATICS
        JNZ NEXT

STATICS:  DISPLAY PROMP3
          MOV AX,LENGTH
          CALL SHOW
          DISPLAY CRLF
          DISPLAY PROMP4
          MOV AX,LETTER
          CALL SHOW
          DISPLAY CRLF
          DISPLAY PROMP5
          MOV AX,NUMBER
          CALL SHOW
          DISPLAY CRLF

      
OVER:   MOV AH,4CH
        INT 21H


SHOW:
        XOR CX,CX
        MOV BX,10
NX1:
        XOR DX,DX
        DIV BX
        OR DX,0e30h
        INC CX
        PUSH DX
        CMP AX,0
        JNZ NX1
NX2:    POP AX
        INT 10H
        LOOP NX2
        RET
        
        
CODES ENDS
END START
        
