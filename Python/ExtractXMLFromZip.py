"""
The Purpose for this script is to extract the XML data from AquiredContent folders.
"""

import zipfile, os, shutil

#One level down

filePath = '\\\\DT014\\AcquiredContent\\WJE'
xmlFileStorePath = '\\\\DT014\\AcquiredContent\\XmlFiles\\WJE'

print('EXTRACT FILES FROM ZIP')
for zipFileName in os.listdir(filePath):
    zipFileExtract = zipfile.ZipFile(filePath+'\\'+zipFileName)
    zipFileExtract.extractall(filePath)
    zipFileExtract.close()
print('EXTRACT FROM ZIP COMPLETED')

# print('MOVE XML TO XML FILE STORE')
# for xmlFileName in os.listdir(filePath):
#     if xmlFileName.endswith('.xml'):
#         shutil.move(filePath+'\\'+xmlFileName,xmlFileStorePath+'\\'+xmlFileName)
# print('XML FILE MOVE COMPLETED')
#
# print('OTHER EXTRACT FILES REMOVED')
# for pdfFile in os.listdir(filePath):
#     if pdfFile.endswith('.pdf'):
#         os.unlink(filePath+'\\'+pdfFile)
# print('PROCESS COMPLETE')



