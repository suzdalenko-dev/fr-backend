from compras.only_sql.stock_sql import get_stok_data_sql
from froxa.utils.connectors.libra_connector import OracleConnector
from produccion.utils.get_me_stock_file import get_me_stock_now


def stock_calculation(request):
    oracle     = OracleConnector()
    oracle.connect()

    stock = get_stok_data_sql(oracle)
    return {'stock': stock}