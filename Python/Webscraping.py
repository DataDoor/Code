"""
Webscraping 

Libaries which need to be installed are 

requests
lxml
bs4 

Example website www.example.com

"""
#Import required Libaries
import requests
import bs4 

'''
Perform a get request to extact the required text into the res variable
'''
res = requests.get('http://www.example.com')

'''
Now using the beautifulsoup libary we're going to convert the
request text from above into some more readable. REMEMBER you need to 
have the lxml libary install and use in this below, if you don't it will warn
you that you need to utilise this libary
'''
webitems = bs4.BeautifulSoup(res.text,'lxml')

'''
Now at this stage you can go two routes, with print the result from the above
and manually search the file for the data you want, or you can use the inspect 
option

For this option you need to go to the website you're looking to scrap data from and 
right click (in chrome this is) then select inspect always make sure to select whatever
you wanting to extract and it will go to that location.

This will bring up the html code in a pane to the right generally, if you look down that 
pane and find the data you want to extracts heading or tag  i.e. <h2>

'''
#print(webitems)

'''
In this below example we're extracting the title tag so we pass the select method in and
request the title tag
'''
title = webitems.select('title')


'''
If you we're to then print out the result it will be returned with the tags i.e. <title>example</title>
however you can use the getText() methord to extract just the text.
'''
print(title[0].getText())



'''
MORE ADVANCED EXAMPLE

In this example we're going to use the wiki page for burnley f.c

https://en.wikipedia.org/wiki/Burnley_F.C.

'''

#Extract html
r = requests.get('https://en.wikipedia.org/wiki/Burnley_F.C.')

#Convert with bs4
webitemsburnley = bs4.BeautifulSoup(r.text,'lxml')


'''
From the inspect page of the website, after selecting the history text on the page
you will see this is in an element mw-headline
'''

#Loop to extract examples
for items in webitemsburnley.select('.mw-headline'):
    print(items.text)




