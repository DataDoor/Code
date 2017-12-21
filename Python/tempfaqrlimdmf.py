"""
Rename filenames to remove certain characters i.e. img etc 
from a file path
"""

import os

#Replacement characters check (These are general ones which need changing)
replacementchars = ['IMG_','VID_','VID-']

print('The current text to remove from the files names are:\n')
for rchar in replacementchars:
    print(rchar)

print('\n')

checkchar = input('Do you want to add to this list Y or N: ')

if checkchar.upper() == 'Y':
    while True:
        replacementitem = input('Please enter char to replace, press enter to stop: ')
        if replacementitem == '':
            break
        else:
            replacementchars.append(replacementitem)

print('The process will now replace the following characters from all filenames\n')
for rchar in replacementchars:
    print(rchar)
print('\n')
print('Ok....Lets go\n')

#FILEPATH CHECK
filepath = 'C:\\Users\\geldern\\OneDrive\\TxtFiles'
check = input('Current path is '+filepath+' is this correct Y or N: ')

if check.upper() == 'Y':
    if os.path.exists(filepath) == True:
        try:
            for replacechar in replacementchars:
                filenames = os.listdir(filepath)
                for filename in filenames:
                    newname = filename.replace(replacechar,'')
                    os.rename(filepath+'\\'+filename,filepath+'\\'+newname)
        except:
            print('Error during process')

    else:
        filepath = input('File path does not exists, please enter path : ')
        if os.path.exists(filepath) == True:
            for replacechar in replacementchars:
                filenames = os.listdir(filepath)
                for filename in filenames:
                    newname = filename.replace(replacechar,'')
                    os.rename(filepath+'\\'+filename,filepath+'\\'+newname)
        else:
            print('File path does not exists!! please check and try again')
else:
    filepath = input('Please enter file path : ')
    if os.path.exists(filepath) == True:
        for replacechar in replacementchars:
            filenames = os.listdir(filepath)
            for filename in filenames:
                newname = filename.replace(replacechar, '')
                os.rename(filepath + '\\' + filename, filepath + '\\' + newname)
    else:
        print('File path does not exists, please check and try again')