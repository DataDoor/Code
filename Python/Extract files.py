import zipfile, os, shutil

filePath = '\\\\DT014\\AcquiredContent\\WJE\\Unzipped'
xmlFileStorePath = '\\\\DT014\\AcquiredContent\\XmlFiles\\WJE'


print('MOVE XML TO XML FILE STORE')
for lvlOneFolder in os.listdir(filePath):
    lvlOnePath = filePath+'\\'+lvlOneFolder
    for lvlTwoFolder in os.listdir(lvlOnePath):
        lvlTwoPath = filePath+'\\'+lvlOneFolder+'\\'+lvlTwoFolder
        for fileName in os.listdir(lvlTwoPath):
            if fileName.endswith('.xml'):
                shutil.move(lvlTwoPath+'\\'+fileName,xmlFileStorePath+'\\'+fileName)
print('XML FILE MOVE COMPLETED')