; FILENAME: EXA200.ASM - B18030620
.586

DATA SEGMENT USE16
    MESGU   DB 'ENTER YOUR USERNAME: $'
    MESGUN  DB 'USERNAME NOT EXIST IN DATABASE!$'
    MESGP   DB 'ENTER YOUR PASSWORD: $'
    MESGPN  DB 'WRONG PASSWORD!$'
    ; 为 0AH 预置数据结构
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
    ASSUME CS:CODE, DS:DATA, ES:EDATA ; ES 用于字符串比较

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
    ; 等待输入
    MOV  AH, 0AH
    MOV  DX, OFFSET USER
    INT  21H
    CALL CRLF
    ; 比较用户名
    MOV  CX, USERDL                  ; 循环次数为长度
    CLD                              ; 增地址
    ; 字符串比较 DS:[SI] 和 ES:[DI]
    MOV  DI, OFFSET USERD            ; USERD 字符串地址
    MOV  SI, OFFSET USER+2           ; USER 字符串地址
    REPE CMPSB                       ; 字符串比较
    JZ   RTUSER                      ; 相等跳到 RTUSER
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
    MOV  SI, 0         ; SI 作为下标密码长度
PWLOOP:
    ; 等待输入密码
    ;MOV  AH, 1         ; 有回显，调试用
    MOV  AH, 8
    INT  21H
    CMP  AL, 0DH       ; 检查是不是回车
    JE   CPASS         ; 是回车则开始判断
    MOV  PASS[SI], AL  ; 否则保存这一位
    INC  SI            ; 并且密码长度自增
    MOV  AH, 2         ; 显示一个星号
    MOV  DL, '*'
    INT  21H
    JMP  PWLOOP        ; 继续输入
CPASS:
    CALL CRLF
    ; 比较密码
    MOV  CX, PASSDL                  ; 循环次数为长度
    CLD                              ; 增地址
    ; 字符串比较 DS:[SI] 和 ES:[DI]
    MOV  DI, OFFSET PASSD            ; PASSD 字符串地址
    MOV  SI, OFFSET PASS             ; PASS 字符串地址
    REPE CMPSB                       ; 字符串比较
    JZ   RTPASS                      ; 相等跳到 RTPASS
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

; 换行
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

; 欢迎屏幕
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
