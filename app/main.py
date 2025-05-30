import os
import oracledb
from flask import Flask, jsonify

app = Flask(__name__)

# Oracle database connection details
# It's recommended to use environment variables for sensitive information
ORACLE_USER = os.getenv('ORACLE_USER', 'your_oracle_user')
ORACLE_PASSWORD = os.getenv('ORACLE_PASSWORD', 'your_oracle_password')
ORACLE_HOST = os.getenv('ORACLE_HOST', 'localhost')
ORACLE_PORT = os.getenv('ORACLE_PORT', '1521')
ORACLE_SERVICE_NAME = os.getenv('ORACLE_SERVICE_NAME', 'your_oracle_service_name')

def get_oracle_connection():
    try:
        dsn = f"{ORACLE_HOST}:{ORACLE_PORT}/{ORACLE_SERVICE_NAME}"
        connection = oracledb.connect(user=ORACLE_USER, password=ORACLE_PASSWORD, dsn=dsn)
        return connection
    except oracledb.Error as e:
        error_obj, = e.args
        print(f"Error connecting to Oracle database: {error_obj.message}")
        return None

@app.route('/')
def hello_world():
    return 'Hello from Text2SQL MCP Server (Python & Oracle)!', 200

@app.route('/test-db-connection')
def test_db_connection():
    connection = None
    try:
        connection = get_oracle_connection()
        if connection:
            cursor = connection.cursor()
            cursor.execute("SELECT SYSDATE FROM DUAL")
            result = cursor.fetchone()
            return jsonify({"status": "success", "message": f"Successfully connected to Oracle. Current date: {result[0]}"}), 200
        else:
            return jsonify({"status": "error", "message": "Failed to connect to Oracle database."}), 500
    except Exception as e:
        return jsonify({"status": "error", "message": f"An error occurred: {str(e)}"}), 500
    finally:
        if connection:
            connection.close()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
