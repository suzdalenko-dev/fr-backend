from datetime import date, datetime, timedelta
from dateutil.relativedelta import relativedelta

from produccion.utils.precio_con_gastos import consultar_precio_con_gastos


def give_me_that_are_in_play(oracle):
    # ARTICLES FROM CONTAINERS
    fechaDesde = (date.today() - relativedelta(months=11)).strftime('%Y-%m-%d')
    sql = """SELECT
            ehs.FECHA_PREV_LLEGADA,
            ehs.num_expediente AS NUM_EXPEDIENTE,
            eae.articulo AS ARTICULO,
            (SELECT DESCRIP_COMERCIAL FROM ARTICULOS WHERE CODIGO_ARTICULO = eae.articulo AND ROWNUM = 1) AS DESCRIPTION_ART,
            eae.PRECIO,
            (CASE WHEN ei.divisa = 'USD' THEN eae.precio * ei.valor_cambio ELSE eae.precio END) AS PRECIO_EUR_ORIGINAL,
            eae.cantidad as CANTIDAD,
            ehs.fecha_llegada,
            ehs.codigo_entrada,
            ec.contenedor AS NUMERO,
            ei.divisa,
            ei.valor_cambio,
            'EXP' AS ENTIDAD,
            -2222 as PRECIO_EUR
          FROM expedientes_hojas_seguim ehs
          JOIN expedientes_articulos_embarque eae ON ehs.num_expediente = eae.num_expediente AND ehs.num_hoja = eae.num_hoja AND ehs.empresa = eae.empresa
          JOIN expedientes_imp ei ON ei.codigo = eae.num_expediente AND ei.empresa = eae.empresa
          JOIN expedientes_contenedores ec ON ec.num_expediente = eae.num_expediente AND ec.num_hoja = eae.num_hoja AND ec.empresa = eae.empresa
          WHERE 
              ehs.FECHA_PREV_LLEGADA >= TO_DATE(:fechaDesde, 'YYYY-MM-DD')
              AND ehs.codigo_entrada IS NULL
              AND ehs.empresa = '001'
                                                                                        -- AND ( eae.articulo = '40106')                                  
          ORDER BY ehs.FECHA_PREV_LLEGADA DESC
    """
    
    
    res = oracle.consult(sql, {'fechaDesde':fechaDesde})

    unique_articles = []
    out_articles    = []
    for r in res:
        if not r['ARTICULO'] in unique_articles:
            unique_articles.append(r['ARTICULO'])
            x = {'name': r['DESCRIPTION_ART'], 'code': r['ARTICULO']}
            out_articles.append(x)


    # ARTICLES FROM ORDERS no los usare de momento
    sql_pp = """
            SELECT
              pc.numero_pedido AS NUMERO,
              pc.fecha_pedido AS FECHA_PREV_LLEGADA,
              pc.codigo_proveedor,
              pc.codigo_divisa,
              pcl.codigo_articulo AS ARTICULO,
              (SELECT DESCRIP_COMERCIAL FROM ARTICULOS WHERE CODIGO_ARTICULO = pcl.codigo_articulo AND ROWNUM = 1) AS DESCRIPTION_ART,
              pcl.descripcion AS descripcion_articulo,
              pcl.precio_presentacion AS PRECIO_EUR,
              pcl.unidades_pedidas as CANTIDAD,
              pcl.unidades_entregadas,
              pcl.precio_presentacion,
              pcl.importe_lin_neto,
              pc.status_cierre,
              'PED' AS ENTIDAD
            FROM
              pedidos_compras pc
            JOIN
              pedidos_compras_lin pcl
              ON pc.numero_pedido = pcl.numero_pedido
              AND pc.serie_numeracion = pcl.serie_numeracion
              AND pc.organizacion_compras = pcl.organizacion_compras
              AND pc.codigo_empresa = pcl.codigo_empresa
            WHERE
                pc.fecha_pedido >= TO_DATE(:fechaDesde, 'YYYY-MM-DD')
                AND pc.codigo_empresa = '001'
                AND pc.status_cierre = 'E'
                AND (pcl.unidades_entregadas IS NULL OR pcl.unidades_entregadas = 0)
                                                                                            --    AND ( pcl.codigo_articulo = '40106') 
            ORDER BY pc.fecha_pedido ASC
        """
    res_orderes = oracle.consult(sql_pp, {'fechaDesde':fechaDesde})
    for r in res_orderes:
        if not r['ARTICULO'] in unique_articles:
            unique_articles.append(r['ARTICULO'])
            x = {'name': r['DESCRIPTION_ART'], 'code': r['ARTICULO']}
            out_articles.append(x)

    return out_articles

