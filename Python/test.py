import zipfile, os, shutil


xmlStorePath = '\\\\LP324\\DataShare\\ContentExtract\\XML\\AAOUJ'

for zipfilename in os.listdir(xmlStorePath):
    zipfile = zipfilename.split(".")
    print(len(zipfile))
    
    i = 0
    while i <= len(zipfile):
        print (zipfile[i])
        i += 1

