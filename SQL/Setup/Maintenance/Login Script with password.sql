------------------------------------------------------------------------------------
-- Description: Provide a list of login(s) and create a script to recreate all login and user settings
--  Revision History
--  Date           Author            Revision 	Description
-- 10/19/2005	   Terry Duffy		 Original 	(Expanded from MS code)
-- 05/17/06			Terry Duffy		Added abliity to limit to a list of databases, changes all char(13) to char(10) for sql05. 
-- 08/02/06			Terry Duffy		Modified for SQL2005
------------------------------------------------------------------------------------
--  Usage
-- Populate @list variable below with account(s),comma delimited list to script. 
-- Save output to recreate:Login,Default DB,Server Roles,DB Access,DB Roles,DB Object Permissions.
-- NOTE:
-- Stored procedures are created in Master, but are deleted
-- to limit by database see section /*Get a table with dbs where login has access*/ and change the where clause
-- to script all logins, see section /*To Script all sql and windows logins...
/*****************************Start Create needed procedures***************************/
USE master
GO
IF OBJECT_ID ('usp_hexadecimal') IS NOT NULL
  DROP PROCEDURE usp_hexadecimal
GO
CREATE PROCEDURE usp_hexadecimal
    @binvalue varbinary(256),
    @hexvalue varchar (514) OUTPUT
AS
DECLARE @charvalue varchar (514)
DECLARE @i int
DECLARE @length int
DECLARE @hexstring char(16)
SELECT @charvalue = '0x'
SELECT @i = 1
SELECT @length = DATALENGTH (@binvalue)
SELECT @hexstring = '0123456789ABCDEF'
WHILE (@i <= @length)
BEGIN
  DECLARE @tempint int
  DECLARE @firstint int
  DECLARE @secondint int
  SELECT @tempint = CONVERT(int, SUBSTRING(@binvalue,@i,1))
  SELECT @firstint = FLOOR(@tempint/16)
  SELECT @secondint = @tempint - (@firstint*16)
  SELECT @charvalue = @charvalue +
    SUBSTRING(@hexstring, @firstint+1, 1) +
    SUBSTRING(@hexstring, @secondint+1, 1)
  SELECT @i = @i + 1
END

SELECT @hexvalue = @charvalue
GO
 
IF OBJECT_ID ('usp_help_revlogin') IS NOT NULL
  DROP PROCEDURE usp_help_revlogin
GO
CREATE PROCEDURE usp_help_revlogin @login_name sysname = NULL AS
DECLARE @name sysname
DECLARE @type varchar (1)
DECLARE @hasaccess int
DECLARE @denylogin int
DECLARE @is_disabled int
DECLARE @PWD_varbinary  varbinary (256)
DECLARE @PWD_string  varchar (514)
DECLARE @SID_varbinary varbinary (85)
DECLARE @SID_string varchar (514)
DECLARE @tmpstr  varchar (1024)
DECLARE @is_policy_checked varchar (3)
DECLARE @is_expiration_checked varchar (3)

DECLARE @defaultdb sysname
 
IF (@login_name IS NULL)
  DECLARE login_curs CURSOR FOR

      SELECT p.sid, p.name, p.type, p.is_disabled, p.default_database_name, l.hasaccess, l.denylogin FROM 
sys.server_principals p LEFT JOIN sys.syslogins l
      ON ( l.name = p.name ) WHERE p.type IN ( 'S', 'G', 'U' ) AND p.name <> 'sa'
ELSE
  DECLARE login_curs CURSOR FOR


      SELECT p.sid, p.name, p.type, p.is_disabled, p.default_database_name, l.hasaccess, l.denylogin FROM 
sys.server_principals p LEFT JOIN sys.syslogins l
      ON ( l.name = p.name ) WHERE p.type IN ( 'S', 'G', 'U' ) AND p.name = @login_name
OPEN login_curs

