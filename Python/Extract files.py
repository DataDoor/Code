import zipfile, os, shutil

# ##One level down

# filePath = '\\\\LP324\\DataShare\\ContentExtract\\Zipped'
# upzipPath = '\\\\LP324\\DataShare\\ContentExtract\\UnZipped'



# ##Extract Zip Contents

# print('EXTRACT FILES FROM ZIP')

# for zipFileName in os.listdir(filePath):

#     zipFileExtract = zipfile.ZipFile(f'{filePath}\\{zipFileName}')
#     zipFileExtract.extractall(upzipPath)
#     zipFileExtract.close()

# print('EXTRACT FROM ZIP COMPLETED')

#Two Level Down

filePath = '\\\\LP324\\DataShare\\ContentExtract\\UnZipped'
xmlStorePath = '\\\\LP324\\DataShare\\ContentExtract\\XML'

print('MOVE XML TO XML FILE STORE')
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