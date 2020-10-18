; FILENAME: EXA200.ASM - B18030620
.586

DATA SEGMENT USE16
    MESGU   DB 'ENTER YOUR USERNAME: $'
    MESGUN  DB 'USERNAME NOT EXIST IN DATABASE!$'
    MESGP   DB 'ENTER YOUR PASSWORD: $'
    MESGPN  DB 'WRONG PASSWORD!$'
    ; Ϊ 0AH Ԥ�����ݽṹ
    USER    DB 100
            DB ?
            DB 100 DUP(?)
    PASS    DB 100 DUP(?)
DATA ENDS
EDATA SEGMENT USE16
    USERD   DB 'B18030620'
    USERDL  EQU $-USERD
    PASSD   DB '123456'
    PASSDL  EQU $-PASSD
    WELCOME DB 'WELCOME'
    LL      EQU $-WELCOME
EDATA ENDS

CODE SEGMENT USE16
    ASSUME CS:CODE, DS:DATA, ES:EDATA ; ES �����ַ����Ƚ�

BEG:
    MOV  AX, DATA
    MOV  DS, AX
    MOV  AX, EDATA
    MOV  ES, AX

CUSER:
    ; ENTER YOUR USERNAME
    MOV  AH, 9
    MOV  DX, OFFSET MESGU
    INT  21H
    ; �ȴ�����
    MOV  AH, 0AH
    MOV  DX, OFFSET USER
    INT  21H
    CALL CRLF
    ; �Ƚ��û���
    MOV  CX, USERDL                  ; ѭ������Ϊ����
    CLD                              ; ����ַ
    ; �ַ����Ƚ� DS:[SI] �� ES:[DI]
    MOV  DI, OFFSET USERD            ; USERD �ַ�����ַ
    MOV  SI, OFFSET USER+2           ; USER �ַ�����ַ
    REPE CMPSB                       ; �ַ����Ƚ�
    JZ   RTUSER                      ; ������� RTUSER
    ; USERNAME NOT EXIST IN DATABASE
    MOV  AH, 9
    MOV  DX, OFFSET MESGUN
    INT  21H
    CALL CRLF
    JMP  CUSER

RTUSER:
    ; ENTER YOUR PASSWORD
    MOV  AH, 9
    MOV  DX, OFFSET MESGP
    INT  21H
    MOV  SI, 0         ; SI ��Ϊ�±����볤��
PWLOOP:
    ; �ȴ���������
    ;MOV  AH, 1         ; �л��ԣ�������
    MOV  AH, 8
    INT  21H
    CMP  AL, 0DH       ; ����ǲ��ǻس�
    JE   CPASS         ; �ǻس���ʼ�ж�
    MOV  PASS[SI], AL  ; ���򱣴���һλ
    INC  SI            ; �������볤������
    MOV  AH, 2         ; ��ʾһ���Ǻ�
    MOV  DL, '*'
    INT  21H
    JMP  PWLOOP        ; ��������
CPASS:
    CALL CRLF
    ; �Ƚ�����
    MOV  CX, PASSDL                  ; ѭ������Ϊ����
    CLD                              ; ����ַ
    ; �ַ����Ƚ� DS:[SI] �� ES:[DI]
    MOV  DI, OFFSET PASSD            ; PASSD �ַ�����ַ
    MOV  SI, OFFSET PASS             ; PASS �ַ�����ַ
    REPE CMPSB                       ; �ַ����Ƚ�
    JZ   RTPASS                      ; ������� RTPASS
    ; WRONG PASSWORD
    MOV  AH, 9
    MOV  DX, OFFSET MESGPN
    INT  21H
    CALL CRLF
    JMP  RTUSER

RTPASS:
    CALL WELC

RETURN:
    MOV  AH, 4CH
    INT  21H

; ����
CRLF PROC
    PUSH AX
    PUSH DX
    MOV  AH, 2
    MOV  DL, 0DH
    INT  21H
    MOV  AH, 2
    MOV  DL, 0AH
    INT  21H
    POP  DX
    POP  AX
    RET
CRLF ENDP

; ��ӭ��Ļ
WELC PROC
    MOV  AX, 1301H
    MOV  BH, 0
    MOV  BL, 01001111B
    MOV  CX, LL
    MOV  DH, 11
    MOV  DL, (80-LL)/2
    MOV  BP, OFFSET WELCOME
    INT  10H
    MOV  CX, USERDL
    MOV  DH, 13
    MOV  DL, (80-USERDL)/2
    MOV  BP, OFFSET USERD
    INT  10H
    RET
WELC ENDP

CODE ENDS
    END BEG