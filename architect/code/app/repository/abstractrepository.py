from db.connection import Connection
from db.reader import Reader
from abc import ABC, abstractmethod
from psycopg2 import sql

class AbstractRepository(ABC):
    connection = Connection.getConn()
    schema = 'eav'

    @abstractmethod
    def __init__(self, table):
        self.query = None
        self.table = table
        self.cursor = self.connection.cursor()
        self.getColumns()

    def __exit__(self):
        self.connection.close()
    
    def select(self, fields = None, where = None, order = None, limit = None):

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

        self.cursor.execute(self.query)
        
        return self.cursor.fetchall()


    def getColumns(self):
        self.cursor.execute("SELECT column_name FROM information_schema.columns WHERE table_schema = '" + self.schema + "' AND table_name = '" + self.table + "'")
        self.columns = Reader(self.cursor).fetchcolumn()

    def execute(self, query, data: dict):
        values = []

        for key in data:
            values.append(data[key])

        print(values)

        self.cursor.execute(self.query, data)

        self.connection.commit()

        return self.cursor.fetchone()
        


    def insert(self, data: dict):

        print(data)

        columns = data.keys()

        print(columns)

        self.query = sql.SQL('INSERT INTO {0} ({1}) VALUES ({2}) RETURNING id') \
            .format(sql.Identifier(self.schema, self.table), \
                    sql.SQL(', ').join(map(sql.Identifier, columns)), \
                    sql.SQL(', ').join(map(sql.Placeholder, columns)))

        print(self.query.as_string(self.connection))

        result = self.execute(self.query, data)

        print(result)