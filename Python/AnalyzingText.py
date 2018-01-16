#Analysing Text

#Here you can use the split function to split up all of the words in a file

#Simple example

#~ title = 'Alice in wonderland'
#~ title.split()

#~ print(title.split())


#Finding all letters in text and production count of words

filename = 'textFiles\pi_text.txt'
try:
	with open(filename) as txtFile:
		contents = txtFile.read()
except:
	print("File Doesn't appear to exist")
else:
	words = contents.split()
	numberofwords = len(words)
	print("Filename:" +filename+' has a total word count of '+str(numberofwords))
	



h