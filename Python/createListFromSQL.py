##IMPORT REQURIED PYTHON LIBRARIES  
import pyodbc

##CREATE CONNECTION TO SQL SERVER DATABASE

conn = pyodbc.connect(
    r'DRIVER={ODBC Driver 13 for SQL Server};'
    r'SERVER=localhost;'
    r'DATABASE=dumpDB;'
    r'Trusted_Connection=yes;'

#OPEN DATABASE CONNECTION
print('Opening dbConnection')
cursor = conn.cursor() 



#Extract SubmissionID data
submissionSQLCommand = ("SELECT column FROM table")
                
#Process query 
cursor.execute(submissionSQLCommand)
columndata = cursor.fetchall ()
columndataList = []

for row in columndata:
    columndataList.append(row[0])


for did in columndataList:
    print(did)



#CLOSE DATABASE CONNECTION
print('Close dbConnection')
conn.close()