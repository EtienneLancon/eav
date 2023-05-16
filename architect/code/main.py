from psycopg2 import Error
from db.connection import Connection
from app.repository.mv_data_lazyness_repository import MvDataLazynessRepository
from serializer.serializer import Serializer
import json

async def app(scope, receive, send):
    assert scope['type'] == 'http'

    try:
        repository = MvDataLazynessRepository()

        body = ''

        result = repository.select()

        json_object = Serializer().serialize(result, repository.columns)

        body = body + json.dumps(json_object)

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