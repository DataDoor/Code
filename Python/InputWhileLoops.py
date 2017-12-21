"""
INPUT AND WHILE LOOPS
"""

#Basic input command string
#~ message = input("Tell me something: ")

#~ print('\n'+message)

#As the input() function holds everything as a string you need to convert
#any numerical data to a number if you want to carry out a comparison 
#to conver the value you can use the int() function 

#Take age as input
#~ age = input("Please enter your name: ")
 
#~ age = int(age)

#Testing age input, comparting the data unless convert to int will result in
#an error.

#~ height = input("Please enter your age: ")

#~ if int(height) < 6:
    #~ print("Sorry to small")
#~ else:
    #~ print("Ok")
    
    
    
#Modulo operator
#This can be used to determine of a value is diviserble by another value

#~ number = 2

#~ if number % 10 == 0:
	#~ print(str(number) +" is an even number")
#~ else:
    #~ print(str(number) +" is an odd number")


#WHILE LOOPS
#like most programming languages a while loop will loop around until to values match
#below is an example of an infinate match, so will run forever as it impossible to break

#~ while 1==1:
    #~ print(1)

#Normal Loop, this will loop around until the value is equal to 5

#
#~ number = 1

#~ print("Loop started")
#~ while number <= 5:
   #~ print(number)
   #~ number +=1
#~ print("Loop Completed")



#User input to quit


#~ prompt = input(

#~ "Tell me your age and I'll repeat this till you type 'quit'")

#~ message = ''

#~ while message != 'quit':
    #~ print(prompt)
    #~ message = input()
    
    
#Using break withing a loop
#This will make the loop break when the value is met

#~ while True:
	#~ prompt = input("Please enter a name of a city you've visited: ")
	#~ city = prompt
	
	#~ if city == 'quit':
	   #~ break
	#~ else:
		#~ print("Nice city to visit "+city)
	

#Using continue in a loop

#~ current_number = 0

#~ while current_number < 10:
    #~ current_number += 1
    #~ if current_number % 2 == 0:
        #~ continue
    #~ print(current_number)


#USING LOOPS WITH LISTS

#~ unconfirmed_users = ['Neil','Alex','Miles']
#~ confirmed_users = []

#~ while unconfirmed_users:
	#~ current_user = unconfirmed_users.pop()
	
	#~ print("Verifying users: "+current_user)
	#~ confirmed_users.append(current_user)

#Display all users
#~ print('\nVERIFIED USERS')

#for loop to print confirmed users
#~ for users in sorted(confirmed_users):
	#~ print(users.title())


#REMOVE FROM LIST IN WHILE LOOP

#~ print('\nPets List')
#~ pets = ['cat','dog','cat','rabbit']

#~ print('\nPets list before loop')
#~ print(pets)

#~ removepet = 'cat'

#~ while removepet in pets:
	#~ pets.remove(removepet)

#~ print('\nPets list after loop (cats removed)')
#~ print(pets)
	

#POPULATING DICTIONART WITH WHILE LOOP

responses = {}

#Set a flag to indicate polling is active

polling_active = True

while polling_active:
    name = input("What is your name?: ")
    response = input("Where do you live?: ")
    
    #Store responses
    responses['name'] = name
    responses['response'] = response
    
    print(responses)
    
    for name, response in responses.items():
        print (response)
    
    






