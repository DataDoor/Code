def spam():
	global eggs 
	eggs = 'Spam'


eggs = 'global'
spam()
print(eggs)
