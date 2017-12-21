#Classes 
#When you create a class you define the general behavior that a whole category
#of objects can have.

#Functions within a class are called methods.

#Dog Class 

"""
class Dog():
    def __init__(self, name, age):
        self.name = name
        self.age = age
		
    def sit(self):
	    print(self.name.title()+" is now sitting")
	    
    def rollover(self):
        print(self.name.title()+" is now rolling over")
        
        
 
#Making an instance from a class

#Create the instance of the class
my_dog = Dog('Willie',7)

#Use the instance 
print("My Dogs name is "+my_dog.name.title()+" and he is "+str(my_dog.age)+" years old")

#Then use other methods within a class

my_dog.rollover()   
my_dog.sit()
"""

"""
class Resturant():
	
	def __init__(self, resturant_name, cuisine_name):
	   
	   self.resturant_name = resturant_name
	   self.cuisine_name = cuisine_name

	def resturant_details(self):
		print("Resturant Name: " +self.resturant_name.title())
		
		
	
new_resturant = Resturant('Waggoners','English')

print('The resturant is called the '+new_resturant.resturant_name)

new_resturant.resturant_details()
"""
	
#Building on Classes 

#CAR CLASS 
class Car():
	"""This class is to represnt a car"""
	
	def __init__(self, make, model, year):
		
		self.make = make
		self.model = model
		self.year = year
		"""this is a attribute with a default value"""
		self.mileage = 0 
		
	"""method for the details of the car"""
	def describe_car(self):
		
		car_description = str(self.year)+" "+self.model+" "+self.make
		return car_description
	
	"""method to find mileage of the car"""
	def read_mileage(self):
		print ("This car has "+str(self.mileage)+" miles")
	
	"""Method to update mileage"""
	def update_mileage(self, mileage):
		if mileage > self.mileage:
			self.mileage = mileage
		else:
			print("Error you can roll back mileage!!")
			
	"""Method to update mileage in increment"""
	def update_mileage_increment (self, mileageaddition):
		self.mileage += mileageaddition
		
		
car_current = Car('Volvo','S60',2013)

#Call the make on its own
print(car_current.make)

#Car description
print(car_current.describe_car())

#Call the mileage
car_current.read_mileage()

#Modify the mileage directly
car_current.mileage = 23
car_current.read_mileage()

#update via method
car_current.update_mileage(60)
car_current.read_mileage()

#Check mileage clocking trap, it currently 60 as set above
car_current.update_mileage(10)

#Check incremental mileage addition, this should result in 70 miles
car_current.update_mileage_increment(10)

print('\n')
car_current.read_mileage()


#DEFINE A CHILD CLASS 

class ElectricCar(Car):
	
	"""Represents aspects of a car which are relevelnt to an electic vehicle"""
	def __init__(self, make, model, year):
		
		"""Initialize attributes of the parent class using the super function"""
		super().__init__(make, model, year)
	
		self.battery_size = 70
		
	def battery_size(self):
		print (self.battery_size())
		
#Call ElectricCar child class using methods from in the Car Class
#Remember that the child class has to be after the parent class in the file
		
my_car = ElectricCar('Volvo','Hybrid',2013)

print(my_car.describe_car())

#Battery size of electric car
my_car.battery_size()
		
	







