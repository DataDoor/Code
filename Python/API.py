##IMPORT REQURIED PYTHON LIBRARIES  

import requests
from requests.auth import HTTPBasicAuth 





"""
SET API VARIABLES
"""

##SET Environment

#URL API
apiuser = ''
apipass = ''
url = ''


r = requests.get(url,auth=HTTPBasicAuth(apiuser, apipass))


print(r.status_code)