FETCH NEXT FROM login_curs INTO @SID_varbinary, @name, @type, @is_disabled, @defaultdb, @hasaccess, @denylogin
IF (@@fetch_status = -1)
BEGIN
  PRINT '--No login(s) found.'
  CLOSE login_curs
  DEALLOCATE login_curs
  RETURN -1
END
SET @tmpstr = '/* usp_help_revlogin script '
--PRINT @tmpstr
SET @tmpstr = '** Generated ' + CONVERT (varchar, GETDATE()) + ' on ' + @@SERVERNAME + ' */'
--PRINT @tmpstr
--PRINT ''
WHILE (@@fetch_status <> -1)
BEGIN
  IF (@@fetch_status <> -2)
  BEGIN
    PRINT ''
    SET @tmpstr = '-- Login: ' + @name
    PRINT @tmpstr
    IF (@type IN ( 'G', 'U'))
    BEGIN -- NT authenticated account/group

      SET @tmpstr = 'CREATE LOGIN ' + QUOTENAME( @name ) + ' FROM WINDOWS WITH DEFAULT_DATABASE = [' + @defaultdb + ']'
    END
    ELSE BEGIN -- SQL Server authentication
        -- obtain password and sid
            SET @PWD_varbinary = CAST( LOGINPROPERTY( @name, 'PasswordHash' ) AS varbinary (256) )
        EXEC usp_hexadecimal @PWD_varbinary, @PWD_string OUT
        EXEC usp_hexadecimal @SID_varbinary,@SID_string OUT
 
        -- obtain password policy state
        SELECT @is_policy_checked = CASE is_policy_checked WHEN 1 THEN 'ON' WHEN 0 THEN 'OFF' ELSE NULL END FROM sys.sql_logins WHERE name = @name
        SELECT @is_expiration_checked = CASE is_expiration_checked WHEN 1 THEN 'ON' WHEN 0 THEN 'OFF' ELSE NULL END FROM sys.sql_logins WHERE name = @name
 
            SET @tmpstr = 'CREATE LOGIN ' + QUOTENAME( @name ) + ' WITH PASSWORD = ' + @PWD_string + ' HASHED, SID = ' + @SID_string + ', DEFAULT_DATABASE = [' + @defaultdb + ']'

        IF ( @is_policy_checked IS NOT NULL )
        BEGIN
          SET @tmpstr = @tmpstr + ', CHECK_POLICY = ' + @is_policy_checked
        END
        IF ( @is_expiration_checked IS NOT NULL )
        BEGIN
          SET @tmpstr = @tmpstr + ', CHECK_EXPIRATION = ' + @is_expiration_checked
        END
    END
    IF (@denylogin = 1)
    BEGIN -- login is denied access
      SET @tmpstr = @tmpstr + '; DENY CONNECT SQL TO ' + QUOTENAME( @name )
    END
    ELSE IF (@hasaccess = 0)
    BEGIN -- login exists but does not have access
      SET @tmpstr = @tmpstr + '; REVOKE CONNECT SQL TO ' + QUOTENAME( @name )
    END
    IF (@is_disabled = 1)
    BEGIN -- login is disabled
      SET @tmpstr = @tmpstr + '; ALTER LOGIN ' + QUOTENAME( @name ) + ' DISABLE'
    END
    PRINT @tmpstr
  END

  FETCH NEXT FROM login_curs INTO @SID_varbinary, @name, @type, @is_disabled, @defaultdb, @hasaccess, @denylogin
   END
CLOSE login_curs
DEALLOCATE login_curs
RETURN 0
GO
/*****************************End Create needed procedures***************************/
SET NOCOUNT ON
Declare 
	@List varchar(max),
	@DatabaseUserName sysname,
	@DB_principal_id smallint,
	@ServerUserName sysname,
	@RoleName sysname,
	@DB_Name sysname,
	@cmd varchar(max),
	@default_schema_name sysname,
	@DB_Nam sysname,
	@state_desc sysname,
	@permission_name sysname ,
	@schema_name sysname ,
	@object_name sysname ,
	@user_name sysname 

