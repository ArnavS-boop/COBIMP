       01 COMPILER-STATE.
          05 CS-TOKEN-COUNT                 PIC 9(5).
          05 CS-TOKEN-TABLE.
             10 CS-TOKEN-ENTRY OCCURS 10001 TIMES.
                15 CS-TOKEN-KIND            PIC 9(3).
                15 CS-TOKEN-TEXT            PIC X(64).
                15 CS-TOKEN-LINE            PIC 9(5).
                15 CS-TOKEN-COLUMN          PIC 9(5).
          05 CS-AST-COUNT                   PIC 9(4).
          05 CS-AST-ROOT                    PIC 9(4).
          05 CS-AST-NODES.
             10 CS-AST-NODE OCCURS 5000 TIMES.
                15 CS-AST-TYPE              PIC X(12).
                15 CS-AST-VALUE             PIC X(64).
                15 CS-AST-LEFT              PIC 9(4).
                15 CS-AST-RIGHT             PIC 9(4).
                15 CS-AST-THIRD             PIC 9(4).
                15 CS-AST-NEXT              PIC 9(4).
                15 CS-AST-FIRST              PIC 9(4).
                15 CS-AST-LINE               PIC 9(5).
                15 CS-AST-COLUMN             PIC 9(5).
          05 CS-SYMBOL-COUNT                PIC 9(4).
          05 CS-SYMBOLS.
             10 CS-SYMBOL OCCURS 1000 TIMES.
                15 CS-SYMBOL-NAME           PIC X(64).
          05 CS-IR-COUNT                    PIC 9(4).
          05 CS-IR-TABLE.
             10 CS-IR-ENTRY OCCURS 5000 TIMES.
                15 CS-IR-OP                 PIC X(8).
                15 CS-IR-ARG1               PIC X(64).
                15 CS-IR-ARG2               PIC X(64).
                15 CS-IR-RESULT              PIC X(64).
          05 CS-TEMP-COUNT                  PIC 9(4).
          05 CS-LABEL-COUNT                 PIC 9(4).
          05 CS-ERROR-FLAG                  PIC X.
          05 CS-ERROR-MESSAGE               PIC X(160).
          05 CS-ERROR-LINE                  PIC 9(5).
          05 CS-ERROR-COLUMN                PIC 9(5).
          05 CS-SOURCE-FILENAME              PIC X(256).
          05 CS-ASM-FILENAME                 PIC X(256).
          05 CS-ASM-STATUS                   PIC XX.
