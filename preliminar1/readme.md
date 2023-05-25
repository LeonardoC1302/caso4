# How can I test each problem? 
## Dirty Read
- On one query window execute 'exec UpdateProductQuantity 1, 60'
- Afterwards, execute 'exec GetProductQuantity 1' on another window
- With the original sp, you should get 110 as Quantity
- With the updated one, you should get 50 because the sp is not reading uncommitted data
- Check the files on [DirtyRead](./dirtyRead/)

## Lost update
- On one query window execute 'exec registerSales 1, 1, 1, 50.0, 1, 1, 30'
- Afterwards, execute 'exec addProduct 1, 30' on another window
- With the original sp, you should get a 20 as final quantity
- With the updated one, you should get 50 because the update is not lost
- Check the files on [LostUpdate](./lostUpdate/)

## Phantom
- On one query window execute 'exec GetWasteMovementsByProducer 1'
- Afterwards, execute 'exec InsertWasteMovements "2023-01-01 00:00:00.000", "phantom", 0, 1, 1, 1, 999.9, 1, 0, "Computer Phantom", 1, 1, 1, 1' on another query window.
- With the original sp, you should get a difference in the total registers returned.
- With the updated one, both quantities should be equal.
- Check the files on [Phantom](./phantom/)

## Deadlock
- On one query window execute 'exec moneyTransaction @senderId=1, @receiverId =2, @amount=100 
- Afterwards, execute 'exec moneyTransaction @senderId=2, @receiverId =1, @amount=100 on another query window.
- This should create a deadlock on the system
- With the updated one when you run both querys there won´t be a deadlock
- Check the files on [Deadlock](./deadlock/)

# How to check if encryption is working?
- On one query window, execute this code:
```sql
SELECT 
    m.definition
FROM 
    sys.sql_modules m
INNER JOIN 
    sys.objects o ON m.object_id = o.object_id
WHERE 
    o.type = 'P' -- Filter for stored procedures
    AND o.name = 'registerSales'; -- Replace with the name of your stored procedure
```
- Also, go to programability section, you shouldn't be able to modify or see the code of the stored procedure.
- Finally, execute this query to verify if the stored procedure is encrypted:
```sql
sp_HelpText [registerSales]
```
# What does each Job do?
## Recompile Stored Procedures
```sql
DECLARE @sql NVARCHAR(MAX);

SET @sql = '';

SELECT @sql = @sql + 'EXEC sp_recompile ''' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ''';' + CHAR(13)
FROM sys.procedures
WHERE OBJECTPROPERTY(OBJECT_ID, 'IsMSShipped') = 0;

EXEC sp_executesql @sql;
```

## Copy Register and Delete Old Information
### Copy Data
```sql
DECLARE @MaxID INT;

-- Insert into [caso3].[dbo].[sources]
SELECT @MaxID = ISNULL(MAX(sourceId), 0)
FROM [caso3].[dbo].[sources];

INSERT INTO [caso3].[dbo].[sources]
SELECT sourceName
FROM [LEOC\SQLSERVER2022].[caso3].[dbo].[sources]
WHERE sourceId > @MaxID;

-- Insert into [caso3].[dbo].[levels]
SELECT @MaxID = ISNULL(MAX(levelId), 0)
FROM [caso3].[dbo].[levels];

INSERT INTO [caso3].[dbo].[levels]
SELECT description
FROM [LEOC\SQLSERVER2022].[caso3].[dbo].[levels]
WHERE levelId > @MaxID;

-- Insert into [caso3].[dbo].[objectTypes]
SELECT @MaxID = ISNULL(MAX(objectTypeId), 0)
FROM [caso3].[dbo].[objectTypes];

INSERT INTO [caso3].[dbo].[objectTypes]
SELECT objectName
FROM [LEOC\SQLSERVER2022].[caso3].[dbo].[objectTypes]
WHERE objectTypeId > @MaxID;

-- Insert into [caso3].[dbo].[eventTypes]
SELECT @MaxID = ISNULL(MAX(eventTypeId), 0)
FROM [caso3].[dbo].[eventTypes];

INSERT INTO [caso3].[dbo].[eventTypes]
SELECT typeName
FROM [LEOC\SQLSERVER2022].[caso3].[dbo].[eventTypes]
WHERE eventTypeId > @MaxID;

-- Insert into [caso3].[dbo].[eventLogs]
SELECT @MaxID = ISNULL(MAX(eventId), 0)
FROM [caso3].[dbo].[eventLogs];

INSERT INTO [caso3].[dbo].[eventLogs]
SELECT posttime, computer, username, checksum, description, referenceId1, referenceId2, value1, value2, sourceId, levelId, eventTypeId, objectTypeId
FROM [LEOC\SQLSERVER2022].[caso3].[dbo].[eventLogs]
WHERE eventId > @MaxID;
```
### Delete Data
```sql
DELETE FROM [LEOC\SQLSERVER2022].[caso3].[dbo].[eventLogs]
WHERE eventId NOT IN (
    SELECT MAX(eventId)
    FROM [LEOC\SQLSERVER2022].[caso3].[dbo].[eventLogs]
);

DELETE FROM [LEOC\SQLSERVER2022].[caso3].[dbo].[sources]
WHERE sourceId NOT IN (
    SELECT MAX(sourceId)
    FROM [LEOC\SQLSERVER2022].[caso3].[dbo].[sources]
);

DELETE FROM [LEOC\SQLSERVER2022].[caso3].[dbo].[levels]
WHERE levelId NOT IN (
    SELECT MAX(levelId)
    FROM [LEOC\SQLSERVER2022].[caso3].[dbo].[levels]
);

DELETE FROM [LEOC\SQLSERVER2022].[caso3].[dbo].[objectTypes]
WHERE objectTypeId NOT IN (
    SELECT MAX(objectTypeId)
    FROM [LEOC\SQLSERVER2022].[caso3].[dbo].[objectTypes]
);

DELETE FROM [LEOC\SQLSERVER2022].[caso3].[dbo].[eventTypes]
WHERE eventTypeId NOT IN (
    SELECT MAX(eventTypeId)
    FROM [LEOC\SQLSERVER2022].[caso3].[dbo].[eventTypes]
);
```