from db.db_connection import DBConnection

db_connection = DBConnection()
result = db_connection.execute('SELECT * FROM videos')
print(result)