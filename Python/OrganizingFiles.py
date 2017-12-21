import shutil, os, zipfile


# #COPYING FILES

# #This example will check if the the directory exists and if 
# #it does the the file will be copied if not it will create the 
# #directory and then copy the file.

# filename = 'HelloTextWorld.txt'
# sourcepath = 'c:\\TxtFiles\\'
# destpath = 'C:\\TxtFiles\DestCopy\\'


# if os.path.exists(destpath) == True:
#     try:
#         print('Copy')
#         shutil.copy(sourcepath+'\\'+filename,destpath+'\\'+filename)
#     except:
#         Print("Error with copying")
# else:
#     try:
#         os.mkdir(destpath)
#         print('Directory Created')
#         print('Copying...')
#         shutil.copy(sourcepath+'\\'+filename,destpath+'\\'+filename)
#         print('File Copied')
#     except:
#         print('Error with copying')

# #COPY DIRECTORY
# #You can use copytree to move a full dir  and its files to a new location

# destpathcopy = 'C:\\TxtFiles\DestCopy2\\'

# #Copy directory
# print('Copying Directory')
# shutil.copytree(destpath,destpathcopy)

# #MOVE FILES OR FOLDER
# #Im this example we'll move a file from about to a new folder

# destpathmove = 'C:\\TxtFiles\DestCopy3\\'

# if os.path.exists(destpathmove) == True:
#     print('Copying file to despathmove folder')
#     shutil.move(destpathcopy+'\\'+filename,destpathmove+'\\'+filename)
# else:
#     print('Creating destpathmove folder')
#     os.mkdir(destpathmove)
#     print('Copying file to despathmove folder')
#     shutil.move(destpathcopy+'\\'+filename,destpathmove+'\\'+filename)

# #DELETING FILES
# """
# There are three way to do this:

# os.unlink() with delete the file at path
# os.rmdir() with detlete the folder, but this must be empty
# shutil.rmtree() with remove the folder and all its contents
# """

# #In this example we can clean up the files which we created above but by using extention ends


# files  = os.listdir(destpath)

# for filename in files:
#     print('Deleting:'+destpath+filename)
#     os.unlink(destpath+filename)
#     print('File: '+destpath+filename+' has been deleted')

# #Remove directories
# print('Deleting: '+destpath) #Remove empty folder
# os.rmdir(destpath)
# print('Deleting: '+destpathcopy) #Remove empty folder
# os.rmdir(destpathcopy)
# print('Deleting: '+destpathmove) #Remove folder with content
# shutil.rmtree(destpathmove)


#WALKING THE DIRECTORY

"""
To walk the directory you can use the command os.walk()
"""
#CREATE SOME DIRECTORYS TO WALK if REQUIRED
# os.mkdir('c:\\TxtFiles\\TopFolder') #TopFolder
# os.mkdir('c:\\TxtFiles\\TopFolder\\SubFolder') #SubFolder
# newfile = open('C:\\TxtFiles\\TopFolder\\SubFolder\\FileinSubFolder.txt','w')
# newfile.write("TestData")

# for foldername, subfolders, filenames in os.walk('c:\\TxtFiles\\TopFolder'):
#     print('Parent Folder name is : '+foldername)

#     for subfolder in subfolders:
#         print(subfolder)
#     for filename in filenames:
#         print(filename)

##ZIP FILES 

##For this you need to have the module import zipfile

#Create a zip file first before trying this

#Find contents
# zipfilepath = 'c:\\TxtFiles'
# zipfilename = 'TestZip.zip'
# filename = 'ZipFileTest.txt'

# examplezip = zipfile.ZipFile(zipfilepath+'\\'+zipfilename)

# print(examplezip.namelist())

#Extract Contents of ZipFile 
#examplezip.extractall(zipfilepath) #Exract all files, give the path where you want them to be extracted to

#Extract an specifc file
# examplezip.extract('ZipFileTest.txt')

#ADD TO ZIPFILE 

zipfilepath = 'c:\\TxtFiles'
zipfilename = 'TestAddZip.zip'
filename = 'ZipAddFileTest.txt'
createfile = open(zipfilepath+'\\'+filename,'w')


newzip = zipfile.ZipFile(zipfilepath+'\\'+zipfilename,'w')
newzip.write(zipfilepath+'\\'+filename)