CREATE EVENT SESSION [queryperf] ON SERVER 
ADD EVENT sqlserver.sql_statement_completed 
ADD TARGET package0.event_file(SET filename=N'E:\queryperf.xel',max_file_size=(2),max_rollover_files=(100)) 
WITH (  MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_MULTIPLE_EVENT_LOSS, 
             MAX_DISPATCH_LATENCY=120 SECONDS,MAX_EVENT_SIZE=0 KB, 
             MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON); 


USE AdventureWorks2012 
DECLARE    @SalesPersonID INT; 
DECLARE    @salesTally INT; 
DECLARE    mycursor CURSOR FOR 
SELECT soh.SalesPersonID 
FROM   Sales.SalesOrderHeader soh 
GROUP  BY soh.SalesPersonID; 
OPEN mycursor; 
FETCH NEXT FROM mycursor INTO @SalesPersonID; 
ALTER EVENT SESSION [queryperf] ON SERVER STATE = START; 
WHILE @@FETCH_STATUS = 0 
BEGIN 
       DBCC FREEPROCCACHE; 
       DBCC DROPCLEANBUFFERS; 
       CHECKPOINT; 
       SELECT @salesTally = COUNT(*) 
       FROM Sales.SalesOrderHeader  soh 
       INNER JOIN Sales.[SalesOrderDetail] sod        ON  soh.[SalesOrderID] = sod.[SalesOrderID] 
       WHERE SalesPersonID = @SalesPersonID 
       FETCH NEXT FROM mycursor INTO @SalesPersonID; 
END 
CLOSE mycursor; 
DEALLOCATE mycursor; 
DROP EVENT SESSION [queryperf] ON SERVER; 



SELECT q.duration,q.cpu_time,q.physical_reads,q.logical_reads,q.writes--,event_data_XML,statement,timestamp 
FROM   ( 
       SELECT  duration=e.event_data_XML.value('(//data[@name="duration"]/value)[1]','int') 
       ,       cpu_time=e.event_data_XML.value('(//data[@name="cpu_time"]/value)[1]','int') 
       ,       physical_reads=e.event_data_XML.value('(//data[@name="physical_reads"]/value)[1]','int') 
       ,       logical_reads=e.event_data_XML.value('(//data[@name="logical_reads"]/value)[1]','int') 
       ,       writes=e.event_data_XML.value('(//data[@name="writes"]/value)[1]','int') 
       ,       statement=e.event_data_XML.value('(//data[@name="statement"]/value)[1]','nvarchar(max)') 
       ,       TIMESTAMP=e.event_data_XML.value('(//@timestamp)[1]','datetime2(7)') 
       ,       * 
       FROM    ( 
               SELECT CAST(event_data AS XML) AS event_data_XML 
               FROM sys.fn_xe_file_target_read_file('E:\queryperf*.xel', NULL, NULL, NULL) 
               )e 
       )q 
--WHERE  q.[statement] LIKE 'select @salesTally = count(*)%' --Filters out all the detritus that we're not interested in! 
ORDER  BY q.[timestamp] ASC 
; 


--ALTER EVENT SESSION Login_Capture ON SERVER STATE = START; 




SELECT 
	e.event_data_XML.value('(//@timestamp)[1]','datetime2')
	,e.event_data_XML.value('(//data[@name ="database_id"]/value)[1]','int')
	,e.event_data_XML.value('(//data[@name="database_id"]/value)[1]','int')
	,event_data_XML.value('(//action[@name ="nt_username"]/value)[1]','varchar(30)')
	,event_data_XML.value('(/event/action[@name ="nt_username"]/value)[1]','varchar(30)')
FROM 
(SELECT CAST(event_data AS XML) AS event_data_XML 
FROM sys.fn_xe_file_target_read_file('\\Em-appl018\itsql\Traces\ExtendedEventTraces\DBL02\logincapture*.xel', NULL, NULL, NULL)) e


DECLARE @MyXML XML
SET @MyXML = '<SampleXML>
<Colors>
<Color1>White</Color1>
<Color2>Blue</Color2>
<Color3>Black</Color3>
<Color4 Special="Light">Green</Color4>
<Color5>Red</Color5>
</Colors>
<Fruits>
<Fruits1>Apple</Fruits1>
<Fruits2>Pineapple</Fruits2>
<Fruits3>Grapes</Fruits3>
<Fruits4>Melon</Fruits4>
</Fruits>
</SampleXML>'

SELECT
a.b.value('Colors[1]/Color1[1]','varchar(10)') AS Color1,
a.b.value('Colors[1]/Color2[1]','varchar(10)') AS Color2,
a.b.value('Colors[1]/Color3[1]','varchar(10)') AS Color3,
a.b.value('Colors[1]/Color4[1]/@Special','varchar(10)')+' '+
a.b.value('Colors[1]/Color4[1]','varchar(10)') AS Color4,
a.b.value('Colors[1]/Color5[1]','varchar(10)') AS Color5,
a.b.value('Fruits[1]/Fruits1[1]','varchar(10)') AS Fruits1,
a.b.value('Fruits[1]/Fruits2[1]','varchar(10)') AS Fruits2,
a.b.value('Fruits[1]/Fruits3[1]','varchar(10)') AS Fruits3,
a.b.value('Fruits[1]/Fruits4[1]','varchar(10)') AS Fruits4
FROM @MyXML.nodes('SampleXML') AS a(b)





--ALTER EVENT SESSION Login_Capture ON SERVER STATE = STOP; 