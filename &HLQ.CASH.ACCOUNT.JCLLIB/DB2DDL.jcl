//DB2DDL JOB (ACCT#),'DB2 create',NOTIFY=&SYSUID,CLASS=A,MSGCLASS=H,
// MSGLEVEL=(1,1),SCHENV=<wlm-env>
//JOBLIB   DD DSN=SYS1.DSND00A.SDSNLOAD,DISP=SHR
//*
//********************************************************************
//*   CREATE STORAGE GROUP/DATABASES/TABLESPACES                     *
//********************************************************************
//CREATE  EXEC PGM=IKJEFT01,DYNAMNBR=20
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
   DSN SYSTEM(DB2D)
   RUN  PROGRAM(DSNTIAD) PLAN(DSNTIAD) -
        LIB('DB2D.RUNLIB.LOAD')
//SYSPRINT DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//SYSIN    DD *
  SET CURRENT SQLID='DB2SUPT' ;
  CREATE   STOGROUP SGSTAPP VOLUMES ('*') VCAT DB2D;

  CREATE   DATABASE STOCKTRD STOGROUP SGSTAPP
           BUFFERPOOL BP1
           CCSID EBCDIC;
  CREATE   TABLESPACE TSSTAPP IN STOCKTRD
    USING STOGROUP SGSTAPP
      PRIQTY 10000
      SECQTY 5000
      ERASE  NO
    CLOSE NO
    CCSID EBCDIC
    BUFFERPOOL BP1;
/*
//* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//*  CREATE TABLES
//* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
//*
//CRTABS  EXEC PGM=IKJEFT01,DYNAMNBR=20 ,COND=(4,LT)
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
 DSN SYSTEM(DB2D)
 RUN  PROGRAM(DSNTIAD) PLAN(DSNTIAD) -
      LIB('DB2D.RUNLIB.LOAD')
//SYSPRINT DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//SYSIN    DD *
  SET CURRENT SQLID='DB2SUPT' ;
CREATE TABLE STOCKTRD.CASHACCOUNTY (
     owner 	  CHAR(32) NOT NULL,
     balance      NUMERIC(9,2),
     currencyc    CHAR(8),
   PRIMARY KEY(owner))
   CCSID EBCDIC
   IN STOCKTRD.TSSTAPP;

CREATE TABLE STOCKTRD.FRANKFURT1 (
     currnkey 	  CHAR(5) NOT NULL,
     currnbase    CHAR(5),
     amount       NUMERIC(9,2),
     rates        NUMERIC(3,2),
     loaddt       DATE NOT NULL,
   PRIMARY KEY(currnkey))
   CCSID EBCDIC
   IN STOCKTRD.TSSTAPP;
//*
//* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//*  GRANT DB2 TABLES ACCESSES
//* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
//*
//CRGRACC EXEC PGM=IKJEFT01,DYNAMNBR=20 ,COND=(4,LT)
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
 DSN SYSTEM(DB2D)
 RUN  PROGRAM(DSNTIAD) PLAN(DSNTIAD) -
      LIB('DB2D.RUNLIB.LOAD')
//SYSPRINT DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//SYSIN    DD *
  SET CURRENT SQLID='DB2SUPT' ;
  GRANT DBADM ON DATABASE STOCKTRD         TO PUBLIC;
  GRANT USE OF TABLESPACE STOCKTRD.TSSTAPP TO PUBLIC;
  GRANT ALL PRIVILEGES ON TABLE STOCKTRD.CASHACCOUNTY TO PUBLIC;
  GRANT ALL PRIVILEGES ON TABLE STOCKTRD.FRANKFURT1 TO PUBLIC;
/*
//* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//*  CREATE INDEXES
//* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
//*
//CRINDX EXEC PGM=IKJEFT01,DYNAMNBR=20 ,COND=(4,LT)
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
 DSN SYSTEM(DB2D)
 RUN  PROGRAM(DSNTIAD) PLAN(DSNTIAD) -
      LIB('DB2D.RUNLIB.LOAD')
//SYSPRINT DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//SYSIN    DD *
  SET CURRENT SQLID='DB2SUPT' ;
CREATE UNIQUE INDEX STOCKTRD.iCASHACCOUNTY
   ON STOCKTRD.CASHACCOUNTY (owner) CLUSTER
   COPY YES ;

CREATE UNIQUE INDEX STOCKTRD.iFRANKFURT1
   ON STOCKTRD.FRANKFURT1 (currnkey) CLUSTER
   COPY YES ;