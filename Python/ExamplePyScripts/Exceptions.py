#EXCEPTIONS
#use the try and catch method


#print("Lets divide some number")
#print("Press q to quit")

#while True:
	
	#first_number = input("\nPlease enter your first number:")
	
	#if first_number == 'q':
		#break
	
	#second_number = input("\nPlease enter your second number:")
	
	#if second_number == 'q':
		#break
	
	
	#try:	
		#answer = int(first_number)/int(second_number)
	#except:
		#print("You can divide by zero")
	#else:
		#print(answer)
		

#LOOKING FOR FILE EXAMPLE

try:
	with open('readerror.txt') as txtFile:
		contents = txtFile.read()
		
except:
	print("The file doesn't appear to exist")
		
else:
	print(contents)

	



