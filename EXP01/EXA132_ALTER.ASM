; FILENAME: EXA132_ALTER.ASM - B18030620
.486

DATA SEGMENT USE16
    COUNT  DB  0         ; 存放统计结果 - 00H
    BUF    DB  '3BBC4$'  ; 预判断的字符串
DATA ENDS

CODE SEGMENT USE16
     ASSUME  CS:CODE, DS:DATA
BEG:
    ; 初始化 DS
    MOV   AX, DATA
    MOV   DS, AX
    ; BUF 偏移地址保存到 BX
    MOV   BX, OFFSET BUF
    ; 初始化下标
    MOV   SI, 0
    ; 检查每位字符
    CALL  TESTER
    ; 显示
    MOV   AH, 9
    MOV   DX, OFFSET BUF
    INT   21H
    MOV   DL, 0AH
    MOV   AH, 2
    INT   21H
    MOV   BL, COUNT
    CALL  DISPLAY
    ; DOS 程序结束
    MOV   AH, 4CH
    INT   21H

; 比较子程序
TESTER PROC
COMPARE:
    CMP  BYTE PTR [BX+SI], '$'
    JE   NEXT               ; 已结束
    CMP  BYTE PTR [BX+SI], 42H
    JB   ISNOT              ; 低于 42H
    CMP  BYTE PTR [BX+SI], 45H
    JA   ISNOT              ; 高于 45H
    ; 在范围内
    JMP  IS
ISNOT:
    INC  SI
    JMP  COMPARE
IS:
    INC  SI
    INC  COUNT
    JMP  COMPARE
NEXT:
    RET
TESTER ENDP

; 二进制显示子程序
; 显示内容 - BL
DISPLAY PROC
    ; 保护现场 - START
    PUSH  AX
    PUSH  BX
    PUSH  CX
    PUSH  DX
    ; 保护现场 - END
    MOV   CX, 8   ; 以八位二进制显示
SHOW:
    MOV   DL, '0'
    RCL   BL, 1   ; 移一位
    JNC   DISP
    MOV   DL, '1'
DISP:
    MOV   AH, 2   ; DOS 功能调用
    INT   21H
    LOOP  SHOW
    MOV   DL, ' '
    MOV   AH, 2   ; DOS 功能调用
    INT   21H
    ; 恢复现场 - START
    POP   DX
    POP   CX
    POP   BX
    POP   AX
    ; 恢复现场 - END
    RET
DISPLAY ENDP

CODE ENDS
    END BEG
