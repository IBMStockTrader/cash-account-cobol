import requests
import urllib3
import json
from zowe.zos_files_for_zowe_sdk import Files

CONNECTION = {
    "host_url": "127.0.0.1",
    "user": "",
    "password": "",
    "ssl_verification": False
}

DATASET = 'SYSD.STOCK.RATES'
zos_files = Files(CONNECTION)

urllib3.disable_warnings()

def retrieve_sql_data():
    url = 'https://api.frankfurter.app/latest?from=USD'
    api_request = requests.request('GET', url, verify=False)
    response_load = json.loads(api_request.text)
    rates = response_load['rates']
    date = response_load['date']
    return rates, date

def generate_sql_statements(rates, date):
    # for key, value in rates.items():
    #     insert = "INSERT INTO DBSTAPP.FRANKFURT1\n"
    #     fields = " (CURRNKEY, CURRNBASE, AMOUNT, RATES, LOADDT)\n"
    #     values = f" VALUES('{key}', 'USD', 1.00, {value}, '{date}');\n"
    #     wait = "SET CURRENT QUERY ACCELERATION WAITFORDATA = 2.5;\n"
    #     separator = "----"
    #     statements.append(f"{insert}{fields}{values}{separator}{wait}{separator}\n")
    for key, value in rates.items():
        update = "UPDATE DBSTAPP.FRANKFURT1\n"
        fields = f" SET RATES={value}, LOADDT='{date}'\n"
        where = f" WHERE CURRNKEY='{key}';\n"
        # wait = "SET CURRENT QUERY ACCELERATION WAITFORDATA = 15.0;\n"
        wait = "\n"
        separator = "----"
        statements.append(f"{wait}{separator}\n{update}{fields}{where}{separator}\n")

if __name__ == "__main__":
    print("Starting...")
    rates, date = retrieve_sql_data()
    statements = list()
    print("Generating statements..")
    generate_sql_statements(rates, date)
    print("Writing to file")    
    with open('update_stock.txt', 'w') as f:
        for sql in statements:
            f.write(sql)

    print("Uploading to DSN...")
    print(zos_files.upload_file_to_dsn("update_stock.txt", DATASET))