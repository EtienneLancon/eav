from psycopg2 import connect
import os

class Connection:
    connection = None
    
    @staticmethod
    def getConn():
        if Connection.connection is None:
            Connection.connection = connect(
                user = os.environ['POSTGRES_USER'],
                password = os.environ['POSTGRES_PASSWORD'],
                host = os.environ['POSTGRES_HOST'],
                port = os.environ['POSTGRES_PORT'],
                database = os.environ['POSTGRES_DB']
            )
        return Connection.connection
    

    @staticmethod
    def getCursor():
        return Connection.getConn().cursor()

    @staticmethod
    def close():
        Connection.getConn().close()

    @staticmethod
    def commit():
        Connection.getConn().commit()

    @staticmethod
    def rollback():
        Connection.getConn().rollback()