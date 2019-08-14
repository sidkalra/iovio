DROP TABLE IF EXISTS dbo.WorkflowStatusChange; 

CREATE TABLE dbo.WorkflowStatusChange (
Id bigint IDENTITY(1,1) NOT NULL,
class smallint NOT NULL,
fromStatus bigint NULL,
statusChangeBy bigint NULL,
statusChangedDate datetime NOT NULL,
streamingObject bigint NULL,
toStatus bigint NULL,
IngangsAuthenticatieEventsOverslaan bit DEFAULT 0 NOT NULL, MotivatieIngangsAuthenticatieEventsOverslaan nvarchar(4000));

insert into  
 dbo.WorkflowStatusChange (class, fromStatus, statusChangeBy, statusChangedDate, streamingObject, toStatus, 
 	IngangsAuthenticatieEventsOverslaan) 
values(101,1,110,'2014-05-23T14:25:10',1,2,0);
insert into  
 dbo.WorkflowStatusChange (class, fromStatus, statusChangeBy, statusChangedDate, streamingObject, toStatus, 
 	IngangsAuthenticatieEventsOverslaan) 
values(101,1,110,'2015-05-23T14:25:10',2,3,0);
insert into  
 dbo.WorkflowStatusChange (class, fromStatus, statusChangeBy, statusChangedDate, streamingObject, toStatus, 
 	IngangsAuthenticatieEventsOverslaan) 
values(101,1,110,'2014-06-23T14:25:10',4,2,0);
insert into  
 dbo.WorkflowStatusChange (class, fromStatus, statusChangeBy, statusChangedDate, streamingObject, toStatus, 
 	IngangsAuthenticatieEventsOverslaan) 
values(101,1,110,'2015-07-23T14:25:10',3,2,0);


DROP TABLE IF EXISTS dbo.StreamingObject; 
CREATE TABLE dbo.StreamingObject (
Id BIGINT PRIMARY Key,
name varchar(50)
);

DROP TABLE IF EXISTS dbo.StatusDefinition;
CREATE TABLE dbo.StatusDefinition (
Id BIGINT PRIMARY Key,
name varchar(50)
);

insert into dbo.StatusDefinition values(1,'started');
insert into dbo.StatusDefinition values(2,'running');
insert into dbo.StatusDefinition values(3,'finished');


insert into dbo.StreamingObject values(1,'object1');
insert into dbo.StreamingObject values(2,'object2');
insert into dbo.StreamingObject values(3,'object3');
insert into dbo.StreamingObject values(4,'object4');



IF EXISTS (SELECT * FROM [dbo].[sysobjects]
           WHERE ID = object_id(N'[dbo].[CheckValidStatus]') AND
                 XTYPE IN (N'FN', N'IF', N'TF'))
    DROP FUNCTION [dbo].[CheckValidStatus]

GO

CREATE FUNCTION dbo.CheckValidStatus(@fromStatus BIGINT, @toStatus BIGINT)
RETURNS BIT
AS
BEGIN
    IF @fromStatus in (select Id from dbo.StatusDefinition) AND @toStatus in (select Id from dbo.StatusDefinition)
        RETURN 1
    RETURN 0
END

GO

DROP FUNCTION IF EXISTS dbo.getUTF8OrDefault;

CREATE FUNCTION dbo.getUTF8OrDefault()
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @collation_name VARCHAR(100)
    IF EXISTS (Select name from sys.fn_helpcollations() where name ='Latin1_General_100_CI_AS_SC_UTF8')
        set @collation_name = 'Latin1_General_100_CI_AS_SC_UTF8'
    SELECT @collation_name=COLLATION_NAME
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_SCHEMA = 'dbo'
		AND TABLE_NAME = 'WorkflowStatusChange'
		AND COLLATION_NAME IS NOT NULL
    RETURN @collation_name
END

GO

ALTER TABLE dbo.WorkflowStatusChange ADD PRIMARY KEY (Id);
ALTER TABLE dbo.WorkflowStatusChange ADD FOREIGN KEY (streamingObject) REFERENCES StreamingObject(Id);
ALTER TABLE dbo.WorkflowStatusChange ADD CONSTRAINT CHK_Status CHECK (dbo.CheckValidStatus(fromStatus, toStatus) = 1);
ALTER TABLE dbo.WorkflowStatusChange ADD CONSTRAINT toStatus_cascade_delete FOREIGN KEY
(toStatus) REFERENCES dbo.StatusDefinition (Id) ON DELETE CASCADE;
ALTER TABLE dbo.WorkflowStatusChange ADD messageFile VARCHAR(MAX);


DECLARE @dbowner VARCHAR(128) = 'dbo'
DECLARE @tablename VARCHAR(128) = 'WorkflowStatusChange'
DECLARE @columnname VARCHAR(128) = 'MotivatieIngangsAuthenticatieEventsOverslaan'
DECLARE @sql NVARCHAR(256) = 'ALTER TABLE '+QUOTENAME(@dbowner)+'.'+QUOTENAME(@tablename)
SET @sql = @sql + ' ALTER COLUMN '+ QUOTENAME(@columnname) + ' nvarchar(4000) collate ' + dbo.getUTF8OrDefault()
exec sp_executeSQL @sql;

	
