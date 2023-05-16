from psycopg2 import Error
from app.repository.mv_data_lazyness_repository import MvDataLazynessRepository
from serializer.serializer import Serializer
import json
from db.connection import Connection

async def app(scope, receive, send):
    assert scope['type'] == 'http'

    body = ''

    try:
        repository = MvDataLazynessRepository()

        

        result = repository.select()

        json_object = Serializer().serialize(result, repository.columns)

        repository.insert({'name': 'toto'})

        body = body + json.dumps(json_object)

    except (Exception, Error) as error:
        body = body + str(error)
        Connection.rollback()


    body = body.encode('utf-8')
    
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