'''
Author: Neil Gelder
Date created: 02/10/2018

This Py script is used to convert the data received
in and Excel Sheet to a table in seleted database

'''

import pandas as pd
import sqlalchemy as sqla
import sys


#VARIABLES REQUIRED FOR CONVERSION

#DB
sqlinstance = ""
database = ""
sqlalconnectionstring = f'mssql+pyodbc://{sqlinstance}/{database}?driver=SQL+Server+Native+Client+11.0?trusted_connection=yes'

#EXCEL
excelwb = r''
excelwbsheet = ""



try:

    #READ EXCEL SHEET
    df = pd.read_excel(excelwb, excelwbsheet)


    #TRANFORM DATA INTO STAGING TABLES

    #Create engine
    engine = sqla.create_engine(sqlalconnectionstring)

    #Move data into Temp table
    df.to_sql('TMSBookData', con=engine,if_exists = 'replace',index=False)

   
except: 
    print('Export failed')





