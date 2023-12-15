# Stock Trader App

## High level architectural diagram

<img src="/Images/architecture-diagram.png">

# Mainframe Cash Account

## Synopsis

This GitHub Repository contain the details of the Mainframe Cash Account application developed as an extension of StockTrader App running on Cloud.

## Solution Design

<!-- <img src="/Images/CashAccount.png"> -->
<img src="/Images/CashAccount-ExchangeRates.png">

## Cash Account description

Kyndryl Stocktrader Cash Account Microservice prototype made using Spring running native on Cloud. As Part of Stock Trader App expansion to integrate with Mainframe environment it was refactored using z/OS Cobol to run under CICS Transaction Services.

This service uses IBM DB2 on z/OS to keep track of accounts and for storing currency rates.

### IBM DB2 Tables

DB2        | Tables       | Comments
-----------|--------------|-------------
DB2        | CASHACCOUNTY | Contains information for Owner, Balance and Currency
DB2        | FRANKFURT1   | Contains information for currency rates
DB2        | PORTIFOLIO   | Contains information for portifolio total
DB2        | STOCK        | Contains information for what stock each account owns

* DB2 DDL for CASHACCOUNTY [here](&HLQ.DDL.SOURCE/CASHACCOUNTY.ddl)
* DB2 DDL for FRANKFURT1 [here](&HLQ.DDL.SOURCE/FRANKFURT1.ddl)
* DB2 DDL for PORTIFOLIO [here](&HLQ.DDL.SOURCE/PORTIFOLIO.ddl)
* DB2 DDL for STOCK [here](&HLQ.DDL.SOURCE/STOCK.ddl)
* DB2 Sample JCL to run DDL [here](&HLQ.CASH.ACCOUNT.JCLLIB/DB2DDL.jcl)

### IBM CICS Resources

CICS Region  | Resource       | Comments
-------------|----------------|-------------
CICS         | DB2Transaction | DB2 Transaction called MAC1 , using DB2 Entry DB2DLU2 and DB2 Plan STOCKPL
CICS         | Program        | COBOL Program called MACP01

* CICS Cobol program [here](&HLQ.COBOL.SOURCE/MACP01.cbl)
* DB2 DCL for CASHACCOUNTY table [here](&HLQ.COBOL.SOURCE/DCLCASH.cbl)
* DB2 DCL for FRANKFURT1 table [here](&HLQ.COBOL.SOURCE/DCLFRANK.cbl)

### IBM z/OS Connect

zCEE Server   | Resource       | Comments
--------------|----------------|-------------
z/OS Connect  | Service        | z/OS Connect that defines what program and CICS region the service will connect
z/OS Connect  | API            | z/OS Connect API definitions for each Cash Account operation

The following operations are available:

```http
GET  /cash-account/{owner} - gets account data from a specific owner
PUT  /cash-account/{owner} - updates the account of a specific owner
PUT  /cash-account/{owner}/debit  - subtracts money (USD) from a specific owner's account
PUT  /cash-account/{owner}/credit - adds money (USD) from a specific owner's account
POST /cash-account/{owner} - creates an account
DELETE /cash-account/{owner} - deletes the account of a specific owner
```

### Microsoft API Management

z/OS Connect APIs were imported into Azure API Management tool to centralize the access for it.

```http
GET  /cash-account/{owner} - gets account data from a specific owner
PUT  /cash-account/{owner} - updates the account of a specific owner
PUT  /cash-account/{owner}/debit  - subtracts money (USD) from a specific owner's account
PUT  /cash-account/{owner}/credit - adds money (USD) from a specific owner's account
POST /cash-account/{owner} - creates an account
DELETE /cash-account/{owner} - deletes the account of a specific owner
```

### Exchange Rates update

For the exchange rate DB2 tables updates we are using the Frankfurter app. Frankfurter is an open-source API for current and historical foreign exchange rates published by the European Central Bank.

Frankfurter app documentation can be found at: `https://www.frankfurter.app/`

In order to update the DB2 table, a Python script was created to retrieve the exchange rates thru the Frankfurter app API and format a series of SQL Statements that are executed thru DSNTEP2 batch program.

* Python Script [here](./Exchange_rates/rates.py)
* JCL [here](&HLQ.CASH.ACCOUNT.JCLLIB/CAUPDATE.jcl)

### Account History

Every action executed thru Stock Trader App to create, delete, update, credit, debit and query is recorded by the CICS Cobol application into a z/OS VSAM KSDS file located at CICSD2F region.

The data is stored using the following format:

```cobol
       01 WS-COMMAREA.                       
          05 WS-REQ           PIC X(1).      
          05 WS-NAME          PIC X(15).     
          05 WS-BALANCE       PIC 9(7)V99.   
          05 WS-CURRENCY      PIC X(8).      
          05 WS-RETCODE       PIC X(10).     
```

The VSAM file is then virtualized using Rocket Data Virtualization tool located on LBD1 z/OS LPAR.
The Virtual table is them exposed thru JDBC Connection and z/OS Connect API.

## License

[Kyndryl Intellectual Property](https://github.kyndryl.net/Continuous-Engineering/CE-Documentation/blob/master/files/LICENSE.md)