; FILENAME: EXP04.ASM - B18030620
.586

DATA SEGMENT USE16
    OLD0B     DD ?
    FLAG      DB 0
DATA ENDS

CODE SEGMENT USE16
    ASSUME CS:CODE, DS:DATA

BEG:
    MOV     AX, DATA
	  MOV     DS, AX      ; 初始化 DS
	  CLI                 ; 关闭中断
	  CALL    I8250       ; 初始化 8250 (串口)
	  CALL    I8259       ; 开放 8259A 辅串口中断
	  CALL    RD0B        ; 读中断向量
	  CALL    WR0B        ; 写中断向量
	  STI                 ; 允许中断
SCAN:
    CMP		FLAG, 1
	  JE		RETURN        ; 接收到 esc 则退出
	  MOV 	AH, 1
	  INT 	16H           ; 检测键盘缓冲区
	  JZ 		SCAN          ; 无字符输入则继续
	  MOV 	DX, 2FDH
	  IN 		AL, DX
	  TEST 	AL, 20H       ; 检测发送保持寄存器是否为空
	  JZ 		SCAN          ; 不为空则不发送
	  MOV 	AH, 0
	  INT 	16H 					; 为空则读取键盘缓冲区
	  AND 	AL, 7FH
	  MOV 	DX, 2F8H
	  OUT 	DX, AL        ; 并把数据写入发送缓冲区
	  CMP 	AL, 1BH
	  JNE 	SCAN          ; 继续接收下一个字符
LAST:
		MOV 	DX, 2FDH
		IN 		AL, DX
		TEST 	AL, 40H
		JZ 		LAST          ; 程序结束前确保内容发送完毕
RETURN:
		CALL 	RESET
		MOV 	AH, 4CH
		INT 	21H


; 初始化 8250 (串口)
; 主串口端口号 3F，实验室统一使用辅串口 2F 端口号
I8250 PROC
    MOV   DX, 2FBH
	  MOV   AL, 80H
	  OUT   DX, AL       ; 设置寻址位
	  MOV   DX, 2F9H
	  MOV   AL, 00H
	  OUT   DX, AL       ; 除数高位 (0060H，1200bps)
	  MOV   DX, 2F8H
	  MOV   AL, 60H
	  OUT   DX, AL        ; 除数低位 (0060H，1200bps)
	  MOV   DX, 2FBH
	  MOV   AL, 00000011B
	  OUT   DX, AL        ; 控制字 (8 位数据位，其他均无)
	  MOV   DX, 2F9H
	  MOV   AL, 01H
	  OUT   DX, AL        ; 中断允许寄存器 (发送为查询，接收为中断)
	  MOV   DX, 2FCH
	  MOV   AL, 0BH
	  OUT   DX, AL        ; 设置 MODEM (0B 允许中断，10H 内环自检)
	  RET
I8250 ENDP

; 开放 8259A 辅串口中断
I8259 PROC
    IN    AL, 21H
	  AND   AL, 11110111B
	  OUT   21H, AL
	  RET
I8259 ENDP

; 读中断向量
RD0B PROC
	  MOV   AX, 350BH
	  INT   21H
	  MOV   WORD PTR OLD0B, BX
	  MOV   WORD PTR OLD0B+2, ES
	  RET
RD0B ENDP

; 写中断向量
WR0B PROC
	  PUSH  DS
  	MOV   AX, CODE
	  MOV   DS, AX
	  MOV   DX, OFFSET RECEIVE
	  MOV   AX, 250BH
	  INT   21H
	  POP   DS
	  RET
WR0B ENDP

; 接收数据
RECEIVE PROC
	  PUSHA
	  PUSH    DS
	  MOV     AX, DATA
	  MOV     DS, AX
	  MOV     DX, 2F8H
	  IN      AL, DX      ; 读取接收缓冲器的内容
	  AND     AL, 7FH
	  CMP     AL, 1BH     ; 判断是否为退出字符 (esc 键)
	  JE      NEXT
  	MOV     AH, 2
  	MOV     DL, AL
  	INT     21H         ; 显示字符
  	JMP     EXIT
NEXT:
    MOV     FLAG, 1
EXIT:
    MOV     AL, 20H
	  OUT     20H, AL
	  POP     DS
	  POPA
	  IRET
RECEIVE ENDP

; 重置
RESET PROC 
	  IN    AL, 21H
	  OR    AL, 00001000B
  	OUT   21H, AL
  	MOV   DX, WORD PTR OLD0B
  	MOV   DS, WORD PTR OLD0B+2
  	MOV   AX, 250BH
  	INT   21H
  	RET
RESET ENDP

CODE ENDS
    END   BEG
