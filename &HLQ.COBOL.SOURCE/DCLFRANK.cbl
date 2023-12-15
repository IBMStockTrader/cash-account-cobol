      ******************************************************************
      * DCLGEN TABLE(STOCKTRD.FRANKFURT1)                              *
      *        LIBRARY(SYSD.STOCK.COBOL.FFURT1)                        *
      *        LANGUAGE(COBOL)                                         *
      *        QUOTE                                                   *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE STOCKTRD.FRANKFURT1 TABLE
           ( CURRNKEY                       CHAR(5) NOT NULL,
             CURRNBASE                      CHAR(5),
             AMOUNT                         DECIMAL(9, 2),
             RATES                          DECIMAL(3, 2),
             LOADDT                         DATE NOT NULL
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE DBSTAPP.FRANKFURT1                 *
      ******************************************************************
       01  DCLFRANKFURT1.
           10 CURRNKEY             PIC X(5).
           10 CURRNBASE            PIC X(5).
           10 AMOUNT               PIC S9(7)V9(2) USAGE COMP-3.
           10 RATES                PIC S9(1)V9(2) USAGE COMP-3.
           10 LOADDT               PIC X(10).
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 5       *
      ******************************************************************
