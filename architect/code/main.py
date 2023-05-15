import psycopg2
from psycopg2 import Error
import os
import json
import struct


async def app(scope, receive, send):
    assert scope['type'] == 'http'

    try:
        # Connect to an existing database
        connection = psycopg2.connect(user=os.environ['POSTGRES_USER'],
                                    password=os.environ['POSTGRES_PASSWORD'],
                                    host=os.environ['POSTGRES_HOST'],
                                    port=os.environ['POSTGRES_PORT'],
                                    database=os.environ['POSTGRES_DB'])
        # Create a cursor to perform database operations
        cursor = connection.cursor()
        # Print PostgreSQL details
        body = "PostgreSQL server information\n"
        body = body + json.dumps(connection.get_dsn_parameters())
        # Executing a SQL query
        cursor.execute("SELECT version();")
        # Fetch result
        record = cursor.fetchone()
        print("You are connected to - ", record, "\n")
        body = body + "\nYou are connected to - " + record[0]

        body = body.encode('utf-8')

    except (Exception, Error) as error:
        print("Error while connecting to PostgreSQL", error)

    
    headers = [
        (b'Content-Type', 'text/plain'),
        (b'Content-Length', str(len(body)).encode('utf-8'))
    ]

    # Send the HTTP response
    await send({
        'type': 'http.response.start',
        'status': 200,
        'headers': headers
    })
    await send({
        'type': 'http.response.body',
        'body': body
    })

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host='0.0.0.0', port=8000)