class Serializer:
    def __init__(self):
        self.data = None
        self.columns = None

    def serialize(self, data, columns):
        self.data = data
        self.columns = columns
        result = []
        for row in self.data:
            result.append(self.serializeRow(row))

        return result

    def serializeRow(self, row):
        result = {}
        for i in range(len(self.columns)):
            result[self.columns[i]] = row[i]
        return result