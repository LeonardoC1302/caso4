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
quantity = 30

# Function to execute the stored procedure
def execute_stored_procedure():
    conn_str = f'DRIVER=SQL Server;SERVER={server};DATABASE={database};UID={username};PWD={password}'
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()
    cursor.execute("EXEC [dbo].[registerSales] ?, ?, ?, ?, ?, ?, ?", client, product, seller, total_price, payment_type, contract, quantity)
    conn.commit()
    conn.close()

# Create multiple threads to execute the stored procedure simultaneously
threads = []
num_threads = 2

for i in range(num_threads):
    thread = threading.Thread(target=execute_stored_procedure)
    threads.append(thread)
    thread.start()

# Wait for all threads to finish
for thread in threads:
    thread.join()
