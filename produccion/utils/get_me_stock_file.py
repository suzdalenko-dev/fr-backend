from froxa.utils.connectors.libra_connector import OracleConnector


def get_me_stock_now(erp_code):
    """
    {
      "__articulo____descripcion": "MINCED DE GAYI",
      "__erp": "302632401",
      "__pesobruto": "1000.0000",
      "__preciocoste6": "1.847950",
      "_stock_unidades_otros": "72518.5000",
      "precio_kg_usar": "1.8479500000",
      "stock_kg_usar": "72518.500000000000"
    }
    """
    sql = """SELECT V_CODIGO_ALMACEN,
            D_CODIGO_ALMACEN,
            V_TIPO_SITUACION,
            V_CANTIDAD_PRESENTACION,
            V_PRESENTACION,
            CODIGO_ARTICULO,
            (select PRECIO_MEDIO_PONDERADO from ARTICULOS_VALORACION where CODIGO_ARTICULO = :erp_code AND CODIGO_DIVISA = 'EUR' AND CODIGO_ALMACEN = '00') AS PRECIO_MEDIO_PONDERADO
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
        )  s WHERE ( NVL(stock_unidad1, 0) != 0 OR NVL(stock_unidad2, 0) != 0) and CODIGO_ARTICULO=:erp_code order by codigo_almacen"""


    oracle = OracleConnector()
    oracle.connect()
    stockArticle = oracle.consult(sql, {"erp_code": erp_code})
    stock_almcenes =  [{'almacenes': stockArticle, 'precio':0, 'stock':0}]
    precioItem = 0
    stockItem  = 0
    if len(stockArticle) > 0:
        for almacen in stockArticle:
            precioItem = float(almacen['PRECIO_MEDIO_PONDERADO'])
            stockItem += float(almacen['V_CANTIDAD_PRESENTACION'])
    stock_almcenes[0]['precio'] = precioItem
    stock_almcenes[0]['stock']  = stockItem

    oracle.close()

    return stock_almcenes