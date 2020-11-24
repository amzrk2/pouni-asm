.MODEL    SMALL
.486
CODE      SEGMENT USE16
          ASSUME CS:CODE

BEG:      JMP  START
CCONPORT  EQU  213H          ; 控制口地址
CCONBIT1  EQU  00010110B     ; 计数器 0 控制字
CCONBIT2  EQU  01010110B     ; 计数器 1 控制字
CCONBIT3  EQU  10010110B     ; 计数器 2 控制字
CDPORT1   EQU  210H          ; 计数器 0 数据端口地址
CDPORT2   EQU  211H          ; 计数器 1 数据端口地址
CDPORT3   EQU  212H          ; 计数器 2 数据端口地址
CHDBIT1   EQU  00H           ; 100kHz / 65536 = 1.5Hz
CHDBIT2   EQU  250           ; 10kHz  / 250   = 40Hz
CHDBIT3   EQU  100           ; 1kHz   / 100   = 10Hz

START:    NOP                ; 启动延时
          MOV  DX, CCONPORT  ; 写入控制字 0
          MOV  AL, CCONBIT1
          OUT  DX, AL
          MOV  DX, CDPORT1   ; 写入初值 0
          MOV  AL, CHDBIT1
          OUT  DX, AL

          MOV  DX, CCONPORT  ; 写入控制字 1
          MOV  AL, CCONBIT2
          OUT  DX, AL
          MOV  DX, CDPORT2   ; 写入初值 1
          MOV  AL, CHDBIT2
          OUT  DX, AL

          MOV  DX, CCONPORT  ; 写入控制字 2
          MOV  AL, CCONBIT3
          OUT  DX, AL
          MOV  DX, CDPORT3   ; 写入初值 2
          MOV  AL, CHDBIT3
          OUT  DX, AL

WT:       NOP
          JMP  WT

CODE      ENDS
          END  BEG
