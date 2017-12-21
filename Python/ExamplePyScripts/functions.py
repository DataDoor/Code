#Functions

#Basic functions
#~ def hello(name):
   #~ print("Hello "+name)
   

#~ hello('neil')


#Functions with default values

#~ def pet_details(pet_name,pet_type = 'dog'):

   #~ print('My pet is called '+pet_name+' and is a '+pet_type)
   
   
#~ pet_details('neil','cat')

#Remember the order of the parameters is inportant
#if we call the following it will return incorrect information

#~ print('\nIncorrect order of parameters')
#~ pet_details('dog','neil')

#You can explicitly name the parameters so the order is correct

#~ print('\nExplicitly passing the parameters')
#~ pet_details(pet_name = 'Cracker',pet_type = 'dog')
 
#RETURN Function

#This function will take the first and last name and ensure they are in
#a title format

#~ def name_parse(firstname, lastname):

    #~ fullname = firstname+' '+lastname

    #~ return fullname.title()
    

#Now we call the function and pass to values, one hasn't got capitals
#so the function should change this when called i.e. Prince Rogers.
    
#~ musician = name_parse('prince','Rogers')

#~ print(musician)

#Making an argument optional
#Sometimes there might not be a value therefore you simple default to any empty string

#~ def full_name_parse(firstname, lastname,middlename = ''):

#~ #Now we need to check if the middle name is used
    #~ if middlename is None:
        #~ fullname = firstname+' '+middlename+' '+lastname
    #~ else:
        #~ fullname = firstname+' '+lastname
	
    #~ return fullname.title()
	

#Call the full_name_parse function

#~ print('\nWith middlename')
#~ print(full_name_parse('neil','Gelder','grant'))

#~ print('\nWithout middlename')
#~ print(full_name_parse('neil','Gelder'))


#RETURING A DICTONARY


#~ def build_person(first_name, last_name):

    #~ person = {'first':first_name,'last':last_name}

    #~ return person
   
   
#~ person = build_person('Neil','Gelder')

#~ print(person)
#~ print(person['first'].title()+' '+person['last'].title())


#PASSING LIST TO FUNCTIONS
#Often you'll need to pass in lists of names to a function

#~ def greeting(names):
	#~ for name in names:
		#~ msg = "Hello and welcome "+name
		
		#~ print(msg.title())

#~ namelist = ['Neil','alex','miles']

#~ print(greeting(namelist))

#PASSING IN ARBITARARY NUMBER OF ARGUMENTS
#When you want to pass in the same type of value but unsure how many times

#~ def make_pizza(*toppings):
    #~ print("Your pizza will have the following toppings:")
    #~ for topping in toppings:
        #~ print (topping.title())
        
#~ print('\nFunction call with one topping')
#~ make_pizza('ham')

#~ print('\nFunction call with multiple toppings')
#~ make_pizza('ham','mushroom','pineapple')


#PASSING IN POSITIONAL AND ARBITARARY ARGUMENTS
#your able to pass in both type like below 

#~ def make_pizza(size,*toppings):
    #~ print("Your "+str(size)+" inch pizza will have the following toppings:")
    #~ for topping in toppings:
        #~ print (topping.title())
       
#~ print('\nFunction call with one topping')
#~ make_pizza(9,'ham')

#~ print('\nFunction call with multiple toppings')
#~ make_pizza(12,'ham','mushroom','pineapple')
    






