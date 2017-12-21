#Libaries
import pyodbc
import json
import twitter
import oauth2 as oauth




#Database connection to SQL Server
conn = pyodbc.connect(
    r'DRIVER={ODBC Driver 13 for SQL Server};'
    r'SERVER=localhost;'
    r'DATABASE=dumpDB;'
    r'UID=python;'
    r'PWD=Python'
    )

# Variables that contains the user credentials to access Twitter API 
twitter_access_token = 'xxxxxxxxxxxxxxxxxxxxxx'
twitter_access_secret = 'xxxxxxxxxxxxxxxxxxxxxx'
twitter_consumer_key = 'xxxxxxxxxxxxxxxxxxxxxx'
twitter_consumer_secret = 'xxxxxxxxxxxxxxxxxxxxxx'


consumer = oauth.Consumer(key=twitter_consumer_key, secret=twitter_consumer_secret)
access_token = oauth.Token(key=twitter_access_token, secret=twitter_access_secret)
client = oauth.Client(consumer,access_token)


twitter_timeline_endpoint = 'https://api.twitter.com/1.1/statuses/user_timeline.json?screen_namescreenname&count=1'

response, data = client.request(twitter_timeline_endpoint)

tweets = json.loads(data)
for tweet in tweets:
    tweetsdata = str(data)
    #print(tweetsdata)

    cursor = conn.cursor()    

    SQLCommand = ("INSERT INTO Twitter(TwitterJson) VALUES (?)")    
    Values = [tweetsdata]   

    #Processing Query    
    cursor.execute(SQLCommand,Values)     

    #Commiting any pending transaction to the database.    
    conn.commit()    

    #closing connection    
    print("Data Successfully Inserted")   

conn.close()  
