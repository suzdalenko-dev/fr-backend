from froxa.utils.connectors.erp_old_connector import MySQLConn
from froxa.utils.connectors.libra_connector import OracleConnector


def get_belin_routes(request):

    conn = MySQLConn()
    conn.connect()

    sql = """SELECT * FROM recogida ORDER BY id DESC LIMIT 22"""
    data = conn.consult(sql)
    conn.close()

    return data


def get_all_of_route(request, code):
    oracle = OracleConnector()
    oracle.connect()

    conn = MySQLConn()
    conn.connect()

    # travel list
    sql = """SELECT DISTINCT __camion, __nombre__camion FROM lineaentrega WHERE __recogida__id = %s AND __camion > 0 ORDER BY __camion ASC"""
    travel_list = conn.consult(sql, (code,))  
    
    # list of travel orders
    for travel in travel_list:
        sql         = """SELECT id, __recogida__id, __pedido__id, __cliente__id, __cliente__descripcion FROM lineaentrega WHERE __recogida__id = %s AND __camion =%s"""
        all_lines   = conn.consult(sql, (code, travel['__camion'],))  
        travel['all_lines'] = all_lines

    # unique clients in travel
    for travel in travel_list:
        unique_client_travel = []
        res                  = []

        for line in travel['all_lines']:
            cliente_name = str(line['__cliente__id']).strip() +" "+str(line['__cliente__descripcion']).strip()
            if cliente_name not in unique_client_travel:
                unique_client_travel += [cliente_name]
                res                  += [{'name': cliente_name, 'orders':[], 'detail':[]}]
        
        travel['unique_client'] = unique_client_travel
        travel['res'] = res


    for travel in travel_list:
        for clientA in travel['res']:
            for line in travel['all_lines']:
                cliente_name = str(line['__cliente__id']).strip() +" "+str(line['__cliente__descripcion']).strip()
                if clientA['name'] == cliente_name:
                    clientA['orders'] += [line['__pedido__id']]
                    

    for travel in travel_list:
        for clientB in travel['res']:
            for id_order in clientB['orders']:
                parts = str(id_order).strip().split("-")
                if len(parts) == 3:
                    year, serie, number_code = parts
                    sqlDetail = """select ARTICULO, DESCRIPCION_ARTICULO, UNIDADES_SERVIDAS, UNI_SERALM, PRESENTACION_PEDIDO, 
                                        EJERCICIO_PEDIDO || '-' || NUMERO_SERIE_PEDIDO || '-' || NUMERO_PEDIDO AS ID_PEDIDO,
                                        EJERCICIO_PEDIDO || '-' || NUMERO_SERIE || '-' || NUMERO_ALBARAN AS ID_ALBARAN
                                from ALBARAN_VENTAS_LIN
                                where NUMERO_PEDIDO = :number_code
                                    AND NUMERO_SERIE_PEDIDO = :serie
                                    AND EJERCICIO_PEDIDO = :year
                                """
                    rows_diario  = oracle.consult(sqlDetail, {'number_code':number_code, 'serie':serie, 'year':year}) or []
                    if len(rows_diario) == 0:
                        sqlDetail = """select ARTICULO, DESCRIPCION_ARTICULO, CANTIDAD_PEDIDA AS UNIDADES_SERVIDAS, PRESENTACION_PEDIDO, UNI_PEDALM AS UNI_SERALM,
                                        EJERCICIO || '-' || NUMERO_SERIE || '-' || NUMERO_PEDIDO AS ID_PEDIDO,
                                        ' ' AS ID_ALBARAN
                                        from PEDIDOS_VENTAS_LIN
                                        where numero_serie = :serie
                                            and NUMERO_PEDIDO = :number_code
                                            and EJERCICIO = :year  
                                    """
                    rows_diario  = oracle.consult(sqlDetail, {'number_code':number_code, 'serie':serie, 'year':year}) or []
                    clientB['detail'] += [rows_diario]

            
    oracle.close()
    conn.close() # sgonzalez  mju76TFC
    return travel_list