import webbrowser, requests

#Simply open a webpage
#webbrowser.open('www.google.com')

#Download data from webpage

goodurl = 'https://automatetheboringstuff.com/files/rj.txt'
badurl = 'https://automatetcccsdsdheboringstuff.com/files/rj.txt'

res = requests.get(goodurl)

if res.status_code == requests.codes.ok:
    print('We''re ok')
else:
    print('That url has and error')

