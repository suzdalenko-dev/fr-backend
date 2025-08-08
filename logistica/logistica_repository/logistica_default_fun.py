from froxa.utils.connectors.erp_old_connector import MySQLConn
from froxa.utils.connectors.libra_connector import OracleConnector
from logistica.models import ListOrdersInTheLoad, TravelsClicked


def get_belin_routes(request):

    conn = MySQLConn()
    conn.connect()

    sql = """SELECT * 
             FROM recogida 
             ORDER BY id DESC 
             LIMIT 22"""
    belin_routes = conn.consult(sql)

    for routeA in belin_routes:
        sql = """SELECT DISTINCT __camion, __nombre__camion FROM lineaentrega WHERE __recogida__id = %s AND __camion > 0 ORDER BY __camion ASC"""
        travel_list = conn.consult(sql, (routeA['id'],)) or []
        routeA['travel_names'] = travel_list
        travelClickeds = TravelsClicked.objects.filter(load_id=routeA['id']).values('load_id', 'track_id', 'number_all_order', 'number_clicked_order')
        travelClickeds = list(travelClickeds)
        routeA['travel_situation'] = travelClickeds

    conn.close()
    return belin_routes



def get_all_of_route(request, code, truck):
    list_orders = ListOrdersInTheLoad.objects.filter(load_id=code).values('id', 'track_id', 'order_id', 'article_id', 'state').order_by('id')
    list_orders = list(list_orders)

    truck = int(truck)

    oracle = OracleConnector()
    oracle.connect()

    conn = MySQLConn()
    conn.connect()

    if truck > 0:
        sql = """SELECT DISTINCT __camion, __nombre__camion FROM lineaentrega WHERE __recogida__id = %s AND __camion = %s"""
        travel_list = conn.consult(sql, (code, truck, ))
    else:
        # travel list
        sql = """SELECT DISTINCT __camion, __nombre__camion FROM lineaentrega WHERE __recogida__id = %s AND __camion > 0"""
        travel_list = conn.consult(sql, (code,))  
    
    # list of travel orders
    for travel in travel_list:
        sql         = """SELECT id, __recogida__id, __pedido__id, __cliente__id, __cliente__descripcion, __orden FROM lineaentrega WHERE __recogida__id = %s AND __camion =%s ORDER BY __orden DESC"""
        all_lines   = conn.consult(sql, (code, travel['__camion'],))  
        travel['all_lines']       = all_lines
        travel['click_situation'] = list_orders


        

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
                    clientA['orders'] += [{'__pedido__id':line['__pedido__id'], '__orden':line['__orden']}]
                    

    for travel in travel_list:
        NUMBER_OF_ORDERS = 0

        for clientB in travel['res']:
            for id_order in clientB['orders']:
                pedido_id = str(id_order['__pedido__id']).strip()
                parts = pedido_id.split("-")
                if len(parts) == 3:
                    year, serie, number_code = parts
                    sqlDetail = """SELECT 
                                    avl.ARTICULO, 
                                    MAX(avl.DESCRIPCION_ARTICULO) AS DESCRIPCION_ARTICULO, 
                                    SUM(avl.UNIDADES_SERVIDAS) AS UNIDADES_SERVIDAS, 
                                    SUM(avl.UNI_SERALM) AS UNI_SERALM, 
                                    avl.ID_PEDIDO,
                                    MAX(avl.ID_ALBARAN) AS ID_ALBARAN,
                                    MAX(avl.PRESENTACION_PEDIDO) AS PRESENTACION_PEDIDO,
                                    SUM(
                                        CASE  
                                            WHEN avl.PRESENTACION_PEDIDO = 'UND' THEN 
                                                ROUND(
                                                    avl.UNIDADES_SERVIDAS / 
                                                    (SELECT MAX(CONVERS_U_DIS) 
                                                     FROM CADENA_LOGISTICA 
                                                     WHERE CODIGO_ARTICULO = avl.ARTICULO), 2)
                                            ELSE avl.UNIDADES_SERVIDAS
                                        END
                                    ) AS CAJAS_CALCULADAS
                                FROM (
                                    SELECT 
                                        avl.ARTICULO, 
                                        avl.DESCRIPCION_ARTICULO, 
                                        avl.UNIDADES_SERVIDAS, 
                                        avl.UNI_SERALM, 
                                        avl.PRESENTACION_PEDIDO, 
                                        avl.EJERCICIO_PEDIDO || '-' || avl.NUMERO_SERIE_PEDIDO || '-' || avl.NUMERO_PEDIDO AS ID_PEDIDO,
                                        avl.EJERCICIO_PEDIDO || '-' || avl.NUMERO_SERIE || '-' || avl.NUMERO_ALBARAN AS ID_ALBARAN
                                    FROM ALBARAN_VENTAS_LIN avl
                                    WHERE avl.NUMERO_PEDIDO = :number_code
                                      AND avl.NUMERO_SERIE_PEDIDO = :serie
                                      AND avl.EJERCICIO_PEDIDO = :year
                                ) avl
                                GROUP BY avl.ID_PEDIDO, avl.ARTICULO
                                """
                    rows_diario  = oracle.consult(sqlDetail, {'number_code':number_code, 'serie':serie, 'year':year}) or []
                    if len(rows_diario) == 0:
                        sqlDetail = """SELECT 
                                        pvl.ARTICULO, 
                                        MAX(pvl.DESCRIPCION_ARTICULO) AS DESCRIPCION_ARTICULO,
                                        SUM(pvl.UNIDADES_SERVIDAS) AS UNIDADES_SERVIDAS, 
                                        SUM(pvl.UNI_SERALM) AS UNI_SERALM, 
                                        pvl.ID_PEDIDO,
                                        MAX(pvl.ID_ALBARAN) AS ID_ALBARAN,
                                        MAX(pvl.PRESENTACION_PEDIDO) AS PRESENTACION_PEDIDO,
                                        SUM(
                                            CASE  
                                                WHEN pvl.PRESENTACION_PEDIDO = 'UND' THEN 
                                                    ROUND(
                                                        pvl.UNIDADES_SERVIDAS / 
                                                        (SELECT MAX(CONVERS_U_DIS) 
                                                         FROM CADENA_LOGISTICA 
                                                         WHERE CODIGO_ARTICULO = pvl.ARTICULO), 2)
                                                ELSE pvl.UNIDADES_SERVIDAS
                                            END
                                        ) AS CAJAS_CALCULADAS
                                    FROM (
                                        SELECT 
                                            ARTICULO, 
                                            DESCRIPCION_ARTICULO, 
                                            CANTIDAD_PEDIDA AS UNIDADES_SERVIDAS, 
                                            UNI_PEDALM AS UNI_SERALM,
                                            PRESENTACION_PEDIDO, 
                                            EJERCICIO || '-' || NUMERO_SERIE || '-' || NUMERO_PEDIDO AS ID_PEDIDO,
                                            ' ' AS ID_ALBARAN
                                        FROM PEDIDOS_VENTAS_LIN
                                        WHERE numero_serie = :serie
                                          AND NUMERO_PEDIDO = :number_code
                                          AND EJERCICIO = :year
                                    ) pvl
                                    GROUP BY pvl.ID_PEDIDO, pvl.ARTICULO
                                    """
                    rows_diario  = oracle.consult(sqlDetail, {'number_code':number_code, 'serie':serie, 'year':year}) or []
                    
                    clientB['detail'] += [rows_diario]
                    NUMBER_OF_ORDERS  += len(rows_diario)

        travelClicked, created             = TravelsClicked.objects.get_or_create(load_id=code, track_id=travel['__camion'])
        travelClicked.number_all_order     = NUMBER_OF_ORDERS
        orders_clicked                     = ListOrdersInTheLoad.objects.filter(load_id=code, track_id=travel['__camion']) or []
        travelClicked.number_clicked_order = len(orders_clicked)
        travelClicked.save()
            
    oracle.close()
    conn.close() # sgonzalez  mju76TFC
    return travel_list



def click_actions(request, action):
    load_id    = request.GET.get('load_id')
    track_id   = request.GET.get('track_id')
    order_id   = request.GET.get('order_id')
    article_id = request.GET.get('article_id')    

    if action == 'put':
        line_order, created = ListOrdersInTheLoad.objects.get_or_create(load_id=load_id, track_id=track_id, order_id=order_id, article_id=article_id)
        if str(line_order.state) == 'clicked':
            line_order.delete()
        elif str(line_order.state) != 'clicked':
            line_order.state = 'clicked'
            line_order.save()
        