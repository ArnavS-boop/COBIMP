>>SOURCE FORMAT IS FREE

IDENTIFICATION DIVISION.
PROGRAM-ID. TOKEN.

DATA DIVISION.

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