import csv, os

#READER

#This opens the file and reads in all the data
# exampleFile = open('c:\TxtFiles\example.csv')
# exampleReader = csv.reader(exampleFile)
#
# #This will read all the data into a variable
# exampleData = list(exampleReader)
# #print(exampleData) #shows all data in exampledata variable
# # print(exampleData[0][1]) #This will display the data from row 1 column 2 rember these are zero indexed
#
# #Loop over the data (using the data from above)
# # for row in exampleData:
# #     print('Row :'+ str(row))
#
# #WRITER
#
# #CSV
# outputFile = open('c:\TxtFiles\exampleWritingFile.csv','w',newline= '') #Remember the newline = '' is needed otherwise it double spaces
# outputWriter = csv.writer(outputFile)
# outputWriter.writerow(['one','Two'])
# outputWriter.writerow(['Three','Four'])
# outputWriter.writerow(['1','2'])
#
# outputFile.close()
#
# #TSV
# outputFile = open('c:\TxtFiles\exampleWritingFile_TSV.tsv','w',newline= '') #Remember the newline = '' is needed otherwise it double spaces
# outputWriter = csv.writer(outputFile,delimiter = '\t',lineterminator = '\n\n')
# outputWriter.writerow(['one','Two'])
# outputWriter.writerow(['Three','Four'])
# outputWriter.writerow(['1','2'])
#
# outputFile.close()

#REMOVE HEADER OF CSV FILES and RE-SAVE

filePath = 'C:\TxtFiles\csv'
filePathHeaderRemoved = 'c:\\TxtFiles\\HeaderRemoved'

#Create new filepath
os.makedirs(filePathHeaderRemoved,exist_ok= True)

#Find all files which are csv
for csvFilename in os.listdir(filePath):
    if csvFilename.endswith('.csv'):
        print('Removing Header from: '+csvFilename)

        csvrows = []
        csvFileObj = open(filePath+'\\'+csvFilename)
        readerobj = csv.reader(csvFileObj)

        for row in readerobj:
            if readerobj.line_num == 1:
                continue
            csvrows.append(row)
        csvFileObj.close()

        csvFileObj = open(filePathHeaderRemoved+'\\'+csvFilename,'w',newline= '')

        csvWriter = csv.writer(csvFileObj)
        for row in csvrows:
            csvWriter.writerow(row)
        csvFileObj.close()







