#WORKING WITH MULTIPLE FILES

"""
This is an example where we will work with mulitple file
"""


filename = ['pi_text.txt','pi_text1.txt','test.txt']

#Create function which counts files words
def filewordcount(filename):
	
	try:
		with open(filename) as txtFile:
			contents = txtFile.read()
	except:
		#print("File Doesn't appear to exist")
		
		#this will simply pass over and not print any error
		pass
	else:
		words = contents.split()
		numberofwords = len(words)
		print("Filename:" +filename+' has a total word count of '+str(numberofwords))
	

for file in filename:
	filewordcount(file)
	
	

