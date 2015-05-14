Problem Description:
编写一程序，实现将既包含在数组A中又包含在数组B中的无符号字数取出并存于数组C中，
然后对数组C中的数按从小到大进行排序，再将其显示出来，其中数组A包含20个数，数组B包含30个数。
如找不到相同的数则显示“No same!”。
C++ 实现关键代码：
//function selectsort
void selectsort(int arr[], int size) {
	for (int current = 0; current < size - 1; current++) {
		//find minimal number
		int min = arr[current];
		int min_index = current;
		for (int iter = current + 1; iter < size; iter++) {
			if (arr[iter] < min) {
				min = arr[iter];
				min_index = iter;
			}
			else {
				continue;
			}
		}
		//swap
		int temp = arr[min_index];
		arr[min_index] = arr[current];
		arr[current] = temp;
	}
}

DISPLAY MACRO STRING                   
    MOV AH,09
    ;MOV DX,OFFSET STRING
    LEA DX,STRING
    INT 21H
ENDM

SHOWCHAR MACRO CHAR
    MOV AH,02
    MOV DL,CHAR
    INT 21H
ENDM

DATAS SEGMENT
    PROMPT DB "The sorted array is: ",'$'
    PROMPT1 DB "No same!",'$'
    CRLF   DB 0DH,0AH,'$'
    A   DB 1,2,23,4,25,36,37,28,9,10,11,12,23,14,15,16,17,18,19,20
    B   DB 1,2,3,4,5,6,7,8,9,10,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40
    C   DB 30 DUP (0)
    ;C   DB 10,9,8,7,6,5,4,3,2
    COUNT   DB (0)
    COUNT2  DB (0)
    ORDERED DB (0)
    TEMP     DB (0)
    MININDEX DW (0)
    INDEX   DW (0)
DATAS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS
    
START:      
            
            MOV AX,DATAS
            MOV DS,AX
            ;JMP SORT_INIT
    
            MOV SI,OFFSET A
            MOV BX,OFFSET B
            MOV DI,OFFSET C
            MOV CX,20
            MOV AH,30
    
COMP:       MOV AL,[SI]
            MOV DL,[BX]
            CMP AL,DL
            JZ  INB
            INC BX
            DEC AH
            CMP AH,0
            JZ  NOT_INB
            JNZ COMP
        
                
INB:        MOV [DI],AL
            INC COUNT
            INC SI
            INC DI
            MOV BX,OFFSET B
            MOV AH,30
            DEC CX
            JNZ COMP
            JZ  NOSAME
            ;JZ  SHOWC

NOT_INB:    INC SI
            MOV BX,OFFSET B
            MOV AH,30
            DEC CX
            JNZ COMP
            JZ  NOSAME
            ;JZ  SHOWC
            
NOSAME:     CMP COUNT,0
            JZ PROMPT_
            JNZ SORT_INIT

PROMPT_:    DISPLAY PROMPT1
            DISPLAY CRLF
            JMP OVER
            
SORT_INIT:  CALL CLEAR
            MOV ORDERED,0          
            MOV CL,COUNT
            DEC CL
            MOV AL,COUNT
            SUB AL,ORDERED
            DEC AL 
            MOV BH,0
            MOV BL,ORDERED
            MOV DL,C[BX]
            MOV MININDEX,BX
            MOV DI,MININDEX
         
COMPMIN:    CMP DL,C[BX + 1]
            JB  NEXT
            MOV DL,C[BX + 1]
            MOV MININDEX,BX
            INC MININDEX
            MOV DI,MININDEX
            JMP NEXT
            
NEXT:       DEC AL
            JZ SWAP
            INC BX
            JMP COMPMIN
            
SWAP:       MOV DH,0
            MOV BH,0
            MOV BL,ORDERED
            MOV DH,C[BX]
            MOV TEMP,DH
            MOV DH,C[DI]
            MOV C[BX],DH
            MOV DH,TEMP
            MOV C[DI],DH
            JMP AGAIN
            
AGAIN:      INC ORDERED
            MOV AL,COUNT
            SUB AL,ORDERED
            DEC AL
            MOV BH,0
            MOV BL,ORDERED
            MOV DH,0
            MOV DL,C[BX]
            MOV MININDEX,BX
            MOV DI,MININDEX
            DEC CL
            JNZ COMPMIN
            JZ SHOWC
                                             

SHOWC:      
            DISPLAY PROMPT
            DISPLAY CRLF
            DISPLAY CRLF
            CALL CLEAR
            MOV CL,COUNT
            MOV COUNT2,CL
            MOV BX,0
            MOV INDEX,BX

DISPLAY:    MOV AL,C[BX]
            CALL SHOW
            SHOWCHAR ' '
            INC INDEX
            MOV BX,INDEX
            XOR AX,AX
            DEC COUNT2
            JNZ DISPLAY
            JZ  OVER
        
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

CLEAR:
        XOR AX,AX
        XOR BX,BX
        XOR CX,CX
        XOR DX,DX
        RET
                
CODES ENDS
END START
