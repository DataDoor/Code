"""
To sort data in a list you can use the sort
function

sort() - This will sort the order permanently
sorted() - This will only sort temporarily
"""

#Create list of cars 

cars = ['Ford','BMW','Volvo','Audi']

print('\nThis version will be unsorted')
print(cars)

#Sort the list (this will be in alphabetical order)
cars.sort()

print('\nThis version will be sorted')
print(cars)

#You can reverse the order by using the reverse method
print('\nOrder in reverse')
cars.sort(reverse  = True)
print(cars)

#SORT
#You can use the sorted method to sort the list on temporarily

#Reset list
cars = ['Ford','BMW','Volvo','Audi']

print('\nCurrentList')
print(cars)

print('\nSorted')
print(sorted(cars))

print('\nlist returned to normal')
print(cars)


#REVERSE LIST
print('\nREVERSELIST')
print('\nCurrentList')

print(cars)


print('\nReversedList')
#Not that reversing the list is not reversing to alphabetical order
#simply reverses the values


cars.reverse()
print(cars)


#LEN()
#This will find out how entries are left

print('\nLEN function')
print('\nCurrentList')

print(cars)

print('\nLen of Cars = 4')
print(len(cars))

#Remove one entry
cars.remove('Audi')

print('\nLen of Cars = 3 after deleting Audi entry')
print(len(cars))









