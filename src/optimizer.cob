       >>SOURCE FORMAT IS FREE
IDENTIFICATION DIVISION.
PROGRAM-ID. OPTIMIZER.

DATA DIVISION.
WORKING-STORAGE SECTION.
    01 O-I PIC 9(4).
    01 O-J PIC 9(4).
    01 O-CONST-COUNT PIC 9(4).
    01 O-CONSTANTS.
       05 O-CONSTANT OCCURS 5000 TIMES.
          10 O-CONST-NAME PIC X(64).
          10 O-CONST-VALUE PIC X(64).
    01 O-A PIC S9(18) COMP-5.
    01 O-B PIC S9(18) COMP-5.
    01 O-RESULT PIC S9(18) COMP-5.
    01 O-EDIT PIC -9(18).
    01 O-VALUE-TEXT PIC X(64).
    01 O-IS-NUMERIC-1 PIC X.
    01 O-IS-NUMERIC-2 PIC X.
    01 O-FOLD PIC X.
LINKAGE SECTION.
    COPY "compiler-state.cpy".
PROCEDURE DIVISION USING COMPILER-STATE.
MAIN-OPTIMIZER.
    MOVE 0 TO O-CONST-COUNT
    INITIALIZE O-CONSTANTS
    PERFORM VARYING O-I FROM 1 BY 1 UNTIL O-I > CS-IR-COUNT
        PERFORM O-SUBSTITUTE-ARG1
        PERFORM O-SUBSTITUTE-ARG2
        MOVE "N" TO O-FOLD
        IF CS-IR-OP(O-I) = "ADD"
           OR CS-IR-OP(O-I) = "SUB"
           OR CS-IR-OP(O-I) = "MUL"
           OR CS-IR-OP(O-I) = "DIV"
           OR CS-IR-OP(O-I) = "EQ"
           OR CS-IR-OP(O-I) = "NE"
           OR CS-IR-OP(O-I) = "LT"
           OR CS-IR-OP(O-I) = "GT"
           OR CS-IR-OP(O-I) = "LE"
           OR CS-IR-OP(O-I) = "GE"
            IF FUNCTION TEST-NUMVAL(
                 FUNCTION TRIM(CS-IR-ARG1(O-I))) = 0
               AND FUNCTION TEST-NUMVAL(
                 FUNCTION TRIM(CS-IR-ARG2(O-I))) = 0
                COMPUTE O-A = FUNCTION NUMVAL(
                    FUNCTION TRIM(CS-IR-ARG1(O-I)))
                COMPUTE O-B = FUNCTION NUMVAL(
                    FUNCTION TRIM(CS-IR-ARG2(O-I)))
                MOVE 0 TO O-RESULT
                EVALUATE CS-IR-OP(O-I)
                    WHEN "ADD"
                        COMPUTE O-RESULT = O-A + O-B
                            ON SIZE ERROR MOVE "Y" TO O-FOLD
                        END-COMPUTE
                    WHEN "SUB"
                        COMPUTE O-RESULT = O-A - O-B
                            ON SIZE ERROR MOVE "Y" TO O-FOLD
                        END-COMPUTE
                    WHEN "MUL"
                        COMPUTE O-RESULT = O-A * O-B
                            ON SIZE ERROR MOVE "Y" TO O-FOLD
                        END-COMPUTE
                    WHEN "DIV"
                        IF O-B = 0
                            MOVE "Y" TO CS-ERROR-FLAG
                            MOVE "Constant division by zero." TO CS-ERROR-MESSAGE
                            DISPLAY "OPTIMIZATION ERROR: constant division by zero."
                        ELSE
                            COMPUTE O-RESULT = O-A / O-B
                                ON SIZE ERROR MOVE "Y" TO O-FOLD
                            END-COMPUTE
                        END-IF
                    WHEN "EQ"
                        IF O-A = O-B MOVE 1 TO O-RESULT END-IF
                    WHEN "NE"
                        IF O-A NOT = O-B MOVE 1 TO O-RESULT END-IF
                    WHEN "LT"
                        IF O-A < O-B MOVE 1 TO O-RESULT END-IF
                    WHEN "GT"
                        IF O-A > O-B MOVE 1 TO O-RESULT END-IF
                    WHEN "LE"
                        IF O-A <= O-B MOVE 1 TO O-RESULT END-IF
                    WHEN "GE"
                        IF O-A >= O-B MOVE 1 TO O-RESULT END-IF
                END-EVALUATE
                IF O-RESULT > 999999999999999999
                   OR O-RESULT < -999999999999999999
                    MOVE "Y" TO O-FOLD
                END-IF
                IF CS-ERROR-FLAG = "N" AND O-FOLD = "N"
                    MOVE O-RESULT TO O-EDIT
                    MOVE FUNCTION TRIM(O-EDIT) TO O-VALUE-TEXT
                    MOVE "MOV" TO CS-IR-OP(O-I)
                    MOVE O-VALUE-TEXT TO CS-IR-ARG1(O-I)
                    MOVE SPACES TO CS-IR-ARG2(O-I)
                    MOVE "Y" TO O-FOLD
                END-IF
            END-IF
        END-IF
        IF CS-IR-OP(O-I) = "MOV"
           AND CS-IR-RESULT(O-I)(1:1) = "@"
           AND FUNCTION TEST-NUMVAL(
               FUNCTION TRIM(CS-IR-ARG1(O-I))) = 0
            IF O-CONST-COUNT < 5000
                ADD 1 TO O-CONST-COUNT
                MOVE CS-IR-RESULT(O-I) TO O-CONST-NAME(O-CONST-COUNT)
                MOVE CS-IR-ARG1(O-I) TO O-CONST-VALUE(O-CONST-COUNT)
            END-IF
        END-IF
    END-PERFORM
    IF CS-ERROR-FLAG = "N"
        DISPLAY "Optimization: constant folding and temporary propagation complete."
    END-IF
    GOBACK.

O-SUBSTITUTE-ARG1.
    IF CS-IR-ARG1(O-I)(1:1) = "@"
        PERFORM VARYING O-J FROM 1 BY 1 UNTIL O-J > O-CONST-COUNT
            IF CS-IR-ARG1(O-I) = O-CONST-NAME(O-J)
                MOVE O-CONST-VALUE(O-J) TO CS-IR-ARG1(O-I)
                EXIT PERFORM
            END-IF
        END-PERFORM
    END-IF.

O-SUBSTITUTE-ARG2.
    IF CS-IR-ARG2(O-I)(1:1) = "@"
        PERFORM VARYING O-J FROM 1 BY 1 UNTIL O-J > O-CONST-COUNT
            IF CS-IR-ARG2(O-I) = O-CONST-NAME(O-J)
                MOVE O-CONST-VALUE(O-J) TO CS-IR-ARG2(O-I)
                EXIT PERFORM
            END-IF
        END-PERFORM
    END-IF.
