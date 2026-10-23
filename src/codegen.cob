       >>SOURCE FORMAT IS FREE
IDENTIFICATION DIVISION.
PROGRAM-ID. CODEGEN.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT ASM-FILE
        ASSIGN TO CG-OUTPUT-FILENAME
        ORGANIZATION IS LINE SEQUENTIAL
        FILE STATUS IS CG-FILE-STATUS.

DATA DIVISION.
FILE SECTION.
FD ASM-FILE.
01 CG-ASM-RECORD PIC X(256).

WORKING-STORAGE SECTION.
    01 CG-OUTPUT-FILENAME PIC X(256).
    01 CG-FILE-STATUS PIC XX.
    01 CG-OUT-LINE PIC X(256).
    01 CG-I PIC 9(4).
    01 CG-TEMP-EDIT PIC 9(4).
    01 CG-OPERAND PIC X(64).
    01 CG-REGISTER PIC X(4).
    01 CG-ADDRESS PIC X(80).
    01 CG-INSTRUCTION PIC X(16).
    01 CG-SET-INSTRUCTION PIC X(8).
    01 CG-SOURCE-NAME-LENGTH PIC 9(4).
    01 CG-BASE-LENGTH PIC 9(4).
    01 CG-OPEN-OK PIC X.
LINKAGE SECTION.
    COPY "compiler-state.cpy".
