; FILENAME: EXA132.ASM - B18030620
.486

DATA SEGMENT USE16
    COUNT  DB  0         ; ���ͳ�ƽ�� - 00H
    BUF    DB  '3BBC4$'  ; Ԥ�жϵ��ַ���
DATA ENDS

CODE SEGMENT USE16
     ASSUME  CS:CODE, DS:DATA
BEG:
    ; ��ʼ�� DS
    MOV   AX, DATA
    MOV   DS, AX
    ; ��ʼ���±�
    MOV   SI, 0
    ; ���ÿλ�ַ�
    CALL  TESTER
    ; ��ʾ
    MOV   AH, 9
    MOV   DX, OFFSET BUF
    INT   21H
    MOV   DL, 0AH
    MOV   AH, 2
    INT   21H
    MOV   BL, COUNT
    CALL  DISPLAY
    ; DOS �������
    MOV   AH, 4CH
    INT   21H

; �Ƚ��ӳ���
TESTER PROC
COMPARE:
    CMP  BUF[SI], '$'
    JE   NEXT               ; �ѽ���
    CMP  BUF[SI], 42H
    JB   ISNOT              ; ���� 42H
    CMP  BUF[SI], 45H
    JA   ISNOT              ; ���� 45H
    ; �ڷ�Χ��
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

; ��������ʾ�ӳ���
; ��ʾ���� - BL
DISPLAY PROC
    ; �����ֳ� - START
    PUSH  AX
    PUSH  BX
    PUSH  CX
    PUSH  DX
    ; �����ֳ� - END
    MOV   CX, 8   ; �԰�λ��������ʾ
SHOW:
    MOV   DL, '0'
    RCL   BL, 1   ; ��һλ
    JNC   DISP
    MOV   DL, '1'
DISP:
    MOV   AH, 2   ; DOS ���ܵ���
    INT   21H
    LOOP  SHOW
    MOV   DL, ' '
    MOV   AH, 2   ; DOS ���ܵ���
    INT   21H
    ; �ָ��ֳ� - START
    POP   DX
    POP   CX
    POP   BX
    POP   AX
    ; �ָ��ֳ� - END
    RET
DISPLAY ENDP

CODE ENDS
    END BEG