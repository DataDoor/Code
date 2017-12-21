"""Working with PDF Files"""
import PyPDF2, os, docx

pdffileObj = open('C:\TxtFiles\meetingminutes.pdf','rb')
pdf = PyPDF2.PdfFileReader(pdffileObj)

#See number of pages
print(pdf.numPages)

#Extract text
pageObj = pdf.getPage(1)

#print(pageObj.extractText())

#Find all pdf docs

pdfFiles = []
for filename in os.listdir('C:\TxtFiles'):
    if filename.endswith('.pdf'):
        print(filename)


#WORD FILES

doc = docx.Document('C:\TxtFiles\demo.docx')
print(len(doc.paragraphs))