#####################################
# llegadas pendientes con o sin contenedor filtrando por la ultima hoja de seguimiento
#####################################

def llegadas_pendientes(oracle, arr_codigos_erp, r_fechas, expedientes_sin_precio, iterations, LAST_CHANGE_VAL):
     # desde pedidos
    llegadas_p_data = []


    for codigo_erp in arr_codigos_erp:
        sql_pp = """
            SELECT
              pc.numero_pedido AS NUMERO,
              pc.fecha_pedido AS FECHA_PREV_LLEGADA,
              pc.codigo_proveedor,
              pc.codigo_divisa,
              pcl.codigo_articulo AS ARTICULO,
              pcl.descripcion AS descripcion_articulo,
              pcl.precio_presentacion AS PRECIO_EUR,
              pcl.unidades_pedidas as CANTIDAD,
              pcl.unidades_entregadas,
              pcl.precio_presentacion,
              pcl.importe_lin_neto,
              pc.status_cierre,
              'PED' AS ENTIDAD
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
                AND (pcl.unidades_entregadas IS NULL OR pcl.unidades_entregadas = 0)
            ORDER BY pc.fecha_pedido ASC
        """

        if iterations == 0:                                                        # espero 22 dias al pedido Katerina 
            desde_dt = datetime.strptime(r_fechas['desde'], '%Y-%m-%d')
            fechaDesde = (desde_dt - timedelta(days=22)).strftime('%Y-%m-%d')
        else:
            fechaDesde = r_fechas['desde']
        
        fechaActual = (datetime.today() - timedelta(days=22)).strftime('%Y-%m-%d') # espero 22 dias al pedido Katerina

        res = oracle.consult(sql_pp, { 'fechaDesde': fechaDesde, 'fechaHasta': r_fechas['hasta'], 'codigo_erp': codigo_erp, 'fechaActual': fechaActual })

        if res:
            llegadas_p_data.extend(res)


    # desde expedientes !!! OJO SOLO CON Y SIN CONTENEDOR
    for codigo_erp in arr_codigos_erp:
        sql_ei = """SELECT
                      ehs.FECHA_PREV_LLEGADA,
                      ehs.num_expediente AS NUM_EXPEDIENTE,
                      eae.articulo AS ARTICULO,
                      eae.PRECIO,
                      :LAST_CHANGE_VAL AS CAMBIO_MES,
                      (CASE WHEN ei.divisa = 'USD' THEN eae.precio * :LAST_CHANGE_VAL ELSE eae.precio END) AS PRECIO_EUR_ORIGINAL_CAM_MES,
                      eae.cantidad as CANTIDAD,
                      ec.contenedor AS NUMERO,
                      ei.divisa,
                      'EXP' AS ENTIDAD,
                      -2223 as PRECIO_EUR,
                      ehs.NUM_HOJA
                    FROM expedientes_hojas_seguim ehs
                    JOIN expedientes_articulos_embarque eae ON ehs.num_expediente = eae.num_expediente AND ehs.num_hoja = eae.num_hoja AND ehs.empresa = eae.empresa
                    JOIN expedientes_imp ei ON ei.codigo = eae.num_expediente AND ei.empresa = eae.empresa
                    JOIN expedientes_contenedores ec ON ec.num_expediente = eae.num_expediente AND ec.num_hoja = eae.num_hoja AND ec.empresa = eae.empresa
                    WHERE 
                        ehs.FECHA_PREV_LLEGADA >= TO_DATE(:fechaDesde, 'YYYY-MM-DD') AND ehs.FECHA_PREV_LLEGADA <= TO_DATE(:fechaHasta, 'YYYY-MM-DD') 
                        AND ehs.FECHA_PREV_LLEGADA >= TO_DATE(:fechaActual, 'YYYY-MM-DD')
                        AND eae.articulo = :codigo_erp
                        AND ehs.codigo_entrada IS NULL
                        AND ehs.empresa = '001'
                    ORDER BY ehs.FECHA_PREV_LLEGADA ASC
        """

        if iterations == 0:                                                       # espero 66 dias al pedido Katerina
            desde_dt = datetime.strptime(r_fechas['desde'], '%Y-%m-%d')
            fechaDesde = (desde_dt - timedelta(days=66)).strftime('%Y-%m-%d')
        else:
            fechaDesde = r_fechas['desde']
        
        fechaActual = (datetime.today() - timedelta(days=66)).strftime('%Y-%m-%d') # espero 66 dias al pedido Katerina

        res = oracle.consult(sql_ei, { 'fechaDesde': fechaDesde, 'fechaHasta': r_fechas['hasta'], 'codigo_erp': codigo_erp, 'fechaActual': fechaActual, 'LAST_CHANGE_VAL':LAST_CHANGE_VAL})

        if res:
            for r in res:
                precio_llegada_sql_sin_gastos = precio_con_sin_contenedor_sin_gastos(oracle, r['NUM_EXPEDIENTE'], r['ARTICULO'])
                precio_llegada_sql_con_gastos = precio_con_sin_contenedor(oracle, r['NUM_EXPEDIENTE'], r['ARTICULO'])

                if precio_llegada_sql_sin_gastos and precio_llegada_sql_con_gastos:
                    PRECIO_SIN_GASTOS_EXCEL = precio_llegada_sql_sin_gastos[0].get('N9')
                    PRECIO_SIN_GASTOS_EXCEL = float(PRECIO_SIN_GASTOS_EXCEL) if PRECIO_SIN_GASTOS_EXCEL not in [None, 'None', ''] else 0

                    PRECIO_CON_GASTOS_EXCEL = precio_llegada_sql_con_gastos[0].get('N10')
                    PRECIO_CON_GASTOS_EXCEL = float(PRECIO_CON_GASTOS_EXCEL) if PRECIO_CON_GASTOS_EXCEL not in [None, 'None', ''] else 0
                    if PRECIO_SIN_GASTOS_EXCEL == 0 or PRECIO_CON_GASTOS_EXCEL == 0:
                        r['PRECIO_EUR'] = -1122
                        if r['NUM_EXPEDIENTE'] not in expedientes_sin_precio:
                            expedientes_sin_precio.append(r['NUM_EXPEDIENTE'])
                    else:
                        r['PRECIO_SIN_GASTOS_EXCEL'] = PRECIO_SIN_GASTOS_EXCEL
                        r['PRECIO_CON_GASTOS_EXCEL'] = PRECIO_CON_GASTOS_EXCEL
                        r['GASTOS']                  = r['PRECIO_CON_GASTOS_EXCEL'] - r['PRECIO_SIN_GASTOS_EXCEL']
                        r['PRECIO_EUR'] = float(r['PRECIO_EUR_ORIGINAL_CAM_MES'] or - 4444) + r['GASTOS']
                else:
                    r['PRECIO_EUR'] = -3333




        # iterare hojas de seguimiento y si existe una con el numero posterior pasare a esta
        exped_filtrados = []
        for expediente in res:
            sql_hoja_mayor = """SELECT ehs.NUM_HOJA 
                                FROM expedientes_hojas_seguim ehs
                                JOIN expedientes_imp ei ON ei.codigo = ehs.num_expediente AND ei.empresa = ehs.empresa
                                WHERE ehs.num_hoja > :numHoja AND ei.codigo = :numExpediente"""
                
            res_sql_mayor = oracle.consult(sql_hoja_mayor, { 'numHoja': expediente['NUM_HOJA'], 'numExpediente': expediente['NUM_EXPEDIENTE']})
            if(res_sql_mayor):
                pass
            else:
                exped_filtrados.append(expediente)
                

        
        if exped_filtrados:        
            llegadas_p_data.extend(exped_filtrados) 
           


    ids_in_use = []
    suzdalIcon = "*"
    for i in llegadas_p_data:
        currentId = str(i['NUMERO'])+str(i['ARTICULO'])
        if currentId in ids_in_use:
            i['NUMERO'] = str(i['NUMERO'])+" "+str(suzdalIcon)
            suzdalIcon += str("*")
        ids_in_use += [currentId]


    return llegadas_p_data





