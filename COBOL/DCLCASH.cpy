      ******************************************************************
      * DCLGEN TABLE(STOCKTRD.CASHACCOUNTY)                            *
      *        LIBRARY(SYSD.STOCK.COBOL)                               *
      *        LANGUAGE(COBOL)                                         *
      *        QUOTE                                                   *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE STOCKTRD.CASHACCOUNTY TABLE
           ( OWNER                          CHAR(32) NOT NULL,
             BALANCE                        DECIMAL(9, 2),
             CURRENCYC                      CHAR(8)
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE DBSTAPP.CASHACCOUNTY               *
      ******************************************************************
       01  DCLCASHACCOUNTY.
           10 OWNER                PIC X(32).
           10 BALANCE              PIC S9(7)V9(2) USAGE COMP-3.
           10 CURRENCYC            PIC X(8).
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 3       *
      ******************************************************************