PROCEDURE DIVISION USING COMPILER-STATE.
MAIN-CODEGEN.
    MOVE SPACES TO CG-OUTPUT-FILENAME
    MOVE FUNCTION LENGTH(FUNCTION TRIM(CS-SOURCE-FILENAME TRAILING))
      TO CG-SOURCE-NAME-LENGTH
    IF CG-SOURCE-NAME-LENGTH < 7
        MOVE "Y" TO CS-ERROR-FLAG
        MOVE "Source filename must end in .cbimp." TO CS-ERROR-MESSAGE
        DISPLAY "CODEGEN ERROR: " FUNCTION TRIM(CS-ERROR-MESSAGE)
        GOBACK
    END-IF
    COMPUTE CG-BASE-LENGTH = CG-SOURCE-NAME-LENGTH - 6
    STRING CS-SOURCE-FILENAME(1:CG-BASE-LENGTH) DELIMITED BY SIZE
           ".asm" DELIMITED BY SIZE
           INTO CG-OUTPUT-FILENAME
    END-STRING
    OPEN OUTPUT ASM-FILE
    IF CG-FILE-STATUS NOT = "00"
        MOVE "Y" TO CS-ERROR-FLAG
        MOVE "Could not create assembly output file." TO CS-ERROR-MESSAGE
        DISPLAY "CODEGEN ERROR: unable to open output ("
          CG-FILE-STATUS ")."
        GOBACK
    END-IF

    MOVE "bits 64" TO CG-OUT-LINE PERFORM CG-WRITE-LINE
    MOVE "default rel" TO CG-OUT-LINE PERFORM CG-WRITE-LINE
    MOVE "global main" TO CG-OUT-LINE PERFORM CG-WRITE-LINE
    MOVE "extern printf" TO CG-OUT-LINE PERFORM CG-WRITE-LINE
    MOVE SPACES TO CG-OUT-LINE PERFORM CG-WRITE-LINE
    MOVE "section .data" TO CG-OUT-LINE PERFORM CG-WRITE-LINE
    MOVE 'fmt db "%ld", 10, 0' TO CG-OUT-LINE PERFORM CG-WRITE-LINE
    MOVE SPACES TO CG-OUT-LINE PERFORM CG-WRITE-LINE
    MOVE "section .bss" TO CG-OUT-LINE PERFORM CG-WRITE-LINE

    PERFORM VARYING CG-I FROM 1 BY 1 UNTIL CG-I > CS-SYMBOL-COUNT
        MOVE SPACES TO CG-OUT-LINE
        STRING "v_" DELIMITED BY SIZE
               FUNCTION TRIM(CS-SYMBOL-NAME(CG-I)) DELIMITED BY SIZE
               ": resq 1" DELIMITED BY SIZE
               INTO CG-OUT-LINE
        END-STRING
        PERFORM CG-WRITE-LINE
    END-PERFORM

    PERFORM VARYING CG-I FROM 1 BY 1 UNTIL CG-I > CS-TEMP-COUNT
        MOVE SPACES TO CG-OUT-LINE
        MOVE CG-I TO CG-TEMP-EDIT
        STRING "tmp_" DELIMITED BY SIZE
               CG-TEMP-EDIT DELIMITED BY SIZE
               ": resq 1" DELIMITED BY SIZE
               INTO CG-OUT-LINE
        END-STRING
        PERFORM CG-WRITE-LINE
    END-PERFORM

    MOVE SPACES TO CG-OUT-LINE PERFORM CG-WRITE-LINE
    MOVE "section .text" TO CG-OUT-LINE PERFORM CG-WRITE-LINE
    MOVE "main:" TO CG-OUT-LINE PERFORM CG-WRITE-LINE
    MOVE "    push rbp" TO CG-OUT-LINE PERFORM CG-WRITE-LINE
    MOVE "    mov rbp, rsp" TO CG-OUT-LINE PERFORM CG-WRITE-LINE

    PERFORM VARYING CG-I FROM 1 BY 1 UNTIL CG-I > CS-IR-COUNT
        IF CS-ERROR-FLAG = "Y"
            EXIT PERFORM
        END-IF
        EVALUATE TRUE
            WHEN FUNCTION TRIM(CS-IR-OP(CG-I)) = "MOV"
                MOVE CS-IR-ARG1(CG-I) TO CG-OPERAND
                MOVE "rax" TO CG-REGISTER
                PERFORM CG-LOAD-OPERAND
                MOVE CS-IR-RESULT(CG-I) TO CG-OPERAND
                PERFORM CG-BUILD-ADDRESS
                MOVE SPACES TO CG-OUT-LINE
                STRING "    mov [rel " DELIMITED BY SIZE
                       FUNCTION TRIM(CG-ADDRESS) DELIMITED BY SIZE
                       "], rax" DELIMITED BY SIZE
                       INTO CG-OUT-LINE
                END-STRING
                PERFORM CG-WRITE-LINE
            WHEN FUNCTION TRIM(CS-IR-OP(CG-I)) = "PRINT"
                MOVE CS-IR-ARG1(CG-I) TO CG-OPERAND
                MOVE "rsi" TO CG-REGISTER
                PERFORM CG-LOAD-OPERAND
                MOVE "    lea rdi, [rel fmt]" TO CG-OUT-LINE
                PERFORM CG-WRITE-LINE
                MOVE "    xor eax, eax" TO CG-OUT-LINE
                PERFORM CG-WRITE-LINE
                MOVE "    call printf" TO CG-OUT-LINE
                PERFORM CG-WRITE-LINE
            WHEN FUNCTION TRIM(CS-IR-OP(CG-I)) = "ADD"
              OR FUNCTION TRIM(CS-IR-OP(CG-I)) = "SUB"
              OR FUNCTION TRIM(CS-IR-OP(CG-I)) = "MUL"
              OR FUNCTION TRIM(CS-IR-OP(CG-I)) = "DIV"
              OR FUNCTION TRIM(CS-IR-OP(CG-I)) = "EQ"
              OR FUNCTION TRIM(CS-IR-OP(CG-I)) = "NE"
              OR FUNCTION TRIM(CS-IR-OP(CG-I)) = "LT"
              OR FUNCTION TRIM(CS-IR-OP(CG-I)) = "GT"
              OR FUNCTION TRIM(CS-IR-OP(CG-I)) = "LE"
              OR FUNCTION TRIM(CS-IR-OP(CG-I)) = "GE"
                MOVE CS-IR-ARG1(CG-I) TO CG-OPERAND
                MOVE "rax" TO CG-REGISTER
                PERFORM CG-LOAD-OPERAND
                MOVE CS-IR-ARG2(CG-I) TO CG-OPERAND
                MOVE "r10" TO CG-REGISTER
                PERFORM CG-LOAD-OPERAND
                EVALUATE FUNCTION TRIM(CS-IR-OP(CG-I))
                    WHEN "ADD" MOVE "    add rax, r10" TO CG-OUT-LINE
                    WHEN "SUB" MOVE "    sub rax, r10" TO CG-OUT-LINE
                    WHEN "MUL" MOVE "    imul rax, r10" TO CG-OUT-LINE
                    WHEN "DIV" MOVE "    cqo" TO CG-OUT-LINE
                    WHEN "EQ" MOVE "    cmp rax, r10" TO CG-OUT-LINE
                    WHEN "NE" MOVE "    cmp rax, r10" TO CG-OUT-LINE
                    WHEN "LT" MOVE "    cmp rax, r10" TO CG-OUT-LINE
                    WHEN "GT" MOVE "    cmp rax, r10" TO CG-OUT-LINE
                    WHEN "LE" MOVE "    cmp rax, r10" TO CG-OUT-LINE
                    WHEN "GE" MOVE "    cmp rax, r10" TO CG-OUT-LINE
                END-EVALUATE
                PERFORM CG-WRITE-LINE
                IF CS-IR-OP(CG-I) = "DIV"
                    MOVE "    idiv r10" TO CG-OUT-LINE
                    PERFORM CG-WRITE-LINE
                ELSE
                    IF CS-IR-OP(CG-I) = "EQ"
                        MOVE "sete al" TO CG-INSTRUCTION
                    ELSE
                        IF CS-IR-OP(CG-I) = "NE"
                            MOVE "setne al" TO CG-INSTRUCTION
                        ELSE
                            IF CS-IR-OP(CG-I) = "LT"
                                MOVE "setl al" TO CG-INSTRUCTION
                            ELSE
                                IF CS-IR-OP(CG-I) = "GT"
                                    MOVE "setg al" TO CG-INSTRUCTION
                                ELSE
                                    IF CS-IR-OP(CG-I) = "LE"
                                        MOVE "setle al" TO CG-INSTRUCTION
                                    ELSE
                                        IF CS-IR-OP(CG-I) = "GE"
                                            MOVE "setge al" TO CG-INSTRUCTION
                                        ELSE
                                            MOVE SPACES TO CG-INSTRUCTION
                                        END-IF
                                    END-IF
                                END-IF
                            END-IF
                        END-IF
                    END-IF
                    IF CG-INSTRUCTION NOT = SPACES
                        MOVE SPACES TO CG-OUT-LINE
                        STRING "    " DELIMITED BY SIZE
                               FUNCTION TRIM(CG-INSTRUCTION) DELIMITED BY SIZE
                               INTO CG-OUT-LINE
                        END-STRING
                        PERFORM CG-WRITE-LINE
                        MOVE "    movzx rax, al" TO CG-OUT-LINE
                        PERFORM CG-WRITE-LINE
                    END-IF
                END-IF
                MOVE CS-IR-RESULT(CG-I) TO CG-OPERAND
                PERFORM CG-BUILD-ADDRESS
                MOVE SPACES TO CG-OUT-LINE
                STRING "    mov [rel " DELIMITED BY SIZE
                       FUNCTION TRIM(CG-ADDRESS) DELIMITED BY SIZE
                       "], rax" DELIMITED BY SIZE
                       INTO CG-OUT-LINE
                END-STRING
                PERFORM CG-WRITE-LINE
            WHEN "IFZ"
                MOVE CS-IR-ARG1(CG-I) TO CG-OPERAND
                MOVE "rax" TO CG-REGISTER
                PERFORM CG-LOAD-OPERAND
                MOVE "    cmp rax, 0" TO CG-OUT-LINE
                PERFORM CG-WRITE-LINE
                MOVE SPACES TO CG-OUT-LINE
                STRING "    je " DELIMITED BY SIZE
                       FUNCTION TRIM(CS-IR-RESULT(CG-I)) DELIMITED BY SIZE
                       INTO CG-OUT-LINE
                END-STRING
                PERFORM CG-WRITE-LINE
            WHEN "JMP"
                MOVE SPACES TO CG-OUT-LINE
                STRING "    jmp " DELIMITED BY SIZE
                       FUNCTION TRIM(CS-IR-RESULT(CG-I)) DELIMITED BY SIZE
                       INTO CG-OUT-LINE
                END-STRING
                PERFORM CG-WRITE-LINE
            WHEN "LABEL"
                MOVE SPACES TO CG-OUT-LINE
                STRING FUNCTION TRIM(CS-IR-RESULT(CG-I)) DELIMITED BY SIZE
                       ":" DELIMITED BY SIZE
                       INTO CG-OUT-LINE
                END-STRING
                PERFORM CG-WRITE-LINE
            WHEN OTHER
                MOVE "Unknown IR operation in code generator." TO CS-ERROR-MESSAGE
                MOVE "Y" TO CS-ERROR-FLAG
        END-EVALUATE
    END-PERFORM

    MOVE "    xor eax, eax" TO CG-OUT-LINE PERFORM CG-WRITE-LINE
    MOVE "    pop rbp" TO CG-OUT-LINE PERFORM CG-WRITE-LINE
    MOVE "    ret" TO CG-OUT-LINE PERFORM CG-WRITE-LINE
    CLOSE ASM-FILE
    IF CG-FILE-STATUS NOT = "00"
        MOVE "Y" TO CS-ERROR-FLAG
        MOVE "Error while writing assembly file." TO CS-ERROR-MESSAGE
    END-IF
    IF CS-ERROR-FLAG = "N"
        MOVE CG-OUTPUT-FILENAME TO CS-ASM-FILENAME
        DISPLAY "Assembly generated: " FUNCTION TRIM(CS-ASM-FILENAME)
    END-IF
    GOBACK.

