
       01  TOKEN-TYPE.
           05  TOKEN-EOF              PIC 9(3) VALUE 000.
           05  TOKEN-IDENTIFIER       PIC 9(3) VALUE 001.
           05  TOKEN-INTEGER          PIC 9(3) VALUE 002.

           05  TOKEN-LET              PIC 9(3) VALUE 010.
           05  TOKEN-IF               PIC 9(3) VALUE 011.
           05  TOKEN-ELSE             PIC 9(3) VALUE 012.
           05  TOKEN-WHILE           PIC 9(3) VALUE 013.
           05  TOKEN-PRINT            PIC 9(3) VALUE 014.

           05  TOKEN-PLUS             PIC 9(3) VALUE 020.
           05  TOKEN-MINUS            PIC 9(3) VALUE 021.
           05  TOKEN-MULTIPLY         PIC 9(3) VALUE 022.
           05  TOKEN-DIVIDE           PIC 9(3) VALUE 023.

           05  TOKEN-ASSIGN           PIC 9(3) VALUE 030.
           05  TOKEN-EQUAL            PIC 9(3) VALUE 031.
           05  TOKEN-NOT-EQUAL        PIC 9(3) VALUE 032.
           05  TOKEN-LESS             PIC 9(3) VALUE 033.
           05  TOKEN-GREATER          PIC 9(3) VALUE 034.
           05  TOKEN-LESS-EQUAL       PIC 9(3) VALUE 035.
           05  TOKEN-GREATER-EQUAL    PIC 9(3) VALUE 036.

           05  TOKEN-LPAREN           PIC 9(3) VALUE 040.
           05  TOKEN-RPAREN           PIC 9(3) VALUE 041.
           05  TOKEN-LBRACE           PIC 9(3) VALUE 042.
           05  TOKEN-RBRACE           PIC 9(3) VALUE 043.
           05  TOKEN-SEMICOLON        PIC 9(3) VALUE 044.