/******************************************USER LIST HERE******************************/
/*E.G. 'User1, user3,domain\user1,domain\user2'*/
set @List = 'calamos\tduffy,test'

/*To Script all sql and windows logins uncomment below, note this may re-create undesired accounts and 
should be modified in the where clause when needed*/
select @list = isnull(@list,'') + [name] + ',' from master.sys.server_principals where type in ('S','U','G')

if right(@List,1) <> ','
	Begin
		set @List = @List + ',' 
	End

Create Table ##DB_USERs
(
Name sysname,
DatabaseUserID smallint null,
ServerUserName sysname null,
default_schema_name sysname null
)

Create Table ##DB_Roles
(
Name sysname
)


CREATE TABLE ##syspermissions (
	[DB_Name] [sysname]  NULL ,
	[state_desc] [sysname]  NULL ,
	[permission_name] [sysname]  NULL ,
	[schema_name] [sysname]  NULL ,
	[object_name] [sysname]  NULL ,
	[user_name] [sysname]  NULL,
	[principal_id] [int]  NULL 
)


CREATE TABLE ##SRV_Roles 
(
SERVERROLE VARCHAR(100),
MEMBERNAME VARCHAR(100),
MEMBERSID  VARBINARY (85)
)
/*Loop thru file_list*/
while @List <> '' 
	Begin
		set @DatabaseUserName  = left( @List, charindex( ',', @List ) - 1 )  
		Print '--BEGIN ' + @DatabaseUserName + ' ************************************'
		Print '--********Begin Script the Login ********************************************************'
		/*Script login with password*/
		Execute usp_help_revlogin  @DatabaseUserName
		Print 'GO'
		
		
		/*GET SERVER ROLES INTO TEMPORARY TABLE*/
		SET @CMD = '[MASTER].[DBO].[SP_HELPSRVROLEMEMBER]'
		INSERT INTO ##SRV_Roles EXEC (@CMD)
		
		Set @CMD = ''
		Select @CMD = @CMD + 'EXEC sp_addsrvrolemember  @loginame = ' +  char(39) + MemberName +  char(39) + ', @rolename = ' +  char(39) +  ServerRole +   char(39) + char(10) + 'GO' + char(10)
		from  ##SRV_Roles where MemberName = @DatabaseUserName
		Print '--Assign Server Roles'
		Print @CMD
		Delete ##SRV_Roles
		Print '--********End Script the Login *********************************************************'
		Print ''
		
		/*Get a table with dbs where login has access*/
		set @DB_Name = ''
		While @DB_Name is not null
			Begin
				Select 
					@DB_Name = min(name)
				from 
					master.sys.databases
				where 
				/*limit by database if needed*/
				name > @DB_Name
				--and name in ('Accounting','CAMDW_DST','Employee','FFS_Staging','HRTraining')

				IF @DB_Name IS NULL BREAK

				Set @cmd = 
				'insert ##DB_USERs
				SELECT '
					+ char(39) + @DB_Name + char(39) + ',' + 
					'u.[principal_id],
					l.[name],
					u.default_schema_name
				FROM '
					+ '[' + @DB_Name + '].[sys].[database_principals] u
					INNER JOIN [master].[sys].[server_principals] l
					ON u.[sid] = l.[sid]
				WHERE 
					u.[name] = ' + char(39) + @DatabaseUserName + char(39)
				Exec (@cmd)
			End
		
		/*Add users/roles/object permissions to databases*/
		set @DB_Name = ''
		While @DB_Name is not null
			Begin
				Select 
					@DB_Name = min(name)
				from 
					##DB_USERs
				where 
					name > @DB_Name 
				if @DB_Name is null BREAK

				Print '/************Begin Database ' + @DB_Name + ' ****************/'
				select @ServerUserName = ServerUserName,@DB_principal_id = DatabaseUserID,@default_schema_name = default_schema_name  from ##DB_USERs where name = @DB_Name
				Set @cmd = 
				'USE [' + @DB_Name + '];' + char(10) +
				'CREATE USER [' + @DatabaseUserName + ']' + char(10) +
			    CHAR(9) + 'FOR LOGIN [' + @ServerUserName + ']' + char(10) +
				CHAR(9) + 'With DEFAULT_SCHEMA  = [' + @default_schema_name + ']' + char(10) +
				'GO' 
				Print '--Add user to databases'
				Print @cmd
		
				/*Populate roles for this user*/
				Select @cmd = 
				'Insert ##DB_Roles
				Select name
				FROM '
					+ '[' + @DB_Name + '].[sys].[database_principals]
				WHERE
					[principal_id] IN (SELECT [role_principal_id] FROM [' +  @DB_Name + '].[sys].[database_role_members] WHERE [member_principal_id] = ' + cast(@DB_principal_id as varchar(25)) + ')'
				--Print @cmd
				Exec (@cmd)
				
				/*Add user to roles*/
				Set @cmd = ''
				Select @cmd = isnull(@cmd,'') +  'EXEC [sp_addrolemember]' + char(10) +
				CHAR(9) + '@rolename = ''' + Name + ''',' + char(10) +
				CHAR(9) + '@membername = ''' + @DatabaseUserName + ''''+ char(10) +
				'GO' + char(10)
				from ##DB_Roles
				if len(@cmd) > 0
					Print '--Add user to role(s)'
				Print @cmd
		
				Delete ##DB_Roles
		
				/*Object Permissions*/

				Set @cmd =
				'
				Insert ##syspermissions
				select ' + char(39) + @DB_Name + char(39) + ',a.[state_desc],a.[permission_name], d.[name],b.[name],c.[name],c.[principal_id] 
				from '
					+ '[' + @DB_Name + '].sys.database_permissions A
					JOIN ' + '[' + @DB_Name + '].[sys].[objects] b 
						ON A.major_id = B.object_id
					JOIN ' + '[' + @DB_Name + '].[sys].[database_principals] c
						ON grantee_principal_id = c.principal_id
					JOIN '+ '[' + @DB_Name + '].sys.schemas d
						ON b.schema_id = d.schema_id'

				Exec (@cmd)
				If exists (select 1 from ##syspermissions where principal_id = @DB_principal_id)
					Print '--Assign specific object permissions'

			
				DECLARE crs_Permissions CURSOR LOCAL FORWARD_ONLY READ_ONLY
				FOR
				SELECT 
					[DB_Name],
					[state_desc],
					[permission_name] ,
					[schema_name] ,
					[object_name] ,
					[user_name] 
				FROM
					##syspermissions
				Where 
					principal_id = @DB_principal_id

				OPEN crs_Permissions
				FETCH NEXT FROM crs_Permissions INTO @DB_Name,@state_desc,@permission_name ,@schema_name ,@object_name ,@user_name 
				WHILE @@FETCH_STATUS = 0
					BEGIN
						SET @cmd = @state_desc + ' ' + @permission_name + ' ON [' + @schema_name + '].[' + @object_name + '] TO [' + @user_name  + ']'
						Print @cmd
						FETCH NEXT FROM crs_Permissions INTO @DB_Name,@state_desc,@permission_name ,@schema_name ,@object_name ,@user_name 
					END
					CLOSE crs_Permissions
					DEALLOCATE crs_Permissions
				
				delete ##syspermissions
				
				
				Print '/************End Database ' + @DB_Name + ' ****************/'
				Print ''
				/*next db*/
			End
		Print '--END ' + @DatabaseUserName + ' ************************************'
		Print ''
		/*Parse the list down*/
		set @List = right( @List, datalength( @List  ) - charindex( ',', @List ) ) 
		/*Clear data for the last user*/
		Delete ##DB_USERs 
	End
/*Clean up*/
Drop table ##DB_USERs
Drop table ##DB_Roles
drop table ##syspermissions
Drop table ##SRV_Roles

use master
Drop procedure usp_help_revlogin
Drop procedure usp_hexadecimal

