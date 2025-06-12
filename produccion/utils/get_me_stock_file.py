from datetime import date, datetime, timedelta
from dateutil.relativedelta import relativedelta
import calendar

from produccion.utils.precio_con_gastos import consultar_precio_con_gastos


def get_me_stock_now(erp_code, oracle):
    sql = """SELECT V_CODIGO_ALMACEN,
            D_CODIGO_ALMACEN,
            V_TIPO_SITUACION,
            V_CANTIDAD_PRESENTACION,
            V_PRESENTACION,
            CODIGO_ARTICULO
            FROM 
        (
            SELECT  s.* , 
                CANTIDAD_PRESENTACION V_CANTIDAD_PRESENTACION,
                CODIGO_ALMACEN V_CODIGO_ALMACEN,
                PRESENTACION V_PRESENTACION,
                STOCK_BARRAS V_STOCK_BARRAS,
                STOCK_UNIDAD1 V_STOCK_UNIDAD1,
                STOCK_UNIDAD2 V_STOCK_UNIDAD2,
                TIPO_SITUACION V_TIPO_SITUACION 
            FROM 
                (
                    SELECT codigo_empresa, 
                    codigo_almacen,
                    (SELECT a.nombre FROM almacenes a WHERE a.almacen = s.codigo_almacen AND a.codigo_empresa = s.codigo_empresa) d_codigo_almacen, 
                    codigo_articulo, 
                    tipo_situacion, 
                    presentacion, 
                    SUM(cantidad_unidad1) stock_unidad1, 
                    SUM(NVL(cantidad_unidad2, 0)) stock_unidad2, 
                    SUM(NVL(cantidad_presentacion, 0)) cantidad_presentacion, 
                    SUM(/*AL*/0/*FAL*/) stock_barras 
                    FROM stocks_detallado s  
                    WHERE NOT EXISTS 
                        (SELECT 1
                        FROM almacenes_zonas az
                        WHERE az.codigo_empresa = s.codigo_empresa
                               AND az.codigo_almacen = s.codigo_almacen
                               AND az.codigo_zona = s.codigo_zona
                               AND az.es_zona_reserva_virtual = 'S') 
                        GROUP BY codigo_empresa, codigo_almacen, codigo_articulo, tipo_situacion, presentacion
                ) s 
        )  s WHERE (NVL(stock_unidad1, 0) != 0 OR NVL(stock_unidad2, 0) != 0) and CODIGO_ARTICULO=:erp_code order by codigo_almacen"""

    stockArticle = oracle.consult(sql, {"erp_code": erp_code})
    stock_almcenes =  [{'erp': erp_code, 'almacenes': stockArticle, 'precio':0, 'stock':0}]
    stockItem  = 0
    if len(stockArticle) > 0:
        for almacen in stockArticle:
            cantidad_raw = almacen.get('V_CANTIDAD_PRESENTACION')
            if cantidad_raw not in [None, '', 'None']:
                stockItem += float(cantidad_raw)
    stock_almcenes[0]['stock']  = stockItem


    sql = """select PRECIO_MEDIO_PONDERADO from ARTICULOS_VALORACION where CODIGO_ARTICULO = :erp_code AND CODIGO_DIVISA = 'EUR' AND CODIGO_ALMACEN = '00'"""
    precioArticle = oracle.consult(sql, {"erp_code": erp_code})
    precioItem = 0.0
    if precioArticle and len(precioArticle) > 0:
        precio_raw   = precioArticle[0].get('PRECIO_MEDIO_PONDERADO')
        if precio_raw not in [None, '', 'None']:
            precioItem = float(precio_raw)
        stock_almcenes[0]['precio'] = precioItem

    return stock_almcenes



################################################

