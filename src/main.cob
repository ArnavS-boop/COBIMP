<<<<<<< HEAD
       >>SOURCE FORMAT IS FREE
=======
>>SOURCE FORMAT IS FREE

>>>>>>> 53d6ddea4ca89eaa948a51b347e238418b2661c8
IDENTIFICATION DIVISION.
PROGRAM-ID. COBIMP.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
<<<<<<< HEAD
=======

>>>>>>> 53d6ddea4ca89eaa948a51b347e238418b2661c8
    SELECT SOURCE-FILE
        ASSIGN TO SOURCE-FILENAME
        ORGANIZATION IS LINE SEQUENTIAL
        FILE STATUS IS FILE-STATUS.

DATA DIVISION.
<<<<<<< HEAD
FILE SECTION.
=======

FILE SECTION.

>>>>>>> 53d6ddea4ca89eaa948a51b347e238418b2661c8
FD SOURCE-FILE.
01 SOURCE-LINE PIC X(1000).

WORKING-STORAGE SECTION.
<<<<<<< HEAD
    COPY "compiler-state.cpy".

    01 SOURCE-FILENAME PIC X(256).
    01 FILE-STATUS PIC XX.
    01 SOURCE-DONE PIC X.
    01 SOURCE-BUFFER PIC X(10000).
    01 SOURCE-LENGTH PIC 9(5).
    01 LINE-LENGTH PIC 9(4).
    01 IR-MODE PIC X.

PROCEDURE DIVISION.
MAIN.
    INITIALIZE COMPILER-STATE
    MOVE "N" TO CS-ERROR-FLAG
    MOVE SPACES TO SOURCE-FILENAME SOURCE-BUFFER
    MOVE 0 TO SOURCE-LENGTH
    MOVE "N" TO SOURCE-DONE

    DISPLAY "COBIMP compiler starting."
    ACCEPT SOURCE-FILENAME FROM COMMAND-LINE
=======

    01 TOKEN-COUNT        PIC 9(3).

    01 TOKEN-TABLE.
        05 TOKEN-ENTRY OCCURS 100 TIMES.
            10 TOKEN-KIND     PIC 9(3).
            10 TOKEN-TEXT     PIC X(64).
            10 TOKEN-LINE     PIC 9(5).
            10 TOKEN-COLUMN   PIC 9(5).

    01 SOURCE-FILENAME PIC X(256).
    01 FILE-STATUS     PIC XX.
    01 SOURCE-DONE     PIC X VALUE "N".

    01 SOURCE-BUFFER   PIC X(10000).
    01 SOURCE-LENGTH   PIC 9(5) VALUE 0.
    01 LINE-LENGTH     PIC 9(4) VALUE 0.

    01 CURRENT-TOKEN PIC 9(3).

PROCEDURE DIVISION.

    DISPLAY "COBIMP compiler starting...".

    ACCEPT SOURCE-FILENAME FROM COMMAND-LINE.

>>>>>>> 53d6ddea4ca89eaa948a51b347e238418b2661c8
    IF SOURCE-FILENAME = SPACES
        DISPLAY "Usage: cobimp <source.cbimp>"
        MOVE 1 TO RETURN-CODE
        STOP RUN
