from psycopg2.extensions import cursor

class Reader:
    def __init__(self, cursor: cursor):
        self.cursor = cursor

    def fetchcolumn(self):
        result = []
        row = self.cursor.fetchone()
        while row is not None:
            result.append(row[0])
            row = self.cursor.fetchone()
        return result