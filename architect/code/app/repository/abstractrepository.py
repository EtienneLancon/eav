from db.connection import Connection
from db.reader import Reader
from abc import ABC, abstractmethod

class AbstractRepository(ABC):
    connection = Connection.getConn()
    schema = 'eav'

    @abstractmethod
    def __init__(self, table):
        self.query = None
        self.table = table
        self.getColumns()

    def __exit__(self):
        self.connection.close()
    
    def select(self, fields = None, where = None, order = None, limit = None):
        cursor = self.connection.cursor()

        if fields is None:
            fields = '*'
        else:
            fields = ', '.join(fields)

        if where is None:
            where = ''
        else:
            where = ' WHERE ' + where
        
        if order is None:
            order = ''
        else:
            if type(order) is list:
                order = ' ORDER BY ' + ', '.join(order)
            else:
                order = ' ORDER BY ' + order

        if limit is None:
            limit = ''
        else:
            limit = ' LIMIT ' + limit

        self.query = 'SELECT ' + fields + ' FROM '+ self.schema + '.' + self.table + where + order + limit

        cursor.execute(self.query)
        
        return cursor.fetchall()


    def getColumns(self):
        cursor = self.connection.cursor()
        cursor.execute("SELECT column_name FROM information_schema.columns WHERE table_schema = '" + self.schema + "' AND table_name = '" + self.table + "'")
        self.columns = Reader(cursor).fetchcolumn()