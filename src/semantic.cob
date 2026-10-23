       >>SOURCE FORMAT IS FREE
IDENTIFICATION DIVISION.
PROGRAM-ID. SEMANTIC.

DATA DIVISION.
WORKING-STORAGE SECTION.
    01 S-I PIC 9(4).
    01 S-J PIC 9(4).
    01 S-FOUND PIC X.
    01 S-NAME PIC X(64).
LINKAGE SECTION.
    COPY "compiler-state.cpy".
PROCEDURE DIVISION USING COMPILER-STATE.
MAIN-SEMANTIC.
    MOVE 0 TO CS-SYMBOL-COUNT
    MOVE "N" TO CS-ERROR-FLAG
    PERFORM VARYING S-I FROM 1 BY 1 UNTIL S-I > CS-AST-COUNT
        OR CS-ERROR-FLAG = "Y"
        EVALUATE FUNCTION TRIM(CS-AST-TYPE(S-I))
            WHEN "VAR-DECL"
                MOVE CS-AST-VALUE(S-I) TO S-NAME
                MOVE "N" TO S-FOUND
                PERFORM VARYING S-J FROM 1 BY 1
                    UNTIL S-J > CS-SYMBOL-COUNT
                    IF CS-SYMBOL-NAME(S-J) = S-NAME
                        MOVE "Y" TO S-FOUND
                    END-IF
                END-PERFORM
                IF S-FOUND = "Y"
                    MOVE "Y" TO CS-ERROR-FLAG
                    MOVE "Duplicate variable declaration: " TO CS-ERROR-MESSAGE
                    MOVE CS-AST-LINE(S-I) TO CS-ERROR-LINE
                    MOVE CS-AST-COLUMN(S-I) TO CS-ERROR-COLUMN
                    DISPLAY "SEMANTIC ERROR at line " CS-ERROR-LINE
                      ": variable '" FUNCTION TRIM(S-NAME) "' is already declared."
                ELSE
                    IF CS-SYMBOL-COUNT >= 1000
                        MOVE "Y" TO CS-ERROR-FLAG
                        MOVE "Symbol table capacity exceeded (1000 variables)." TO CS-ERROR-MESSAGE
                    ELSE
                        ADD 1 TO CS-SYMBOL-COUNT
                        MOVE S-NAME TO CS-SYMBOL-NAME(CS-SYMBOL-COUNT)
                    END-IF
                END-IF
            WHEN "ASSIGN"
                MOVE CS-AST-VALUE(S-I) TO S-NAME
                PERFORM S-FIND-SYMBOL
                IF S-FOUND = "N"
                    MOVE "Y" TO CS-ERROR-FLAG
                    MOVE "Assignment to undeclared variable." TO CS-ERROR-MESSAGE
                    MOVE CS-AST-LINE(S-I) TO CS-ERROR-LINE
                    MOVE CS-AST-COLUMN(S-I) TO CS-ERROR-COLUMN
                    DISPLAY "SEMANTIC ERROR at line " CS-ERROR-LINE
                      ": variable '" FUNCTION TRIM(S-NAME) "' is not declared."
                END-IF
            WHEN "IDENTIFIER"
                MOVE CS-AST-VALUE(S-I) TO S-NAME
                PERFORM S-FIND-SYMBOL
                IF S-FOUND = "N"
                    MOVE "Y" TO CS-ERROR-FLAG
                    MOVE "Use of undeclared variable." TO CS-ERROR-MESSAGE
                    MOVE CS-AST-LINE(S-I) TO CS-ERROR-LINE
                    MOVE CS-AST-COLUMN(S-I) TO CS-ERROR-COLUMN
                    DISPLAY "SEMANTIC ERROR at line " CS-ERROR-LINE
                      ": variable '" FUNCTION TRIM(S-NAME) "' is not declared."
                END-IF
            WHEN "INTEGER"
                IF FUNCTION LENGTH(
                     FUNCTION TRIM(CS-AST-VALUE(S-I))) > 18
                    MOVE "Y" TO CS-ERROR-FLAG
                    MOVE "Integer literals are limited to 18 decimal digits." TO CS-ERROR-MESSAGE
                    MOVE CS-AST-LINE(S-I) TO CS-ERROR-LINE
                    MOVE CS-AST-COLUMN(S-I) TO CS-ERROR-COLUMN
                    DISPLAY "SEMANTIC ERROR at line " CS-ERROR-LINE
                      ": integer literal exceeds 18 digits."
                END-IF
        END-EVALUATE
    END-PERFORM
    IF CS-ERROR-FLAG = "N"
        DISPLAY "Semantic analysis: passed ("
          CS-SYMBOL-COUNT " variables)."
    END-IF
    GOBACK.

S-FIND-SYMBOL.
    CALL "SYMBOL" USING COMPILER-STATE S-NAME S-FOUND.
