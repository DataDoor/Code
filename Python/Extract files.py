import zipfile, os, shutil




def UnZip (currentZipLoc,finalUpZipLoc)

'''
This function extracts the zip file contents into a requsted location
'''
for zipFileName in os.listdir(currentZipLoc):

    zipFileExtract = zipfile.ZipFile(f'{currentZipLoc}\\{zipFileName}')
    zipFileExtract.extractall(finalUpZipLoc)
    zipFileExtract.close()

print('EXTRACT FROM ZIP COMPLETED')


def ExtractXmlFile (currentFolderPath, xmlStorePath)

"""
This function extracts the required xml files from the folders 
into a XML store.

PLEASE NOTE: This extract is currently set at 2 levels down
I.e. A folder within a folder holds the XML file
"""


for lvlOneFolder in os.listdir(filePath):
    lvlOnePath = f'{filePath}\\{lvlOneFolder}'
    for lvlTwoFolder in os.listdir(lvlOnePath):
        lvlTwoPath = f'{filePath}\\{lvlOneFolder}\\{lvlTwoFolder}'
        for fileName in os.listdir(lvlTwoPath):
            if fileName.endswith('.xml'):
                currentPath = f'{lvlTwoPath}\\{fileName}'
                movePath = f'{xmlStorePath}\\{fileName}'

            try:
                shutil.copy(currentPath,movePath)
                #print (f'{fileName} - Copied')
            except:
                print(f'Move failed for {fileName}')
                continue
                
print('XML FILE MOVE COMPLETED')



#Unzip parameters
currentZipLoc = '\\\\LP324\\DataShare\\ContentExtract\\Zipped'
finalUpZipLoc = '\\\\LP324\\DataShare\\ContentExtract\\UnZipped'


#Xml Extract parameters
currentFolderPath = '\\\\LP324\\DataShare\\ContentExtract\\UnZipped'
xmlStorePath = '\\\\LP324\\DataShare\\ContentExtract\\XML'


