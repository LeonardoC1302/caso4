import pyodbc
import threading

# Connection details
server = 'localhost'
database = 'caso3'
username = 'root'
password = '123456'

# Stored procedure parameters
producerId = 1

# Function to execute the stored procedure
def execute_stored_procedure():
    conn_str = f'DRIVER=SQL Server;SERVER={server};DATABASE={database};UID={username};PWD={password}'
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()
    data = cursor.execute("EXEC [dbo].[GetWasteMovementsByProducer] ?", producerId)
    totalResults = 0
    for row in data:
        totalResults += 1
        # print(row)
    
    print("Cantidad de resultados: " ,totalResults)
    conn.commit()
    conn.close()

# Function to modify the data in the wasteMovements table
def modify_wastes():
    conn_str = f'DRIVER=SQL Server;SERVER={server};DATABASE={database};UID={username};PWD={password}'
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()
    cursor.execute("INSERT INTO wasteMovements (posttime, responsibleName, signImage, addressId, movementTypeId, contractId, quantity, userId, checksum, computer, containerId, wasteId, carId) OUTPUT inserted.wasteMovementId VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)", "2023-01-01 00:00:00.000", "phantom", 0, 1, 1, 1, 999.9, 1, 0, "Computer Phantom", 1, 1, 1)
    wasteMovementId = cursor.fetchone()[0]
    # print(wasteMovementId)
    cursor.execute("INSERT INTO producersXmovements (producerId, wasteMovementId) VALUES (?,?)", 1,wasteMovementId)
    conn.commit()
    conn.close()

# Create multiple threads to execute the stored procedure simultaneously and modify the data in the wasteMovements table
threads = []
num_threads = 2

for i in range(num_threads):
    if i == 0:
        thread = threading.Thread(target=execute_stored_procedure)
        threads.append(thread)
        thread.start()
    else:
        thread = threading.Thread(target=modify_wastes)
        threads.append(thread)
        thread.start()

# Wait for all threads to finish
for thread in threads:
    thread.join()

print(" -- Segunda ejecucion --")
execute_stored_procedure()