CG-LOAD-OPERAND.
    IF FUNCTION TEST-NUMVAL(FUNCTION TRIM(CG-OPERAND)) = 0
        MOVE SPACES TO CG-OUT-LINE
        STRING "    mov " DELIMITED BY SIZE
               FUNCTION TRIM(CG-REGISTER) DELIMITED BY SIZE
               ", " DELIMITED BY SIZE
               FUNCTION TRIM(CG-OPERAND) DELIMITED BY SIZE
               INTO CG-OUT-LINE
        END-STRING
    ELSE
        PERFORM CG-BUILD-ADDRESS
        MOVE SPACES TO CG-OUT-LINE
        STRING "    mov " DELIMITED BY SIZE
               FUNCTION TRIM(CG-REGISTER) DELIMITED BY SIZE
               ", [rel " DELIMITED BY SIZE
               FUNCTION TRIM(CG-ADDRESS) DELIMITED BY SIZE
               "]" DELIMITED BY SIZE
               INTO CG-OUT-LINE
        END-STRING
    END-IF
    PERFORM CG-WRITE-LINE.

CG-BUILD-ADDRESS.
    MOVE SPACES TO CG-ADDRESS
    IF CG-OPERAND(1:1) = "@"
        STRING "tmp_" DELIMITED BY SIZE
               CG-OPERAND(3:4) DELIMITED BY SIZE
               INTO CG-ADDRESS
        END-STRING
    ELSE
        STRING "v_" DELIMITED BY SIZE
               FUNCTION TRIM(CG-OPERAND) DELIMITED BY SIZE
               INTO CG-ADDRESS
        END-STRING
    END-IF.

CG-WRITE-LINE.
    WRITE CG-ASM-RECORD FROM CG-OUT-LINE
    MOVE SPACES TO CG-OUT-LINE.
