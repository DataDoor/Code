
import os 

"""
By using the os.path.join your able to have the path output to whatever 
os your using i.e for windows the paths use a forward \ but osx and linux use /
"""
"""
path = os.path.join('users','data','year')
print (path)
"""
"""
#Create list
fileList = ['File1.txt','File2.txt','File3.txt']

for file in fileList:
    print(os.path.join('c:\\users\\files\\'+file))
"""
"""
#GET THE CURRENT WORKING DIR
print(os.getcwd())
"""

"""
#CREATE DIRECTORY
os.makedirs("C:\\Newfolder")
"""

"""
#Finding dirname or base name 
path = 'C:\\Windows\\Users\\FileName.exe'

print(os.path.dirname(path)) #This will return everything up to the last \
print(os.path.basename(path)) #This will return everything after the last \

#Split the path
print (path.split(os.path.sep))
"""

"""
#FINDING FILE SIZE AND FOLDER CONTENTS

##There are two types of to carry this out os.path.getsize() & os.listdir()



for fileName in os.listdir('c:\\txtFiles'):
    fileSize = os.path.getsize(os.path.join('c:\\txtFiles',fileName))

    print('FileName: '+fileName+' '+str(fileSize))
"""

"""
#CHECKING IF DIRECTORY OR FILE EXISTS

pathtrue = os.path.exists('C:\\Windows')
print(pathtrue) #True as it exists

pathtrue = os.path.exists('C:\\WindowsNoExists')
print(pathtrue) #False as it doesn't exist

pathtrue = os.path.isdir('C:\\Windows')
print(pathtrue) #True as its a directory

pathtrue = os.path.isdir('C:\\Windows\test.exe')
print(pathtrue) #False as its a file


pathtrue = os.path.isfile('C:\\Windows\')
print(pathtrue) #False as its a directory

pathtrue = os.path.isfile('C:\\TxtFiles\\pi_digits.txt')
print(pathtrue) #True if this file hasn't moved :-)
"""

# #OPENING FILES 

# filename = 'C:\\TxtFiles\\HelloTextWorld.txt'

# #This will open the file
# open(filename)

# #This will also open the file 
# open(filename,'r')


#READING FILES 

#First you need to open the file like above

# filename = 'C:\\TxtFiles\\HelloTextWorld.txt'

# #This will open the file
# fileContents = open(filename)

#Read data from the file
#content = fileContents.read() 

#Print the contents from a file
#print(content)

#Read line by line

# contents  = fileContents.readlines()

# for line in contents:
#     print(line)

#WRITE TO FILES 

#This is a case of adding the 'w' to the open funciton

# filename = 'C:\\TxtFiles\\HelloTextWorld.txt'

# #This will open the file
# fileContents = open(filename,'w')
# fileContents.write('Added Text')
# #Close the file
# fileContents.close()

# content = open(filename)
# contentdata = content.read()
# print(contentdata)



