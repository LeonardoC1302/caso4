import pyodbc
import threading

# Connection details
server = 'localhost'
database = 'caso3'
username = 'root'
password = '123456'

# Stored procedure parameters
client = 1
product = 1
seller = 1
total_price = 50.00
payment_type = 1
contract = 1
quantitySale = 30
quantityUpdate = 10

# Barrier to synchronize the start of the threads
barrier = threading.Barrier(2)

def execute_sales():
    conn_str = f'DRIVER=SQL Server;SERVER={server};DATABASE={database};UID={username};PWD={password}'
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()

    # Wait for the barrier to synchronize the start of the threads
    barrier.wait()

    cursor.execute("EXEC [dbo].[registerSales] ?, ?, ?, ?, ?, ?, ?", client, product, seller, total_price, payment_type, contract, quantitySale)
    conn.commit()
    conn.close()

def execute_inventory():
    conn_str = f'DRIVER=SQL Server;SERVER={server};DATABASE={database};UID={username};PWD={password}'
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()

    # Wait for the barrier to synchronize the start of the threads
    barrier.wait()

    cursor.execute("EXEC [dbo].[updateInventory] ?, ?", product, quantityUpdate)
    conn.commit()
    conn.close()

# Create multiple threads to execute the stored procedures simultaneously
inventory_thread = threading.Thread(target=execute_inventory)
sales_thread = threading.Thread(target=execute_sales)

# Start both threads
inventory_thread.start()
sales_thread.start()

# Wait for both threads to finish
inventory_thread.join()
sales_thread.join()

# Check the quantity in the inventoryProduct table
conn_str = f'DRIVER=SQL Server;SERVER={server};DATABASE={database};UID={username};PWD={password}'
conn = pyodbc.connect(conn_str)
cursor = conn.cursor()
cursor.execute("SELECT quantity FROM inventoryProduct WHERE productId = ?", product)
result = cursor.fetchone()
conn.close()

if result is not None:
    quantity = result[0]
    print(f"The quantity in inventoryProduct for productId {product} is: {quantity}")
else:
    print("No rows found")
