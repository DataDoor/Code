#This is how we can populate lists

#Normal use of list

#~ namelist = ['Neil','Alex','Miles']

#~ print(namelist) #printlist
#~ print(len(namelist)) #length of list

#Populate from input

#~ namelist2 = [] #Empty list

#~ while True:
	#~ print('Enter a name (Or enter nothing to stop):' )
	#~ name = input()
	
	#~ if name == '':
		#~ break
	
	#~ namelist2 = namelist2 + [name]

#~ #list names
#~ print('This is the list of names:')

#~ for names in namelist2:
	#~ print(names)
	

#USING RANGE

#~ """ 
#~ Range can be used to iterate through a certain number but its useful
#~ to work through a list without knowing the amount of values held in that
#~ list
#~ """

#~ namelist = ['Test','Test1','Test2','Test3','Test4','Test5']

#~ for i in range(len(namelist)):
	#~ print(namelist[i])
	

#LOOKING FOR VALUES

namelist = ['Test','Test1','Test2','Test3','Test4','Test5']

searchname = 'Test'

for i in namelist:
	if i.index(searchname) != None:
		print('Yes')




