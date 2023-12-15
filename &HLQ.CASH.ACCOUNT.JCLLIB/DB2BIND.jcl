//DB2BIND JOB (ACCT#),'BIND PROGRAMS',NOTIFY=&SYSUID,CLASS=A,
// MSGCLASS=H,MSGLEVEL=(1,1),SCHENV=<wlm-env>
//*
//* STOCK TRADER BINDS
//*
//BIND    EXEC PGM=IKJEFT01,DYNAMNBR=20
//STEPLIB  DD  DSN=SYS1.DSND00A.SDSNLOAD,DISP=SHR
//DBRMLIB  DD  DSN=SYSD.STOCK.DBRMLIB,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSTSPRT DD  SYSOUT=*
//SYSUDUMP DD  SYSOUT=*
//SYSIN  DD *
/*
//SYSTSIN DD *
DSN SYSTEM(DB2D)
BIND PACKAGE (STOCKTRD)                                    -
     ISO(CS)                                              -
     CURRENTDATA(NO)                                      -
     MEMBER(ACCT01)                                       -
     DEGREE(1)                                            -
     DYNAMICRULES(BIND)                                   -
     ACTION (REPLACE)                                     -
     EXPLAIN(NO)                                          -
     OWNER(KDLUDEV)                                      -
     QUALIFIER(STOCKTRD)                                   -
     ENABLE(BATCH,CICS)                                   -
     REL(DEALLOCATE)                                      -
     VALIDATE(BIND)

BIND PLAN (STOCKPL)                                       -
     PKLIST(NULLID.*, *.STOCKTRD.*)                        -
     CURRENTDATA(NO)                                      -
     ISO(CS)                                              -
     ACTION (REP)                                         -
     OWNER(KDLUDEV)                                      -
     QUALIFIER(STOCKTRD)                                   -
     REL(DEALLOCATE)                                      -
     ACQUIRE(USE)                                         -
     RETAIN                                               -
     NOREOPT(VARS)                                        -
     VALIDATE(BIND)

RUN PROGRAM(DSNTIAD) PLAN(DSNTIA10) -
    LIB('DB2D.RUNLIB.LOAD')
END
/*
