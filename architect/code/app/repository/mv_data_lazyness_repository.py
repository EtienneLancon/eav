from .abstractrepository import AbstractRepository

class MvDataLazynessRepository(AbstractRepository):
    def __init__(self):
        super().__init__('mv_data_lazyness')