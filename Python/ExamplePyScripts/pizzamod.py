"""
This is pizza module to show how to import modules
"""

def make_pizza(size,*toppings):
    print("Your "+str(size)+" inch pizza will have the following toppings:")
    for topping in toppings:
        print (topping.title())
       
