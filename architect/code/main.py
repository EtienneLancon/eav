from psycopg2 import Error
from db.connection import Connection


async def app(scope, receive, send):
    assert scope['type'] == 'http'

    try:
        # Connect to an existing database
        # Create a cursor to perform database operations
        cursor = Connection.getCursor()
        # Print PostgreSQL details
        body = "PostgreSQL server information\n"
        # Executing a SQL query
        cursor.execute("SELECT version();")
        # Fetch result
        record = cursor.fetchone()
        
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