"""

SLICING LISTS
This is where you cna limit what is returned for a list
"""

name = ['neil','alex','miles','Paul','Phillip','Anne']

#This will return a list of the names, but only the first 3
for namelst in name[:3]:
	print(namelst.title())
	

#Copying a list

my_foods = ['pizza','falafel','carrot_cake']

print(my_foods)

#This will create a copy of the list with as we're not limiting the output
friends_foods = my_foods[:]

print(friends_foods)

#To add a different we'll add a new item to the list

friends_foods.append('burgers')
print(friends_foods) 


#One pit fall which people have is to try and simple set one variable list to equal the other i.e.

#Set friends foods to my_foods list
friends_foods = my_foods

#Both lists will be the same
print(my_foods)
print(friends_foods)

#if we append a value to the list it will appear in both not just one

my_foods.append('burger')

print(my_foods)
print(friends_foods)




