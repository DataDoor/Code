/*FIND TABLE FROM SUSPECT PAGES DATA*/

SELECT * FROM [msdb].[dbo].[suspect_pages];


/*
This will return a result like the below

database_id file_id     page_id              event_type  error_count last_update_date
----------- ----------- -------------------- ----------- ----------- -----------------------
6           1           295                  2           2           2014-09-25 01:18:22.910

You can just use print option 0, as that just displays the page’s header. You also must enable trace flag 3604 to get any output from DBCC PAGE – it’s perfectly safe. So taking the values from our suspect_pages output, that gives us:

We can then use this in DBCC PAGE to find the data 

dbcc page ( {'dbname' | dbid}, filenum, pagenum [, printopt={0|1|2|3} ])

DBCC TRACEON (3604);
DBCC PAGE (6, 1, 295, 0);
DBCC TRACEOFF (3604);
GO

In the results from the header look for the object Metadata: ObjectId = 245575913 

you can then use the OBJECT_NAME(245575913) Function to find the object

REMEMBER to change the data which your using other wise the OBJECT_NAME function will return NULL
*/

DBCC TRACEON (3604);

DBCC PAGE ( {'dbname' | dbid}, filenum, pagenum , 0);

DBCC TRACEOFF (3604);
GO






