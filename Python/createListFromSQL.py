##IMPORT REQURIED PYTHON LIBRARIES  
import pyodbc

##CREATE CONNECTION TO SQL SERVER DATABASE

conn = pyodbc.connect(
    r'DRIVER={ODBC Driver 13 for SQL Server};'
    r'SERVER=localhost;'
    r'DATABASE=dumpDB;'
    r'UID=python;'
    r'PWD=Python') 

#OPEN DATABASE CONNECTION
print('Opening dbConnection')
cursor = conn.cursor() 



#Extract SubmissionID data
submissionSQLCommand = ("SELECT SubmissionID FROM ScholarOne.Submissions")
                
#Process query 
cursor.execute(submissionSQLCommand)
submissionData = cursor.fetchall ()
submissionIDList = []

for row in submissionData:
    submissionIDList.append(row[0])


for subid in submissionIDList:
    print(subid)



#CLOSE DATABASE CONNECTION
print('Close dbConnection')
conn.close()