###################################################
# precio con y sin contenedor haber si se puede
##################################################

def precio_con_sin_contenedor(oracle, exp_id, art_code):
    sql = """SELECT * FROM (
        SELECT ( ( (
                   SELECT SUM(hs.importe_portes)
                     FROM reparto_portes_hs hs
                    WHERE hs.codigo_empresa = ehs.empresa
                      AND hs.numero_expediente = ehs.num_expediente
                      AND hs.hoja_seguimiento = ehs.num_hoja
                      AND hs.codigo_articulo = eae.articulo
                ) / DECODE(
                   art.unidad_valoracion,
                   1, eae.cantidad_unidad1,
                   2, eae.cantidad_unidad2
                ) ) + ( eae.precio * DECODE(
                   ehs.tipo_cambio,
                   'E', DECODE(ei.cambio_asegurado, 'S', ei.valor_cambio, 'N', 1),
                   'S', ehs.valor_cambio,
                   'N', COALESCE(ehs.valor_cambio, ei.valor_cambio, 1)
                ) ) ) AS N10
          FROM articulos art
          JOIN expedientes_articulos_embarque eae ON art.codigo_articulo = eae.articulo AND art.codigo_empresa = eae.empresa
          JOIN expedientes_hojas_seguim ehs ON ehs.num_expediente = eae.num_expediente AND ehs.num_hoja = eae.num_hoja AND ehs.empresa = eae.empresa
          JOIN expedientes_imp ei ON ei.codigo = ehs.num_expediente AND ei.empresa = ehs.empresa
          JOIN expedientes_contenedores ec ON ec.num_expediente = eae.num_expediente AND ec.num_hoja = eae.num_hoja AND ec.empresa = eae.empresa AND ec.linea = eae.linea_contenedor
         WHERE eae.empresa = '001'
           AND eae.articulo = :art_code
           AND ehs.num_expediente = :exp_id
           AND (ehs.status NOT IN ('C'))
         ORDER BY ehs.NUM_HOJA DESC
    )
    WHERE ROWNUM = 1
    """

    res = oracle.consult(sql, {'exp_id':exp_id, 'art_code': art_code})
    return res




