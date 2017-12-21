#Lists are created by usign the[] brackete and then commas to seperate the values
#Remember list are zero valued, i.e. in the below example 0  will be Neil


#CREATE
#Creating a list of familiy names
familyname = ['Neil','Alex','Miles','Paul','Phillip','Ann','Margaret','Joyce']

#SELECTION
print('SELECTION\n')
#Select first value in list
selection = familyname[0]
print(selection)

#Select second value in list
selection = familyname[1]
print(selection)

#use - 1 to select the last item in the list, this is useful as you'd never know 
#How many items are in a list without invesitagting 
#you can move up the list by using the -2 second -3 third etc

selection = familyname[-1]
print(selection)

#REPLACE

print('REPLACE\n')
#Replace a value in a list
familyname[0]  ='John'
print(familyname[0])

#ADD TO LIST
print('ADD TO LIST\n')
#To add new items to the list you can use the append function 

#AddName
familyname.append('Milly')
#Full list
print(familyname)
#Select last value
print(familyname[-1])

#POPULATE EMPTY LIST
print('POPULATE EMPTY LIST\n')
#Populating an empty list
familynameapp = []

familynameapp.append('neil')
familynameapp.append('alex')
familynameapp.append('miles')

#Printlist
print(familynameapp)


#DELETE ITEMS FROM LIST
print('DELETE ITEMS FROM LIST\n')

familynamedel = ['Neil','Alex','Miles','Paul','Phillip','Ann','Margaret','Joyce']

#delete Neil from above list
del familynamedel[0]

#Print list
print(familynamedel)

#POP METHOD OF DELETEING
print('POP METHOD OF DELETEING\n')
#Pop is used if you want to remove an item from the list but use the value 
#after its been removed.

#for example when have the falily list
familynamepop = ['Neil','Alex','Miles']

#and we can to remove Alex but use the value we use the following 

#create variable to hold popped value
popped_value = familynamepop.pop(1)

#print the list to show the value has been removed
print(familynamepop)

#Print popped value
print(popped_value)


#REMOVE BY VALUE
print('REMOVE BY VALUE\n')
#Clearly you'll not alway know the indes value in the list, for this you can use the remove function

familynameremove = ['Neil','Alex','Miles']
print(familynameremove)

#Remove value

familynameremove.remove('Neil')
print(familynameremove)

#Please note however that this will only remove the first instance of the value
#therefore if the value appears twice then you'd need to create a loop to find all
#occurances for example 

familynameremove = ['Neil','Alex','Miles','Neil']
print(familynameremove)

familynameremove.remove('Neil')
print(familynameremove)
print('As you can see Neil still exists, it only removed the first version')





