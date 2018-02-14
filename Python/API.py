
##IMPORT REQURIED PYTHON LIBRARIES  

import requests
from requests.auth import HTTPBasicAuth 
import pyodbc

##CREATE CONNECTION TO SQL SERVER DATABASE

conn = pyodbc.connect(
    r'DRIVER={ODBC Driver 13 for SQL Server};'
    r'SERVER=localhost;'
    r'DATABASE=dumpDB;'
    r'UID=python;'
    r'PWD=Python'
    ) 

##SET VARIABLES

url = 'http://alfuat.emerald.ixxus.io/alfresco/s/emerald/Cases/people'
apiuser = 'integration'
apipass = 'integration'


##CALL GET API

print('Call GET API - {0}'.format(url))
r = requests.get(url, auth=HTTPBasicAuth(apiuser, apipass))

#REPLACE UTF-8 WITH UTF-16, THIS IS REQUIRED AS SQL SERVER ONLY ACCEPTS UTF-16
xmlString = str(r.text).replace("UTF-8","UTF-16")

#OPEN DATABASE CONNECTION
print('Opening dbConnection')
cursor = conn.cursor() 


#CREATE SQL STATEMENT FOR INSERTING XML INTO TABLE
SQLCommand = ("INSERT INTO APIXMLTest(XMLData) VALUES (?)")
Values = [xmlString]
            

#PROCESSING QUERY    
cursor.execute(SQLCommand,Values)  

#COMMIT TRANSACTION TO DATABASE 
conn.commit() 


#CLOSE DATABASE CONNECTION.
print('Close dbConnection')
conn.close()   





