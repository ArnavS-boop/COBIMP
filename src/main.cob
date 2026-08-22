>>SOURCE FORMAT IS FREE

IDENTIFICATION DIVISION.
PROGRAM-ID. COBIMP.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.

    SELECT SOURCE-FILE
        ASSIGN TO SOURCE-FILENAME
        ORGANIZATION IS LINE SEQUENTIAL
        FILE STATUS IS FILE-STATUS.

DATA DIVISION.

FILE SECTION.

FD SOURCE-FILE.
01 SOURCE-LINE PIC X(1000).

WORKING-STORAGE SECTION.

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

    IF SOURCE-FILENAME = SPACES
        DISPLAY "Usage: cobimp <source.cbimp>"
        MOVE 1 TO RETURN-CODE
        STOP RUN
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