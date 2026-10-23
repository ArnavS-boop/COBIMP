<<<<<<< HEAD
       >>SOURCE FORMAT IS FREE
=======
>>SOURCE FORMAT IS FREE

>>>>>>> 53d6ddea4ca89eaa948a51b347e238418b2661c8
IDENTIFICATION DIVISION.
PROGRAM-ID. TOKEN.

DATA DIVISION.
<<<<<<< HEAD
WORKING-STORAGE SECTION.
    01 TK-I PIC 9(5).
LINKAGE SECTION.
    COPY "compiler-state.cpy".
PROCEDURE DIVISION USING COMPILER-STATE.
MAIN-TOKEN.
    DISPLAY "----- TOKENS -----"
    PERFORM VARYING TK-I FROM 1 BY 1 UNTIL TK-I > CS-TOKEN-COUNT
        DISPLAY TK-I " | type=" CS-TOKEN-KIND(TK-I)
          " | text=[" FUNCTION TRIM(CS-TOKEN-TEXT(TK-I)) "]"
          " | line=" CS-TOKEN-LINE(TK-I)
          " | column=" CS-TOKEN-COLUMN(TK-I)
    END-PERFORM
    DISPLAY "----- END TOKENS -----"
    GOBACK.
=======

WORKING-STORAGE SECTION.

    COPY "compiler-defs.cpy".

    01  TOKEN-TABLE.
        05  TOKEN-ENTRY OCCURS 100 TIMES.
            10  TOKEN-KIND       PIC 9(3).
            10  TOKEN-VALUE      PIC X(64).
            10  TOKEN-LINE       PIC 9(5).
            10  TOKEN-COLUMN     PIC 9(5).

    01  TOKEN-COUNT             PIC 9(3) VALUE 0.

PROCEDURE DIVISION.

    DISPLAY "Token module initialized.".

    STOP RUN.
>>>>>>> 53d6ddea4ca89eaa948a51b347e238418b2661c8
