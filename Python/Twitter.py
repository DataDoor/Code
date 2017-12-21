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
twitter_access_token = '122365194-9QOZCeNPsX0P3f3DLAZomCOZUjCmuzwcAgslHJGF'
twitter_access_secret = 'MXo0sJECrWJa15JaiJTHuu3KaOTXzyyTaNgL2seFVy8TE'
twitter_consumer_key = 'RB3t1sJwOIT4z5VCp0IaxDaaq'
twitter_consumer_secret = 'fwIDUuaipptUqR50OQ9vuenNFff1jWj9Gj3nNQo2iQm8xIWSpl'


consumer = oauth.Consumer(key=twitter_consumer_key, secret=twitter_consumer_secret)
access_token = oauth.Token(key=twitter_access_token, secret=twitter_access_secret)
client = oauth.Client(consumer,access_token)


twitter_timeline_endpoint = 'https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=g3lder&count=2'

response, data = client.request(twitter_timeline_endpoint)

tweets = json.loads(data)
for tweet in tweets:
    print(data)