<<<<<<< HEAD
    END-IF
    MOVE SOURCE-FILENAME TO CS-SOURCE-FILENAME
    DISPLAY "Source: " FUNCTION TRIM(SOURCE-FILENAME)

    OPEN INPUT SOURCE-FILE
    IF FILE-STATUS NOT = "00"
        DISPLAY "Error: could not open source file ("
          FILE-STATUS ")."
        MOVE 1 TO RETURN-CODE
        STOP RUN
    END-IF

    PERFORM UNTIL SOURCE-DONE = "Y"
        READ SOURCE-FILE
            AT END
                MOVE "Y" TO SOURCE-DONE
            NOT AT END
                MOVE FUNCTION LENGTH(
                    FUNCTION TRIM(SOURCE-LINE TRAILING))
                    TO LINE-LENGTH
                IF SOURCE-LENGTH + LINE-LENGTH + 1 > 10000
                    DISPLAY "Error: source file exceeds 10000 characters."
                    CLOSE SOURCE-FILE
                    MOVE 1 TO RETURN-CODE
                    STOP RUN
                END-IF
                IF LINE-LENGTH > 0
                    MOVE SOURCE-LINE(1:LINE-LENGTH)
                      TO SOURCE-BUFFER(SOURCE-LENGTH + 1:LINE-LENGTH)
                    ADD LINE-LENGTH TO SOURCE-LENGTH
                END-IF
                MOVE X"0A" TO SOURCE-BUFFER(SOURCE-LENGTH + 1:1)
                ADD 1 TO SOURCE-LENGTH
        END-READ
    END-PERFORM
    CLOSE SOURCE-FILE

    DISPLAY "Source loaded: " SOURCE-LENGTH " characters."
    CALL "LEXER" USING
        SOURCE-BUFFER
        SOURCE-LENGTH
        CS-TOKEN-COUNT
        CS-TOKEN-TABLE

    IF CS-TOKEN-COUNT = 0
        DISPLAY "Compilation stopped during lexical analysis."
        MOVE 1 TO RETURN-CODE
        STOP RUN
    END-IF
    DISPLAY "Lexical analysis: passed ("
      CS-TOKEN-COUNT " tokens, including EOF)."
    CALL "TOKEN" USING COMPILER-STATE

    CALL "PARSER" USING COMPILER-STATE
    IF CS-ERROR-FLAG = "Y"
        CALL "COBIMP-ERROR" USING COMPILER-STATE
        MOVE 1 TO RETURN-CODE
        STOP RUN
    END-IF
    DISPLAY "Syntax analysis: passed."

    CALL "AST" USING COMPILER-STATE
    CALL "SEMANTIC" USING COMPILER-STATE
    IF CS-ERROR-FLAG = "Y"
        CALL "COBIMP-ERROR" USING COMPILER-STATE
        MOVE 1 TO RETURN-CODE
        STOP RUN
    END-IF

    CALL "TAC" USING COMPILER-STATE
    IF CS-ERROR-FLAG = "Y"
        CALL "COBIMP-ERROR" USING COMPILER-STATE
        MOVE 1 TO RETURN-CODE
        STOP RUN
    END-IF
    MOVE "R" TO IR-MODE
    CALL "IR" USING COMPILER-STATE IR-MODE

    CALL "OPTIMIZER" USING COMPILER-STATE
    IF CS-ERROR-FLAG = "Y"
        CALL "COBIMP-ERROR" USING COMPILER-STATE
        MOVE 1 TO RETURN-CODE
        STOP RUN
    END-IF
    MOVE "O" TO IR-MODE
    CALL "IR" USING COMPILER-STATE IR-MODE

    CALL "CODEGEN" USING COMPILER-STATE
    IF CS-ERROR-FLAG = "Y"
        CALL "COBIMP-ERROR" USING COMPILER-STATE
        MOVE 1 TO RETURN-CODE
        STOP RUN
    END-IF

    DISPLAY "Compilation completed successfully."
    STOP RUN.
=======
    END-IF.

    DISPLAY "Source: " SOURCE-FILENAME.

    OPEN INPUT SOURCE-FILE.

    IF FILE-STATUS NOT = "00"
        DISPLAY "Error: could not open source file."
        DISPLAY "File status: [" FILE-STATUS "]"
        MOVE 1 TO RETURN-CODE
        STOP RUN
    END-IF.

    MOVE SPACES TO SOURCE-BUFFER.
    MOVE 0 TO SOURCE-LENGTH.

    PERFORM UNTIL SOURCE-DONE = "Y"

        READ SOURCE-FILE

            AT END
                MOVE "Y" TO SOURCE-DONE

           NOT AT END
           
               MOVE FUNCTION LENGTH(
                   FUNCTION TRIM(SOURCE-LINE)
               ) TO LINE-LENGTH
           
               IF SOURCE-LENGTH + LINE-LENGTH + 1 > 10000
                   DISPLAY "Error: source file is too large."
                   CLOSE SOURCE-FILE
                   MOVE 1 TO RETURN-CODE
                   STOP RUN
               END-IF
           
               MOVE FUNCTION TRIM(SOURCE-LINE)
                   TO SOURCE-BUFFER(
                       SOURCE-LENGTH + 1:
                       LINE-LENGTH
                   )
           
               ADD LINE-LENGTH TO SOURCE-LENGTH
           
               MOVE X"0A"
                   TO SOURCE-BUFFER(SOURCE-LENGTH + 1:1)
           
               ADD 1 TO SOURCE-LENGTH

        END-READ

    END-PERFORM.

    CLOSE SOURCE-FILE.

    DISPLAY "Source loaded: "
            SOURCE-LENGTH
            " characters.".

CALL "LEXER"
    USING
        SOURCE-BUFFER
        SOURCE-LENGTH
        TOKEN-COUNT
        TOKEN-TABLE.
  
    DISPLAY "----- TOKENS RECEIVED BY MAIN -----".

    PERFORM VARYING CURRENT-TOKEN
        FROM 1 BY 1
        UNTIL CURRENT-TOKEN > TOKEN-COUNT

        DISPLAY
            "MAIN TOKEN "
            CURRENT-TOKEN
            " | Type="
            TOKEN-KIND(CURRENT-TOKEN)
            " | Text=["
            FUNCTION TRIM(TOKEN-TEXT(CURRENT-TOKEN))
            "]"

    END-PERFORM.

    DISPLAY "----- END TOKENS -----".

*> DISPLAY "----- SOURCE BUFFER -----".
*> DISPLAY SOURCE-BUFFER.
*> DISPLAY "----- END SOURCE BUFFER -----".

>>CALL "LEXER"
>>    USING SOURCE-BUFFER SOURCE-LENGTH.

    DISPLAY "Compilation input complete.".

    STOP RUN.
>>>>>>> 53d6ddea4ca89eaa948a51b347e238418b2661c8
