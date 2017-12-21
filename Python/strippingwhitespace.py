#Stipping whitespace

#Message with white space on both sides

message = ' This is test '

#No changes
print (message+ ' Length '+str(len(message)))

#Left whitespace removed
print(message.lstrip()+ ' Length '+str(len(message.lstrip())))

#Right whitespace removed
print(message.rstrip()+ ' Length '+str(len(message.rstrip())))

#Whitespace removed both sides.
print (message.strip()+ ' Length '+str(len(message.strip())))
