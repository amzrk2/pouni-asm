; FILENAME: EXA131.ASM - B18030620
.486

DATA SEGMENT USE16
    SUM   DB  ?, ?        ; ��ź� - XXXXH
    MESG  DB  '25+9='     ; ��ʽ��
          DB  0, 0, '$'   ; �����ַ�����β
    N1    DB  9           ; ������ 1 - 09H
    N2    DB  25          ; ������ 2 - 19H
DATA ENDS

CODE SEGMENT USE16
     ASSUME  CS:CODE, DS:DATA
BEG:
    ; ��ʼ�� DS
    MOV   AX, DATA
    MOV   DS, AX
    ; ȡ SUM ��ƫ�Ƶ�ַ�� BX
    MOV   BX, OFFSET SUM
    ; AH �� 09H��AL �� 19H
    MOV   AH, N1             ; AH - 0009H
    MOV   AL, N2             ; AL - 0019H
    ; ��Ӳ�������浽 SUM
    ADD   AH, AL
    MOV   [BX], AH           ; SUM - 0022H
    ; ������תʮ����
    CALL  CHANG
    ; ��ʾ
    MOV   AH, 9
    MOV   DX, OFFSET MESG
    INT   21H
    ; DOS �������
    MOV   AH, 4CH
    INT   21H

; �ӳ���
CHANG PROC
LAST:
	CMP  BYTE PTR [BX],10
	JC   NEXT                   ; С�� 10 ���Ѽ���ֻʣ��λ
	SUB  BYTE PTR [BX],10       ; SUM ÿ�� 10 ʮλ�ϵ����ֶ�Ӧ +1
	INC  BYTE PTR [BX+7]        ; [BX+7] �� MESG ��Ԥ���ĵ�һ�� 0 (ʮλ)
	JMP  LAST                   ; ѭ�������ϼ� 10
NEXT:
	MOV  AH, SUM                         ; SUM ��Ϊ��λ��
	MOV  BYTE PTR [BX+8], BYTE PTR AH    ; ��λ���ŵ� [BX+8]
	;MOV  BYTE PTR [BX+8], BYTE PTR SUM  ; ����ͬʱΪ�ڴ������
	ADD  BYTE PTR [BX+7], 30H            ; PTR ʮλ
	ADD  BYTE PTR [BX+8], 30H            ; PTR ��λ
	RET
CHANG ENDP

CODE ENDS
    END BEG