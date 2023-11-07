//DEFKSDS JOB (P0L1),'STOCK TRADER KSDS',MSGCLASS=A,CLASS=A,
// MSGLEVEL=(1,1),REGION=0M,NOTIFY=&SYSUID.,SYSAFF=ANY
//****
//* DEFINE VSAM KSDS FILE FOR STOCK TRADER APP
//****
//STEPNAME EXEC PGM=IDCAMS
//SYSPRINT DD   SYSOUT=*
//SYSIN    DD   *
    DEFINE CLUSTER (NAME(SYSD.STOCK.HISTORY)                -
                    INDEXED                                 -
                    RECSZ(100 100)                          -
                    CYLINDERS(150,50)                       -
                    SHAREOPTIONS(2 3)                       -
                    KEYS(29 0))                             -
            DATA (NAME(SYSD.STOCK.HISTORY.DATA))            -
            INDEX (NAME(SYSD.STOCK.HISTORY.INDEX))
/*