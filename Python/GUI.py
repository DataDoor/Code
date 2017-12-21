#GUI examples


from guizero import App
from guizero import Text
from guizero import TextBox
from guizero import PushButton

app = App(title = "Import of data")

welcome_message = Text(app, text="Welcome to my app", size=40, font="Times New Roman", color="lightblue")

my_name = TextBox(app, width = 20)

def say_my_name():
    welcome_message.set(my_name.get())

update_text = PushButton(app, command=say_my_name, text="Display my name")




app.display()
