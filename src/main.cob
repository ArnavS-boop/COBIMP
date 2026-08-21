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

    01 SOURCE-FILENAME PIC X(256).
    01 FILE-STATUS     PIC XX.
    01 SOURCE-DONE     PIC X VALUE "N".

    01 SOURCE-BUFFER   PIC X(10000).
    01 SOURCE-LENGTH   PIC 9(5) VALUE 0.
    01 LINE-LENGTH     PIC 9(4) VALUE 0.

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

                IF LINE-LENGTH > 0
                    MOVE SOURCE-LINE(1:LINE-LENGTH)
                        TO SOURCE-BUFFER(
                            SOURCE-LENGTH + 1:
                            LINE-LENGTH
                        )

                    ADD LINE-LENGTH TO SOURCE-LENGTH
                END-IF

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
        USING SOURCE-BUFFER SOURCE-LENGTH.

    DISPLAY "Compilation input complete.".

    STOP RUN.