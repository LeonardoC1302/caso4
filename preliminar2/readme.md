# Create users to prove:
###  It is possible to deny all access to the database tables and operate it only by executing stored procedures
- We will be using an user called sp
- Create a new user and make sure to uncheck the 'map' option of the database on the User Mapping section
- Use T-SQL to grant permissions to the user to execute the stored procedures
```sql
GRANT EXECUTE ON [schema].[procedure_name] TO [user_or_role]
```

### It is possible to restrict the visibility of columns to certain users
- After creating an user with permissions on the database, use T-SQL to deny access to certain columns
```sql
DENY SELECT ON [dbo].[YourTableName] (RestrictedColumn1, RestrictedColumn2) TO [YourUserName]
```

### Roles can be created, and users can belong to roles. Those roles could have table and column restrictions that apply to the users that belong to said role
- Create a new role with the following T-SQL
```sql
USE YourDatabaseName; -- Specify the database where you want to create the role
CREATE ROLE [YourRoleName];
```
- Execute the following T-SQL to deny access to specific columns
```sql
DENY SELECT ON [dbo].[YourTableName] (DeniedColumn1, DeniedColumn2) TO [YourRoleName];
```
- Execute the following T_SQL to deny access to specific tables
```sql
DENY SELECT ON [dbo].[YourTableName] TO [YourRoleName];
```
- Execute the following T-SQL to add a user to the role
```sql
EXEC sp_addrolemember 'YourRoleName', 'YourUserName';
```

### How sql server resolves permission priorities in the hierarchy, for example that a higher level denies access to something and a lower level is assigned
- SQL Server follows a permission hierarchy where explicit DENY permissions take precedence over explicit GRANT permissions. 
- Basically, it follows this priority order from highest to lowest:
1. Explicit DENY
2. Explicit GRANT
3. Implicit DENY by database roles (public, db_owner, db_datareader, etc.)
4. Implicit GRANT by server roles (sysadmin, securityadmin, etc.)

# Testing the user permissions or restrictions
# Demonstration of the backup and restore process
## Full Backup
- Open SSMS and go to the Object Explorer
- Right click on the database you want to backup and select Tasks -> Back Up
- Select the backup type as 'Full'
- Select the destination of the backup file
- Click on 'OK' to start the backup process

## Incremental Backup
- Open SSMS and go to the Object Explorer
- Right click on the database you want to backup and select Tasks -> Back Up
- Select the backup type as 'Differential'
- Select the destination of the backup file
- Click on 'OK' to start the backup process
- This backup will only contain the changes made since the last full backup

## Restore
- Open SSMS and go to the Object Explorer
- Right click on databases and select 'Restore Database'
- Select the 'Device' option and click on the '...' button to select the backup file
- Select the backup file and click on 'OK'
- On 'Destination' select the database you want to restore the backup to or create a new one
- Click on 'OK' to start the restore process
- The database will be restored to the state it was when the backup was made

# Reporting Services
- Install SQL Server Reporting Services
- After the installation, open the Reporting Services Configuration Manager
- On 'Databases', click on 'Change Database'
- Select 'Create a new report server database' and click on 'Next'
- Put the login credentials and click on 'Next'
- Create a new database name and click on 'Next'
- Select 'Service Credentials' and click on 'Next'
- Use Port 8080 on the next 2 steps
- Go to 'Web Service URL' and click on 'Apply'
- Go to 'Web Portal URL' and click on 'Apply'
- Go to 'Encryption Keys' and click on 'Backup'

<!-- Leo's Link http://leoc:8080/Reports/browse -->