####################################################
# PRECIO SIN GASTON LINEA EXPEDIENDTE
###################################################

def precio_con_sin_contenedor_sin_gastos(oracle, exp_id, art_code):
    sql_sin_gastos = """SELECT *
                            FROM (
                                SELECT
                                    eae.articulo AS c3,
                                    DECODE(
                                        COALESCE(ehs.valor_cambio, ei.valor_cambio, 1),
                                        0,
                                        eae.precio,
                                        eae.precio * COALESCE(ehs.valor_cambio, ei.valor_cambio, 1)
                                    ) AS n9,
                                    (
                                        (
                                            SELECT SUM(hs.importe_portes)
                                            FROM reparto_portes_hs hs
                                            WHERE hs.codigo_empresa = ehs.empresa
                                              AND hs.numero_expediente = ehs.num_expediente
                                              AND hs.hoja_seguimiento = ehs.num_hoja
                                              AND hs.codigo_articulo = eae.articulo
                                        ) / DECODE(
                                            art.unidad_valoracion,
                                            1, eae.cantidad_unidad1,
                                            2, eae.cantidad_unidad2
                                        )
                                    ) + (
                                        eae.precio * DECODE(
                                            ehs.tipo_cambio,
                                            'E', DECODE(ei.cambio_asegurado, 'S', ei.valor_cambio, 'N', 1),
                                            'S', ehs.valor_cambio,
                                            'N', COALESCE(ehs.valor_cambio, ei.valor_cambio, 1)
                                        )
                                    ) AS n10,
                                    ehs.num_hoja
                                FROM articulos art
                                JOIN expedientes_articulos_embarque eae ON art.codigo_articulo = eae.articulo AND art.codigo_empresa = eae.empresa
                                JOIN expedientes_hojas_seguim ehs ON ehs.num_expediente = eae.num_expediente AND ehs.num_hoja = eae.num_hoja AND ehs.empresa = eae.empresa
                                JOIN expedientes_imp ei ON ei.codigo = ehs.num_expediente AND ei.empresa = ehs.empresa
                                JOIN expedientes_contenedores ec ON ec.num_expediente = eae.num_expediente AND ec.num_hoja = eae.num_hoja AND ec.empresa = eae.empresa AND ec.linea = eae.linea_contenedor
                                WHERE eae.empresa = '001'
                                  AND eae.articulo = :art_code
                                  AND ehs.num_expediente = :exp_id
                                  AND ehs.status NOT IN ('C')
                                ORDER BY ehs.num_hoja DESC
                            )
                            WHERE ROWNUM = 1"""
    
    res = oracle.consult(sql_sin_gastos, {'exp_id':exp_id, 'art_code': art_code})
    return res