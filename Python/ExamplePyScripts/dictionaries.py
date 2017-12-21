#DICTIONAIRES

#CREATING A SIMPLE DICTIONARY
person = {'firstname':'neil','lastname':'gelder'}

#QUERYING DATA TO RETEIVE VALUE
print(person['firstname'])

#ADDING TO DICTIONARY

print('\nPre addition')
print(person)

#Add title to dictionary
person['title'] = 'mr'


print('\nPost addition')
print(person)

#ADDING TO EMPTY DICTIONARY

#Create dictionary
print('\nCreate car dictionary')
car ={}

car['make'] = 'volvo'
car['model'] = 'S60'

print(car)

#MODIFY DICTIONARY VALUES
print('\nMODIFY DICTIONARY VALUES')

print('\nCurrent car dictionary')
print(car)

#modify model value

car['model'] = 'XC90'

print('\nUpdated dictionary')
print(car)


#DELETE key pair i.e section like model
print('\nDELETE key pair i.e section like model')

print('\nCurrent dictionary')
print(car)

#Delete
del car['model']

print('\nUdpated with delete keypair dictionary')
print(car)


#USING DICTIONARIES FOR  SIMILAR VALUES
print('\nUSING DICTIONARIES FOR  SIMILAR VALUES')

fav_languages = {
    'neil':'python',
    'james':'java',
    'sarah':'sql',
    'dave':'python'
	}
	
print("Neil's favorite language is "+
    fav_languages['neil'].title())
    
    
    
 #LOOPING THROUGH DICTIONARIES
print('\nLOOPING THROUGH DICTIONARIES')

print('\nLooping person')
for key, value in person.items():
	print(key+': '+value)
 
 
print('\nLooping person')
for name, language in fav_languages.items():
	print('[Name] - '+name+', [Favorite language] - '+language)
 
 

#LOOPING THROUGH KEYS
#This would be useful if you just want the keys values

print('\nLooping key values')
for name in fav_languages.keys():
    print(name.title())


#SORT RETURNED DATA
print('\nLooping key values SORTED')
for name in sorted(fav_languages.keys()):
    print(name.title())




#LOOPING THROUGH VALUES
#This would be useful if you just want the value values

print('\nLooping value values')
for language in fav_languages.values():
    print(language.title())


print('\nGetting distint list using SET')
for language in set(fav_languages.values()):
    print(language.title())
    

#AUTO POPULATE LISTS
print('\nAUTO POPULATE LISTS')

#Create empty list
alien= []

#Loop to create 10 new aliens
for aliens in range(11):
	new_alien = {'colour':'green','points':'5','speed':'slow'}
	alien.append(new_alien)

#Display list
print('\nShow Lists')
print(alien)

#This shows the total created
print('\nShow count')
print(str(len(alien)))

#Modify certain amount of entries

for aliens in alien[0:3]:
	if aliens['colour'] == 'green':
	    aliens['colour'] = 'yellow'
	    aliens['speed'] = 'fast'

print(aliens)
    
#PUTTING LIST INTO A DIRECTORY
print('\nPUTTING LIST INTO A DIRECTORY')
pizza = {
    'crust':'thick',
    'toppings':['ham','mushroom']
    }
    
print ("You ordered a "+pizza['crust']+" crust pizza with the following toppings:")

print("Toppings:")
for topping in pizza['toppings']:
    print(topping)
    
    
 
#MULTIPLE LISTS IN DICTIONARY
print('\nMULTIPLE LISTS IN DICTIONARY')
p_languages = {
    'neil':['python','c#'],
    'james':['java'],
    'sarah':['sql','c#'],
    'dave':['python']
	}

for name, languages in p_languages.items():
    print(name.title()+" has the following languages")
    for personlanguages in languages:
        print(personlanguages)
    print('\n')



#DICTIONARIES IN DICTIONARIES 
print('\nDICTIONARIES IN DICTIONARIES')
#Create users
users = {
    'geldern':{'firstname':'neil','lastname':'gelder'},
    'kirkerk':{'firstname':'marc','lastname':'kirker'}
    }

for username, user_info in users.items():
	print("UserName: "+username)
	print("Firstname: "+user_info['firstname']+" Lastname: "+user_info['lastname']+'\n')
