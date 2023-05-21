import pyodbc
import threading

# Connection details
server = 'localhost'
database = 'caso3'
username = 'root'
password = '123456' 

# Stored procedure parameters
product = 1
quantity = 60 # Greater than 50 to read the dirty data (rollback)

def execute_update():
    conn_str = f'DRIVER=SQL Server;SERVER={server};DATABASE={database};UID={username};PWD={password}'
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()

    cursor.execute("EXEC [dbo].[UpdateProductQuantity] ?, ?", product, quantity)
    conn.commit()
    conn.close()

def execute_read():
    conn_str = f'DRIVER=SQL Server;SERVER={server};DATABASE={database};UID={username};PWD={password}'
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()

    cursor.execute("EXEC [dbo].[GetProductQuantity] ?", product)

    rows = cursor.fetchall()
    for row in rows:
        print(row)
    
    conn.commit()
    conn.close()

# Create multiple threads to execute the stored procedures simultaneously
threads = []
num_threads = 2

for i in range(num_threads):
    if i == 0:
        thread = threading.Thread(target=execute_update)
        threads.append(thread)
        thread.start()
    else:
        thread = threading.Thread(target=execute_read)
        threads.append(thread)
        thread.start()



# Wait for all threads to finish
for thread in threads:
    thread.join()

