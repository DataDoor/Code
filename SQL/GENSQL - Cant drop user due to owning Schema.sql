SELECT s.name
FROM sys.schemas s
WHERE s.principal_id = USER_ID('gpReporting');


ALTER AUTHORIZATION ON SCHEMA::DYNGRP TO dbo;
ALTER AUTHORIZATION ON SCHEMA::db_datareader TO dbo;
