#STORING DATA 

#Import json files
import json


#Using json.dump() and json.load()

#Dump numbers list into json file

#~ numbers = [1,2,3,4,5]

#~ filename = 'numbers.json'

#~ with open(filename,'w') as jsonfile:
	#~ json.dump(numbers,jsonfile)


#Reload list from json into memory

#Open file
#~ with open(filename) as jsonFileLoad:
	#~ number = json.load(jsonFileLoad)

#~ #Print loaded file
#~ print (number)

#Saving and reading user generated data

##Saving user info from input
#~ username = input("What is your name: ")

#~ filename = 'users.json'

#~ with open(filename, 'w') as jsonUser:
	#~ json.dump(username, jsonUser)

#~ print ("We'll remember you when you come back")

##Reload user data
#~ filename = 'users.json'

#~ with open(filename) as jsonUserRead:
	#~ username = json.load(jsonUserRead)

#~ print("Hi "+username+" you're back")


#Combine and add error exceptions

filename = 'username.json'

try:
	
	with open(filename) as userRead:
		username = json.load(userRead)
	print("Welcome back "+username)

except:
	
	username = input("What is your name: ")
	
	with open(filename,'w') as userWrite:
		json.dump(username, userWrite)
	print("Thanks we'll remember you")



