; FILENAME: EXA131.ASM - B18030620
.486

DATA SEGMENT USE16
    SUM   DB  ?, ?        ; 存放和 - XXXXH
    MESG  DB  '25+9='     ; 显式用
          DB  0, 0, '$'   ; 和与字符串结尾
    N1    DB  9           ; 操作数 1 - 09H
    N2    DB  25          ; 操作数 2 - 19H
DATA ENDS

CODE SEGMENT USE16
     ASSUME  CS:CODE, DS:DATA
BEG:
    ; 初始化 DS
    MOV   AX, DATA
    MOV   DS, AX
    ; 取 SUM 的偏移地址到 BX
    MOV   BX, OFFSET SUM
    ; AH 放 09H，AL 放 19H
    MOV   AH, N1             ; AH - 0009H
    MOV   AL, N2             ; AL - 0019H
    ; 相加并将结果存到 SUM
    ADD   AH, AL
    MOV   [BX], AH           ; SUM - 0022H
    ; 二进制转十进制
    CALL  CHANG
    ; 显示
    MOV   AH, 9
    MOV   DX, OFFSET MESG
    INT   21H
    ; DOS 程序结束
    MOV   AH, 4CH
    INT   21H

; 子程序
CHANG PROC
LAST:
	CMP  BYTE PTR [BX],10
	JC   NEXT                   ; 小于 10 则已减至只剩个位
	SUB  BYTE PTR [BX],10       ; SUM 每减 10 十位上的数字对应 +1
	INC  BYTE PTR [BX+7]        ; [BX+7] 即 MESG 中预留的第一个 0 (十位)
	JMP  LAST                   ; 循环，不断减 10
NEXT:
	MOV  AH, SUM                         ; SUM 中为个位数
	MOV  BYTE PTR [BX+8], BYTE PTR AH    ; 个位数放到 [BX+8]
	;MOV  BYTE PTR [BX+8], BYTE PTR SUM  ; 不可同时为内存操作数
	ADD  BYTE PTR [BX+7], 30H            ; PTR 十位
	ADD  BYTE PTR [BX+8], 30H            ; PTR 个位
	RET
CHANG ENDP

CODE ENDS
    END BEG