def obtener_rangos_meses():
    rangos = []
    meses_en_adelante = 4
    hoy = datetime.today()
    mes_actual = hoy.month
    anio_actual = hoy.year

    for i in range(meses_en_adelante):
        mes = (mes_actual + i) % 12
        mes = 12 if mes == 0 else mes
        anio = anio_actual + ((mes_actual + i - 1) // 12)
        
        primera_fecha = datetime(anio, mes, 1)
        ultima_fecha = primera_fecha + relativedelta(months=1) - timedelta(days=1)
        
        rangos.append([
            primera_fecha.strftime("%Y-%m-%d"),
            ultima_fecha.strftime("%Y-%m-%d")
        ])

    return rangos

################################################

def obtener_rangos_meses7():
    rangos = []
    meses_en_adelante = 7
    hoy = datetime.today()
    mes_actual = hoy.month
    anio_actual = hoy.year

    for i in range(meses_en_adelante):
        mes = (mes_actual + i) % 12
        mes = 12 if mes == 0 else mes
        anio = anio_actual + ((mes_actual + i - 1) // 12)
        
        primera_fecha = datetime(anio, mes, 1)
        ultima_fecha = primera_fecha + relativedelta(months=1) - timedelta(days=1)
        
        rangos.append([
            primera_fecha.strftime("%Y-%m-%d"),
            ultima_fecha.strftime("%Y-%m-%d")
        ])

    return rangos


#######################################################



def consumo_produccion(oracle, arr_codigos_erp, r_fechas):
    pass




#######################################################
### here I first look for the orders and then I look for the containers
#######################################################

def pedidos_pendientes(oracle, arr_codigos_erp, r_fechas, expedientes_sin_precio):
    # desde pedidos
    llegadas_p_data = []

    iterations = 0
    for codigo_erp in arr_codigos_erp:
        sql_pp = """
            SELECT
              pc.numero_pedido,
              pc.fecha_pedido,
              pc.codigo_proveedor,
              pc.codigo_divisa,
              pcl.codigo_articulo,
              pcl.descripcion AS descripcion_articulo,
              pcl.precio_presentacion AS PRECIO_EUR,
              pcl.unidades_pedidas as CANTIDAD,
              pcl.unidades_entregadas,
              pcl.precio_presentacion,
              pcl.importe_lin_neto,
              pc.status_cierre,
              'PEDIDO' AS ENTIDAD
            FROM
              pedidos_compras pc
            JOIN
              pedidos_compras_lin pcl
              ON pc.numero_pedido = pcl.numero_pedido
              AND pc.serie_numeracion = pcl.serie_numeracion
              AND pc.organizacion_compras = pcl.organizacion_compras
              AND pc.codigo_empresa = pcl.codigo_empresa
            WHERE
                pc.fecha_pedido >= TO_DATE(:fechaDesde, 'YYYY-MM-DD') AND pc.fecha_pedido <= TO_DATE(:fechaHasta, 'YYYY-MM-DD') 
                AND pc.fecha_pedido >= TO_DATE(:fechaActual, 'YYYY-MM-DD')
                AND pc.codigo_empresa = '001'
                AND pc.status_cierre = 'E'
                AND pcl.codigo_articulo = :codigo_erp
        """

        if iterations == 0:                                                        # espero 15 dias al pedido Katerina 
            desde_dt = datetime.strptime(r_fechas['desde'], '%Y-%m-%d')
            fechaDesde = (desde_dt - timedelta(days=15)).strftime('%Y-%m-%d')
        else:
            fechaDesde = r_fechas['desde']
        
        fechaActual = (datetime.today() - timedelta(days=15)).strftime('%Y-%m-%d') # espero 15 dias al pedido Katerina

        res = oracle.consult(sql_pp, { 'fechaDesde': fechaDesde, 'fechaHasta': r_fechas['hasta'], 'codigo_erp': codigo_erp, 'fechaActual': fechaActual })

        if res:
            llegadas_p_data.extend(res)

        iterations += 1


    # desde expedientes !!! COMPROBAR ESTE CASO: CODIGO_PROVEEDOR: "001186"
    iterations = 0
    for codigo_erp in arr_codigos_erp:
        sql_ei = """SELECT
                      ehs.FECHA_PREV_LLEGADA,
                      ehs.num_expediente AS NUM_EXPEDIENTE,
                      eae.articulo AS ARTICULO,
                      eae.PRECIO,
                      (CASE WHEN ei.divisa = 'USD' THEN eae.precio * ei.valor_cambio ELSE eae.precio END) AS PRECIO_EUR_ORIGINAL,
                      eae.cantidad as CANTIDAD,
                      ehs.fecha_llegada,
                      ehs.codigo_entrada,
                      ec.contenedor,
                      ei.divisa,
                      ei.valor_cambio,
                      'EXPEDIENTE' AS ENTIDAD,
                      -2222 as PRECIO_EUR
                    FROM expedientes_hojas_seguim ehs
                    JOIN expedientes_articulos_embarque eae ON ehs.num_expediente = eae.num_expediente AND ehs.num_hoja = eae.num_hoja AND ehs.empresa = eae.empresa
                    JOIN expedientes_imp ei ON ei.codigo = eae.num_expediente AND ei.empresa = eae.empresa
                    JOIN expedientes_contenedores ec ON ec.num_expediente = eae.num_expediente AND ec.num_hoja = eae.num_hoja AND ec.empresa = eae.empresa
                    WHERE 
                        ehs.FECHA_PREV_LLEGADA >= TO_DATE(:fechaDesde, 'YYYY-MM-DD') AND ehs.FECHA_PREV_LLEGADA <= TO_DATE(:fechaHasta, 'YYYY-MM-DD') 
                        AND ehs.FECHA_PREV_LLEGADA >= TO_DATE(:fechaActual, 'YYYY-MM-DD')
                        AND eae.articulo = :codigo_erp
                        AND ehs.codigo_entrada IS NULL
                        AND (ec.contenedor IS NULL OR ec.contenedor != 'CNT')
                        AND ehs.empresa = '001'
        """

        if iterations == 0:                                                       # espero 40 dias al pedido Katerina
            desde_dt = datetime.strptime(r_fechas['desde'], '%Y-%m-%d')
            fechaDesde = (desde_dt - timedelta(days=40)).strftime('%Y-%m-%d')
        else:
            fechaDesde = r_fechas['desde']
        
        fechaActual = (datetime.today() - timedelta(days=40)).strftime('%Y-%m-%d') # espero 40 dias al pedido Katerina

        res = oracle.consult(sql_ei, { 'fechaDesde': fechaDesde, 'fechaHasta': r_fechas['hasta'], 'codigo_erp': codigo_erp, 'fechaActual': fechaActual})

        if res:
            for r in res:
                precio_llegada_sql = consultar_precio_con_gastos(oracle, r['NUM_EXPEDIENTE'], r['ARTICULO'], r['CANTIDAD'])
                if precio_llegada_sql:
                    valor_precio_final = precio_llegada_sql[0].get('N10')
                    r['PRECIO_EUR'] = float(valor_precio_final) if valor_precio_final not in [None, 'None', ''] else 0
                    if r['PRECIO_EUR'] == 0 and r['NUM_EXPEDIENTE'] not in expedientes_sin_precio:
                        expedientes_sin_precio.append(r['NUM_EXPEDIENTE'])
                        r['PRECIO_EUR'] = -1122
                   
            llegadas_p_data.extend(res)

        iterations += 1

    return llegadas_p_data


##########################################################
# consume in production and sales
##########################################################

def consumo_pasado(oracle, arr_codigos_erp, r_fechas):
    # Convert strings to datetime objects
    fechaDesde_dt = datetime.strptime(r_fechas['desde'], '%Y-%m-%d')
    fechaHasta_dt = datetime.strptime(r_fechas['hasta'], '%Y-%m-%d')

    # Restar 1 año
    fechaDesde_dt -= relativedelta(years=1)
    fechaHasta_dt -= relativedelta(years=1)

    # Restar 1 mes !!! cambiar aqui por 1 año
    # fechaDesde_dt -= relativedelta(months=1)
    # fechaHasta_dt -= relativedelta(months=1)

    # Formato correcto a STRING para SQL
    fechaDesde = fechaDesde_dt.strftime('%Y-%m-%d')
    fechaHasta = fechaHasta_dt.strftime('%Y-%m-%d')

    consumo_data = []

    for codigo_erp in arr_codigos_erp:
        sql_of = """SELECT 
                        ofc.FECHA_ENTREGA_PREVISTA,
                        cofmc.ORDEN_DE_FABRICACION,
                        cofmc.CODIGO_ARTICULO_CONSUMIDO,
                        a.DESCRIP_COMERCIAL AS DESCRIP_CONSUMIDO,
                        a.unidad_codigo1 AS CODIGO_PRESENTACION,
                        TO_NUMBER(cofmc.CANTIDAD_UNIDAD1) AS CANTIDAD,
                        'OFS_CONSUMO' AS CONSUMO_OFS
                    FROM 
                        COSTES_ORDENES_FAB_MAT_CTD cofmc
                    JOIN 
                        ORDENES_FABRICA_CAB ofc ON ofc.ORDEN_DE_FABRICACION = cofmc.ORDEN_DE_FABRICACION
                    JOIN 
                        articulos a ON a.codigo_articulo = cofmc.CODIGO_ARTICULO_CONSUMIDO
                    WHERE 
                        ofc.FECHA_ENTREGA_PREVISTA >= TO_DATE(:fechaDesde, 'YYYY-MM-DD') 
                        AND ofc.FECHA_ENTREGA_PREVISTA <= TO_DATE(:fechaHasta, 'YYYY-MM-DD')
                        AND codigo_articulo_consumido = :codigo_erp
                        AND TO_NUMBER(cofmc.CANTIDAD_UNIDAD1) != 0
                    ORDER BY ofc.FECHA_ENTREGA_PREVISTA ASC
                        
        """
        res = oracle.consult(sql_of, { 'codigo_erp': codigo_erp, 'fechaDesde': fechaDesde, 'fechaHasta': fechaHasta })
        if res:
            consumo_data.extend(res)


    for codigo_erp in arr_codigos_erp:
        sql_pv = """SELECT
                        c.fecha_pedido AS fecha_venta,
                        l.articulo AS codigo_articulo,
                        TO_NUMBER(l.uni_seralm) AS CANTIDAD,
                        'P_VENTA' AS P_VENTA
                    FROM
                        albaran_ventas_lin l
                    JOIN
                        albaran_ventas c ON l.numero_albaran = c.numero_albaran AND l.numero_serie = c.numero_serie AND l.ejercicio = c.ejercicio AND l.organizacion_comercial = c.organizacion_comercial AND l.empresa = c.empresa
                    JOIN
                        articulos a ON a.codigo_articulo = l.articulo
                    WHERE
                        l.empresa = '001'
                        AND NVL(l.linea_anulada, 'N') = 'N'
                        AND l.articulo = :codigo_erp
                        AND c.fecha_pedido BETWEEN TO_DATE(:fechaDesde, 'YYYY-MM-DD') AND TO_DATE(:fechaHasta, 'YYYY-MM-DD')
                        AND TO_NUMBER(l.uni_seralm) != 0
                    ORDER BY
                        c.fecha_pedido DESC
        """
        res = oracle.consult(sql_pv, { 'codigo_erp': codigo_erp, 'fechaDesde': fechaDesde, 'fechaHasta': fechaHasta })
        if res:
            consumo_data.extend(res)

    return consumo_data


###################################################
# fechas y dias mes restantes
###################################################


def verificar_mes(fecha_str):
    """
    Verifica si la fecha (en string "YYYY-MM-DD") está en el mes y año actual.
    :param fecha_str: str
    :return: "mes actual" o "mes no actual"
    """
    fecha = datetime.strptime(fecha_str, "%Y-%m-%d").date()
    ahora = datetime.now().date()
    return "mes actual" if fecha.month == ahora.month and fecha.year == ahora.year else "mes no actual"

def obtener_dias_restantes_del_mes():
    """
    Retorna el número de días restantes en el mes actual (incluyendo hoy).
    :return: int
    """
    hoy = datetime.now().date()
    ultimo_dia = calendar.monthrange(hoy.year, hoy.month)[1]
    return ultimo_dia - hoy.day + 1

