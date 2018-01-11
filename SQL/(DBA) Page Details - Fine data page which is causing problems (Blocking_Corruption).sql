/*
Use this to fine problem with from locking or corrupt pages,
this is good for finding for example if the page which is corrupted
is an index in that case a simple rebuild will work
*/

/*Example

DBCC PAGE ( {'dbname' | dbid}, filenum, pagenum [, printopt={0|1|2|3} ])

0 - print just the page header
1 - page header plus per-row hex dumps and a dump of the page slot array
2 - page header plus whole page hex dump
3 - page header plus detailed per-row interpretation


--These statments will produce informaiton for their respective mark pages

DBCC PAGE ('DatabaseName',1,0,3)   ---- File Page Header
DBCC PAGE ('DatabaseName',1,1,3)   ---- Page Free Space
DBCC PAGE ('DatabaseName',1,2,3)   ---- Global Allocation Map
DBCC PAGE ('DatabaseName',1,3,3)   ---- Secondary Global Allocation Map
DBCC PAGE ('DatabaseName',1,6,3)   ---- Differential map

*/




DBCC TRACEON (3604);

GO

DECLARE @Dbid INT
SET @DbId = DB_ID()

/*DBCC PAGE ( {'dbname' | dbid}, filenum, pagenum [, printopt={0|1|2|3} ])*/

DBCC PAGE (@Dbid,1,1,3)  

GO

DBCC TRACEOFF (3604);