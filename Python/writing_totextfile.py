#WRITING DATA TO FILE

#Note in the open function, we use a second agrument 'W'
#you can use 'r' read, 'w' write, 'a' append if you leave thie argument
#out it simple defaults to read

#Simple writing to file
#filename = 'textFiles\WritingText.txt'

#with open(filename, 'w') as newFile:
	#newFile.write('I love python')



#Simple writing to file but seperating lines, remember if you don't use the \n it will all appear in one line
#filename = 'textFiles\WritingText.txt'

#with open(filename, 'w') as newFile:
	#newFile.write('I love python\n')
	#newFile.write('I love c#\n')


#Append new data to a file 
filename = 'textFiles\WritingText.txt'

with open(filename, 'a') as newFile:
	newLanuage = input("Enter the new language you use:")
	newFile.write(newLanuage+'\n')
