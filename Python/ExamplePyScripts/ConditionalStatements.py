"""
Conditional statements
"""


#CHECKING FOR EQUAL VALUES

#Create list of cars

#Creste list 
cars = ['volvo','volkswagen','bmw','vauxhall']

#Create for loop to check for equal values
for car in cars:
   if car == 'bmw':
    print ('Match found')
   else:
    print('No match')
 
 
##CHECKING FOR NON-EQUAL VALUES

pizzatopping = ['cheese','mushrooms']

notwantedtoppings = 'mushrooms'

print('\nPIZZA TOPPINGS:')
for topping in pizzatopping:
	if topping != notwantedtoppings:
		print('Topping ok: '+topping)
	else:
		print('Topping remove: '+topping)

print('END OF LIST')


#CHECKING MULTI CONDITIONS
print('\nMULTI CONDITIONS P1')

value = 35

print('\nValue to be checks for: '+str(value))


if (value >=10) and (value <15):
	print('Condition: '+str(1)+' Passed')

if (value >=15) and (value <25):
	print('Condition: '+str(2)+' Passed')

if (value >=25) and (value <35):
	print('Condition: '+str(3)+' Passed')

if (value >=35) and (value <=45):
	print('Condition: '+str(4)+' Passed')
	
	


print('\n')
print('MULTI CONDITIONS P2')

value1 = 15
value2 = 30

print('\nValue to be checks for: '+str(value))


if (value1 >=10) or (value2 <40):
	print('Condition: '+str(1)+' Passed')


#CHECKING VALUE PRESENT IN LIST
print('\nCHECKING VALUE PRESENT IN LIST')

#create list

pizzatoppings = ['cheese','pineapple','pepperoni']
requestedtopping = 'pepperoni'

if requestedtopping in pizzatoppings:
	print ('Topping is present')



banned_users = ['phil','chris']
user = 'john'

#CHECKING VALUE NOT PRESENT IN LIST
print('\nCHECKING VALUE NOT PRESENT IN LIST')
if user not in banned_users:
    print (user.title()+' user is accepted')
else:
    print (user.title()+' user is currently banned')
    
    
#ElseIF


print('\nelif condition')

age = 35

print('\nValue to be checks for: '+str(age))


if (age >=0) and (age <3):
	price = 0
elif (age >=3) and (age <5):
    price = 5
elif (age >=5) and (age <10):
    price = 10
    
#Remember that the else is not required only if useful
else:
    price = 15
print ('Your admission price = £'+str(price))


#Checking lists against a list
#This script will check if the list item is available

print('\nlist check condition\n')

avaiabletopping = ['mushrooms','peppers','cheese','ham','pineapple','salami']
requestedtopping = ['peppers','mushroom','ham']


for requestedtoppings in requestedtopping:
    if requestedtoppings in avaiabletopping:
	    print(requestedtoppings.title()+': Topping added ')
    else:
	    print(requestedtoppings.title()+': Topping is not avaiable')

print('\nPizza completed')
































