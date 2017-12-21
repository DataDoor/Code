#Looping

#TEXT LOOPING
print ('\nBASIC LOOP')

artists = ['Prince','Michael Jackson','Madonna','Jesus']

#NOTE the indentation for the print is required
for artistloop in artists:
	print ('Artist: ' +artistloop)

print('\nAdd more lines to be outputted in loop')
#you can have as many indented commands as you want	
for artistloop in artists:
	print ('Artist: ' +artistloop)
	print ('The Artist: '+artistloop)


print('\nSummerise with using unindented command at the end')
#you can have as many indented commands as you want	
for artistloop in artists:
	print ('Artist: ' +artistloop)

print('\nTotal artists: '+str(len(artists)))


#NUMERICAL LOOPING
print('\nNumerical looping')

#Note that this will list number 1-5, 6 is the value to reach
for num in range(1,6):
	print(num)
	
#move up in evens in the range first number is the start, second end, third is amount to added
#In this example it will start at 1, end at 5 and move up in adition of 2 i.e 1,3,5
for num in range(1,6,2):
	print(num)

#Create a list of number by using the list() function wrapper
print('\nCreate list for numbers')

nums = list(range(1,6))
print (nums)


#STATS 
print('\nSTATS')
#Create list of numbers

stats = [1,2,3,410,12,32,102,1000]

print('\nfull list')
print(stats)

print('\nMax value')
print(max(stats))

print('\Min value')
print(min(stats))

print('\sum of values')
print(sum(stats))






