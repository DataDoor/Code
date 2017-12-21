"""
TUPLE - Lists which don't change

The main difference is instead of [] to define the list we use a normal
() parentheses
"""

movements = ('left','right')

#this is list the items
print(movements)

#This will list the last item
print(movements[-1])

#If we try and alter an item then we will receive and error
#movements[0] = 'up'

#However we can alter the list all together
print("\nOld values")
print(movements)

#alter the items
print("\nNeil values")
movements =('up','down')

print(movements)
