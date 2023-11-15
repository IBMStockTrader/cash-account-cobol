       IDENTIFICATION DIVISION.
       PROGRAM-ID. CASH00.

       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
             EXEC SQL
                 INCLUDE SQLCA
             END-EXEC.
             EXEC SQL
                 INCLUDE DCLCASH
              END-EXEC.
             EXEC SQL
                 INCLUDE DCLFRANK
              END-EXEC.
      *
       01 WS-CALC pic 9(7)V99.

       77 WS-CURRENCY-KEY  PIC X(5).
       77 WS-MSG           PIC X(50).
       77 WS-ASKTIME       PIC S9(15) COMP-3.
       77 WS-DATE          PIC X(08).
       77 WS-TIME          PIC X(06).
       77 WS-KEY-LGTH      PIC S9(4) COMP.
       77 WS-DATA-LGTH     PIC S9(4) COMP.
       77 BALANC-rate      PIC 9(8)V99 value zeros.

       01 BALANCE-GRP.
          02 BALANCE-CH PIC X(9).
          02 BALANCE-NM REDEFINES BALANCE-CH PIC S9(7)V9(2).



       01 CUST-NAME.
          02 CUST-NAME-LENGTH  PIC S9(4) COMP.
          02 CUST-NAME-TEXT    PIC X(32).

       01 WS-VSAM-RECORD.
          05 WS-VR-NAME        PIC X(15).
          05 WS-VR-DATE        PIC X(08).
          05 WS-VR-TIME        PIC X(06).
          05 WS-VR-REQ         PIC X(1).
          05 WS-VR-BALANCE     PIC 9(7)V99.
          05 WS-VR-CURRENCY    PIC X(8).
          05 WS-VR-RETCODE     PIC X(10).

       01 WS-VSAM-KEY.
          05 WS-VK-NAME        PIC X(15).
          05 WS-VK-DATE        PIC X(08).
          05 WS-VK-TIME        PIC X(06).


       01 WS-COMMAREA.
          05 WS-REQ           PIC X(1).
          05 WS-NAME          PIC X(15).
          05 WS-BALANCE       PIC 9(7)V99.
          05 WS-CURRENCY      PIC X(8).
          05 WS-RETCODE       PIC X(10).


       LINKAGE SECTION.
       01  DFHCOMMAREA.
          05 LK-COMMAREA   PIC X(1) OCCURS 1 to 32767 TIMES
             DEPENDING ON EIBCALEN.

       PROCEDURE DIVISION.

             MOVE DFHCOMMAREA(1:EIBCALEN) TO WS-COMMAREA

             DISPLAY 'REQ   :'   WS-REQ
             DISPLAY 'BAL   :'   WS-BALANCE
             DISPLAY 'NAME  :'   WS-NAME
             DISPLAY 'CURNCY:'   WS-CURRENCY

             MOVE WS-BALANCE    TO BALANCE
             MOVE WS-NAME       TO CUST-NAME-TEXT
             MOVE WS-CURRENCY   TO CURRENCYC
             MOVE SPACES        TO WS-RETCODE

             EXEC CICS ASKTIME ABSTIME (WS-ASKTIME) END-EXEC

             EXEC CICS FORMATTIME ABSTIME (WS-ASKTIME)
                  YYYYMMDD (WS-DATE)
                  TIME     (WS-TIME)
             END-EXEC
             DISPLAY 'DATE  :'   WS-DATE
             DISPLAY 'TIME  :'   WS-TIME

             EVALUATE WS-REQ
                   WHEN 'A'
                       PERFORM CASH-ACCT-ADD
                   WHEN 'Q'
                       PERFORM CASH-ACCT-READ
                   WHEN 'U'
                       PERFORM CASH-ACCT-UPDATE
                   WHEN 'X'
                       PERFORM CASH-ACCT-DELETE
                   WHEN 'C'
                       PERFORM CASH-ACCT-CREDIT
                   WHEN 'D'
                       PERFORM CASH-ACCT-DEBIT
             END-EVALUATE.

             MOVE SQLCODE       TO WS-RETCODE
             MOVE BALANCE       TO WS-BALANCE
             MOVE CURRENCYC     TO WS-CURRENCY

             MOVE WS-COMMAREA TO DFHCOMMAREA(1:EIBCALEN)


             MOVE WS-NAME       TO WS-VR-NAME
             MOVE WS-DATE       TO WS-VR-DATE
             MOVE WS-TIME       TO WS-VR-TIME
             MOVE WS-REQ        TO WS-VR-REQ
             MOVE WS-BALANCE    TO WS-VR-BALANCE
             MOVE WS-CURRENCY   TO WS-VR-CURRENCY
             MOVE SQLCODE       TO WS-VR-RETCODE

             MOVE WS-NAME       TO WS-VK-NAME
             MOVE WS-DATE       TO WS-VK-DATE
             MOVE WS-TIME       TO WS-VK-TIME

             EXEC CICS IGNORE CONDITION NOTOPEN END-EXEC
             EXEC CICS IGNORE CONDITION DUPREC  END-EXEC

             EXEC CICS WRITE FILE ('HISTORY')
                  FROM            (WS-VSAM-RECORD)
                  LENGTH          (LENGTH OF WS-VSAM-RECORD)
                  RIDFLD          (WS-VSAM-KEY)
                  KEYLENGTH       (LENGTH OF WS-VSAM-KEY)
             END-EXEC

             EXEC CICS RETURN END-EXEC
             EXIT.

       CASH-ACCT-READ.
           EXEC SQL
                SELECT owner,balance,currencyc
                INTO  :DCLCASHACCOUNTY
                FROM STOCKTRD.CASHACCOUNTY
                WHERE LOWER(Owner) = LOWER(:CUST-NAME-TEXT)
           END-EXEC.
           IF SQLCODE = 0
              MOVE OWNER TO WS-NAME
              MOVE BALANCE TO WS-BALANCE
              MOVE CURRENCYC TO WS-CURRENCY
              MOVE 'ACCOUNT QUERY SUCCESSFUL' TO WS-MSG
           ELSE
              MOVE 'ACCOUNT NOT PRESENT' TO WS-MSG
           END-IF.
       CASH-ACCT-ADD.
           EXEC SQL
               INSERT INTO STOCKTRD.CASHACCOUNTY(
	                   owner, balance, CURRENCYC)
	            VALUES (UPPER(:CUST-NAME-TEXT), :BALANCE, :WS-CURRENCY)
           END-EXEC.
           IF SQLCODE = 0
              MOVE CUST-NAME-TEXT TO WS-NAME
              MOVE 'ACCOUNT ADDED SUCCESSFULLY' TO WS-MSG
           ELSE
              MOVE 'ACCOUNT NOT ADDED' TO WS-MSG
           END-IF.

       CASH-ACCT-UPDATE.
           EXEC SQL
                SELECT owner,balance,currencyc
                INTO  :DCLCASHACCOUNTY
                FROM STOCKTRD.CASHACCOUNTY
                WHERE LOWER(Owner) = LOWER(:CUST-NAME-TEXT)
           END-EXEC.
           IF SQLCODE = 0
               MOVE WS-BALANCE   TO BALANCE

               EXEC SQL
                UPDATE STOCKTRD.CASHACCOUNTY
    	           SET  BALANCE=:BALANCE,
                        CURRENCYC=:WS-CURRENCY
    	           where UPPER(Owner) = UPPER(:CUST-NAME-TEXT)
               END-EXEC
              MOVE 'ACCOUNT UPDATED' TO WS-MSG
            ELSE
              MOVE 'ACCOUNT NOT PRESENT' TO WS-MSG
            END-IF.

       CASH-ACCT-DELETE.

           EXEC SQL
                SELECT OWNER,BALANCE,CURRENCYC
                INTO  :DCLCASHACCOUNTY
                FROM STOCKTRD.CASHACCOUNTY
                WHERE LOWER(OWNER) = LOWER(:CUST-NAME-TEXT)
           END-EXEC.

           IF SQLCODE = 0
               EXEC SQL
                DELETE FROM  STOCKTRD.CASHACCOUNTY
    	           WHERE LOWER(OWNER) = LOWER(:CUST-NAME-TEXT)
               END-EXEC
              MOVE 'ACCOUNT DELETED SUCCESSFUL' TO WS-MSG
            ELSE
              MOVE 'ACCOUNT NOT PRESENT' TO WS-MSG
            END-IF.

       CASH-ACCT-CREDIT.
           EXEC SQL
                SELECT OWNER,BALANCE,CURRENCYC
                INTO  :DCLCASHACCOUNTY
                FROM STOCKTRD.CASHACCOUNTY
                WHERE LOWER(Owner) = LOWER(:CUST-NAME-TEXT)
           END-EXEC.

           IF SQLCODE = 0
              MOVE CURRENCYC TO WS-CURRENCY-KEY
              EXEC SQL
              SELECT CURRNKEY,CURRNBASE,AMOUNT,RATES,LOADDT
                INTO  :DCLFRANKFURT1
                FROM STOCKTRD.FRANKFURT1 WHERE CURRNKEY =
                :WS-CURRENCY-KEY
             END-EXEC

             MOVE WS-BALANCE   TO BALANC-RATE
             COMPUTE WS-CALC = BALANCE + (RATES * BALANC-RATE)
             END-COMPUTE

             MOVE WS-CALC TO BALANCE

             EXEC SQL
               UPDATE STOCKTRD.CASHACCOUNTY
	                SET  BALANCE=:BALANCE
	                WHERE UPPER(OWNER) = UPPER(:CUST-NAME-TEXT)
             END-EXEC

             MOVE 'ACCOUNT CREDITED' TO WS-MSG
             ELSE
                MOVE 'ACCOUNT NOT CREDITED' TO WS-MSG
             END-IF.

       CASH-ACCT-DEBIT.

           EXEC SQL
                SELECT owner,balance,currencyc
                INTO  :DCLCASHACCOUNTY
                FROM STOCKTRD.CASHACCOUNTY
                WHERE LOWER(Owner) = LOWER(:CUST-NAME-TEXT)
           END-EXEC.
           IF SQLCODE = 0
              MOVE CURRENCYC TO WS-CURRENCY-KEY
              EXEC SQL
              SELECT CURRNKEY,CURRNBASE,AMOUNT,RATES,LOADDT
                INTO  :DCLFRANKFURT1
                FROM STOCKTRD.FRANKFURT1 where CURRNKEY =
                :WS-CURRENCY-KEY
             END-EXEC

             MOVE WS-BALANCE   TO BALANC-RATE
             COMPUTE WS-CALC = BALANCE - (RATES * BALANC-rate)
             END-COMPUTE

             MOVE WS-CALC TO BALANCE
             EXEC SQL
            UPDATE STOCKTRD.CASHACCOUNTY
	           SET  balance=:BALANCE
	           where UPPER(Owner) = UPPER(:CUST-NAME-TEXT)
           END-EXEC

           MOVE 'ACCOUNT DEBITED' TO WS-MSG
           ELSE
              MOVE 'ACCOUNT NOT DEBITED' TO WS-MSG
           END-IF.
