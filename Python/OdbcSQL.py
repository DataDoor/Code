import pyodbc


conn = pyodbc.connect(
    r'DRIVER={ODBC Driver 13 for SQL Server};'
    r'SERVER=localhost;'
    r'DATABASE=dumpDB;'
    r'UID=python;'
    r'PWD=Python'
    )

print("Enter any value")    
value =input()    

cursor = conn.cursor()    

SQLCommand = ("INSERT INTO Twitter(TwitterJson) VALUES (?)")    
Values = [value]   

#Processing Query    
cursor.execute(SQLCommand,Values)     

#Commiting any pending transaction to the database.    
conn.commit()    

#closing connection    
print("Data Successfully Inserted")   
conn.close()  
