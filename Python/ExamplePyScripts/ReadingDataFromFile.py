#Simple reading from a text file in the same directory
#with open('pi_digits.txt') as file_object:
	#contents = file_object.read()
	#print(contents.rstrip())


#READING FROM A RELATIVE PATH
#Reading from a relative path i.e. a folder withing the host folder wher
#the python file is stored you use the \ notation to show where the file is located
#i.e. textfiles\Test_text.txt 

#with open('textFiles\pi_digits.txt') as file_object:
	#contents = file_object.read()
	#print(contents.rstrip())

#READING FILE FROM ANY LOCATION ON THE NETWORK

#Remember that you will require security access to the files for this to work

#file_path  = 'C:\TxtFiles\pi_digits.txt'

#with open(file_path) as file_object:
    #contents = file_object.read()
    #print(contents.rstrip())


#READ LINE BY LINE

#with open('textFiles\pi_digits.txt') as file_object:
	#for line in file_object:
		#print(line.rstrip())

#CONTENT TO A LIST 

#with open('textFiles\pi_text.txt') as file_object:
	#lines = file_object.readlines()
	
	#for line in lines:
		#print(line.rstrip().title())


#MANIPULATION DATA 

#Place all data in one string 
#file_name  = 'textFiles\pi_digits.txt'

#with open(file_name) as file_object:
	#lines = file_object.readlines()
	
	#digit_string = ''
	
	#for line in lines:
		
		#digit_string += line.strip()
		
	#print('Combined digit string'+digit_string+' With a length of '+str(len(digit_string)))
	
	
#Look for data in a string
file_name  = 'textFiles\pi_digits.txt'

with open(file_name) as file_object:
	lines = file_object.readlines()
	
	digit_string = ''
	
	for line in lines:
		
		digit_string += line.strip()
		
	birthday = input('Enter your birthday in the format of ddmmyy:')
	
	if birthday in digit_string:
		print("its there")
	else:
		print("Sorry")
		
