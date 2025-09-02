from compras.only_sql.stock_sql import get_stok_data_sql
from froxa.utils.connectors.libra_connector import OracleConnector
from produccion.utils.get_me_stock_file import get_me_stock_now


def stock_calculation(request):
    oracle     = OracleConnector()
    oracle.connect()

    stock = get_stok_data_sql(request, oracle)
    return {'stock': stock}






"""

edi de 001393 COVIRAN configurar EDI


"""









"""
a las 11 de la noche aviso almacen@froxa.com

aviso a Gema de los palets que hay:
    Desde almacen: 90 PRODUCCION / FABRICA 
    Hasta almacen: 90 PRODUCCION / FABRICA

    Desde Codigo Entrada: PRODUCCION CODIGO ENTRADA MAQUILA FM
    Hasta cod. Entrada:   PRODUCCION CODIGO ENTRADA MAQUILA FM
"""