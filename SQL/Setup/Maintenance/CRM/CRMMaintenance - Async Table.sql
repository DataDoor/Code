Select COUNT(AsyncOperationId)FROM AsyncOperationBase WITH (NOLOCK)
where OperationType in (1, 9, 12, 25, 27, 10) 
AND StateCode = 3 AND StatusCode IN (30,32) 


CREATE NONCLUSTERED INDEX CRM_WorkflowLog_AsyncOperationID ON [dbo].[WorkflowLogBase] ([AsyncOperationID])
GO 

CREATE NONCLUSTERED INDEX CRM_DuplicateRecord_AsyncOperationID ON [dbo].[DuplicateRecordBase] ([AsyncOperationID])
GO

CREATE NONCLUSTERED INDEX CRM_BulkDeleteOperation_AsyncOperationID ON [dbo].[BulkDeleteOperationBase]
(AsyncOperationID)
GO


IF EXISTS (SELECT name from sys.indexes
                  WHERE name = N'CRM_AsyncOperation_CleanupCompleted')
      DROP Index AsyncOperationBase.CRM_AsyncOperation_CleanupCompleted
GO
CREATE NONCLUSTERED INDEX CRM_AsyncOperation_CleanupCompleted
ON [dbo].[AsyncOperationBase] ([StatusCode],[StateCode],[OperationType])
GO

declare @DeleteRowCount int
Select @DeleteRowCount = 2000
declare @DeletedAsyncRowsTable table (AsyncOperationId uniqueidentifier not null primary key)
declare @continue int, @rowCount int
select @continue = 1
while (@continue = 1)
begin
      begin tran
      insert into @DeletedAsyncRowsTable(AsyncOperationId)
      Select top (@DeleteRowCount) AsyncOperationId
      from AsyncOperationBase
      where OperationType in (1, 9, 12, 25, 27, 10) AND StateCode = 3 AND StatusCode in (30, 32)     
 
      Select @rowCount = 0
      Select @rowCount = count(*) from @DeletedAsyncRowsTable
      select @continue = case when @rowCount <= 0 then 0 else 1 end     
 
        if (@continue = 1)
        begin
            delete WorkflowLogBase from WorkflowLogBase W, @DeletedAsyncRowsTable d
            where W.AsyncOperationId = d.AsyncOperationId
            
delete BulkDeleteFailureBase From BulkDeleteFailureBase B, @DeletedAsyncRowsTable d
            where B.AsyncOperationId = d.AsyncOperationId
 
            delete AsyncOperationBase From AsyncOperationBase A, @DeletedAsyncRowsTable d
            where A.AsyncOperationId = d.AsyncOperationId            
 
            delete @DeletedAsyncRowsTable
      end
 
      commit
end

--Drop the Index on AsyncOperationBase

DROP INDEX AsyncOperationBase.CRM_AsyncOperation_CleanupCompleted


-- Rebuild Indexes & Update Statistics on AsyncOperationBase Table 
ALTER INDEX ALL ON AsyncOperationBase REBUILD WITH (FILLFACTOR = 80, ONLINE = OFF,SORT_IN_TEMPDB = ON, STATISTICS_NORECOMPUTE = OFF)
GO 
-- Rebuild Indexes & Update Statistics on WorkflowLogBase Table 
ALTER INDEX ALL ON WorkflowLogBase REBUILD WITH (FILLFACTOR = 80, ONLINE = OFF,SORT_IN_TEMPDB = ON, STATISTICS_NORECOMPUTE = OFF)

GO



UPDATE STATISTICS [dbo].[AsyncOperationBase] WITH FULLSCAN
UPDATE STATISTICS [dbo].[DuplicateRecordBase] WITH FULLSCAN
UPDATE STATISTICS [dbo].[BulkDeleteOperationBase] WITH FULLSCAN
UPDATE STATISTICS [dbo].[WorkflowCompletedScopeBase] WITH FULLSCAN
UPDATE STATISTICS [dbo].[WorkflowLogBase] WITH FULLSCAN
UPDATE STATISTICS [dbo].[WorkflowWaitSubscriptionBase] WITH FULLSCAN