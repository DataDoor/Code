/* 
 
Hacked together on a SSMS 2016, tested against SQL 2014 
Use at your own risk, test first.  I accept no responsibility for any issues arising 
from this script in your environment.  
 
Kevin3NF 
http://DallasDBAs.com/blog 
 
*/ 
 
-- eliminate this if you are logging to a permanent user table 
-- or, if you are just logging the errors to a user table, leave this here 
-- and uncomment the insert below to map to your table 
Create Table #Errorlog  
    (Logdate datetime,  
     ProcessInfo varchar(50),  
     LogText varchar(5000)) 
 
--Dump all the things into the table 
insert into #Errorlog 
EXEC sys.xp_readerrorlog  
    0            -- Current ERRORLOG 
    ,1            -- SQL ERRORLOG (not Agent) 
 
--Query just like you would anything else: 
-- INSERT dbo.YourTable (your columns) 
Select *  
from #Errorlog  
Where 1=1 
    --and LogText like '(c) Microsoft Corporation%' 
    and (LogText like '%Error%'    or LogText like '%Fail%'or LogText like '%deadlock%' 
    ) 
    And Logdate > getdate() -2 
    And LogText Not Like '%CheckDB%' 
    And LogText not like '%35262%' 
    And LogText not like '%35250%' 
 
--Clean up your mess, you weren't raised in a barn! 
-- again, omit this if not using a temp table 
Drop Table #Errorlog 