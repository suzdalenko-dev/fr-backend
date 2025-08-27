from froxa.utils.connectors.libra_connector import OracleConnector
from froxa.utils.utilities.funcions_file import crear_excel_sin_pandas, get_short_date
import os
from openpyxl import Workbook
from django.conf import settings

from froxa.utils.utilities.smailer_file import SMailer


def comparacion_almacen_98(request):
    oracle = OracleConnector()
    oracle.connect()
    out = []

    current_year = request.GET.get('year')

    sql = """SELECT NUMERO_DOC_EXT,
                    NUMERO_DOC_INTERNO,
                    TO_CHAR(FECHA, 'YYYY-MM-DD') AS FECHA_SUPERVISION,
                    CODIGO_ALMACEN,
                    (select a.NOMBRE from ALMACENES a WHERE a.ALMACEN = CODIGO_ALMACEN) AS D_ALMACEN,
                    TIPO_PEDIDO_COM,
                    (SELECT t.DESCRIPCION
                       FROM TIPOS_PEDIDO_COM t
                      WHERE t.TIPO_PEDIDO = c.TIPO_PEDIDO_COM AND t.ORGANIZACION_COMPRAS = c.ORGANIZACION_COMPRAS) AS D_TIPO_PEDIDO_COM,
                    CODIGO_PROVEEDOR,
                    (SELECT prlv.nombre
                        FROM proveedores prlv
                        WHERE prlv.codigo_rapido = c.codigo_proveedor AND prlv.codigo_empresa = c.codigo_empresa) AS D_CODIGO_PROVEEDOR
    
            FROM ALBARAN_COMPRAS_C c
            WHERE 
                c.CODIGO_EMPRESA = '001'
                AND c.ORGANIZACION_COMPRAS = '01'
                AND c.CENTRO_CONTABLE IN (
                    SELECT DISTINCT gru.CODIGO_CENTRO
                    FROM CENTROS_GRUPO_CCONT gru
                    WHERE gru.EMPRESA = c.CODIGO_EMPRESA AND gru.CODIGO_GRUPO = '01')
                AND EXISTS (
                    SELECT 1
                    FROM ALBARAN_COMPRAS_L li
                    WHERE li.NUMERO_DOC_INTERNO = c.NUMERO_DOC_INTERNO AND li.CODIGO_EMPRESA = c.CODIGO_EMPRESA)
                AND c.STATUS_ANULADO = 'N'
                AND CODIGO_ALMACEN = '98'
                AND TO_CHAR(FECHA, 'YYYY') = :current_year

                -- AND NUMERO_DOC_EXT = '219/2'
          
            ORDER BY FECHA DESC

            """

    res = oracle.consult(sql, {'current_year':current_year}) or []

    for r in res:
        sql = """SELECT 
                    NUMERO_DOC_EXT,
                    NUMERO_DOC_INTERNO,
                    TO_CHAR(FECHA, 'YYYY-MM-DD') AS FECHA_SUPERVISION,
                    CODIGO_ALMACEN,
                    (select a.NOMBRE from ALMACENES a WHERE a.ALMACEN = CODIGO_ALMACEN) AS D_ALMACEN,
                    TIPO_PEDIDO_COM,
                    (SELECT t.DESCRIPCION
                       FROM TIPOS_PEDIDO_COM t
                      WHERE t.TIPO_PEDIDO = ALBARAN_COMPRAS_C.TIPO_PEDIDO_COM AND t.ORGANIZACION_COMPRAS = ALBARAN_COMPRAS_C.ORGANIZACION_COMPRAS) AS D_TIPO_PEDIDO_COM,
                    CODIGO_PROVEEDOR,
                    (SELECT prlv.nombre
                        FROM proveedores prlv
                        WHERE prlv.codigo_rapido = albaran_compras_c.codigo_proveedor AND prlv.codigo_empresa = albaran_compras_c.codigo_empresa) AS D_CODIGO_PROVEEDOR
                FROM ALBARAN_COMPRAS_C
                WHERE CODIGO_EMPRESA = '001'
                    AND ORGANIZACION_COMPRAS = '01'
                    AND CENTRO_CONTABLE IN (
                            SELECT DISTINCT gru.CODIGO_CENTRO
                            FROM CENTROS_GRUPO_CCONT gru
                            WHERE gru.EMPRESA = ALBARAN_COMPRAS_C.CODIGO_EMPRESA AND gru.CODIGO_GRUPO = '01')
                    AND EXISTS (
                            SELECT 1
                            FROM ALBARAN_COMPRAS_L li, ARTICULOS lia
                            WHERE li.NUMERO_DOC_INTERNO = ALBARAN_COMPRAS_C.NUMERO_DOC_INTERNO AND li.CODIGO_EMPRESA = ALBARAN_COMPRAS_C.CODIGO_EMPRESA AND lia.CODIGO_EMPRESA = li.CODIGO_EMPRESA AND lia.CODIGO_ARTICULO = li.CODIGO_ARTICULO)
                    AND STATUS_ANULADO = 'N'
                    AND NUMERO_DOC_EXT = :num_doc_ext
                    AND CODIGO_ALMACEN = '25'
                ORDER BY FECHA DESC
            """
        textos = oracle.consult(sql, {'num_doc_ext': r['NUMERO_DOC_EXT']}) or []


        sql = """SELECT 
                    NUMERO_DOC_EXT,
                    NUMERO_DOC_INTERNO,
                    TO_CHAR(FECHA, 'YYYY-MM-DD') AS FECHA_SUPERVISION,
                    CODIGO_ALMACEN,
                    (select a.NOMBRE from ALMACENES a WHERE a.ALMACEN = CODIGO_ALMACEN) AS D_ALMACEN,
                    TIPO_PEDIDO_COM,
                    (SELECT t.DESCRIPCION
                       FROM TIPOS_PEDIDO_COM t
                      WHERE t.TIPO_PEDIDO = ALBARAN_COMPRAS_C.TIPO_PEDIDO_COM AND t.ORGANIZACION_COMPRAS = ALBARAN_COMPRAS_C.ORGANIZACION_COMPRAS) AS D_TIPO_PEDIDO_COM,
                    CODIGO_PROVEEDOR,
                    (SELECT prlv.nombre
                        FROM proveedores prlv
                        WHERE prlv.codigo_rapido = albaran_compras_c.codigo_proveedor AND prlv.codigo_empresa = albaran_compras_c.codigo_empresa) AS D_CODIGO_PROVEEDOR
                FROM ALBARAN_COMPRAS_C
                WHERE CODIGO_EMPRESA = '001'
                    AND ORGANIZACION_COMPRAS = '01'
                    AND CENTRO_CONTABLE IN (
                            SELECT DISTINCT gru.CODIGO_CENTRO
                            FROM CENTROS_GRUPO_CCONT gru
                            WHERE gru.EMPRESA = ALBARAN_COMPRAS_C.CODIGO_EMPRESA AND gru.CODIGO_GRUPO = '01')
                    AND EXISTS (
                            SELECT 1
                            FROM ALBARAN_COMPRAS_L li, ARTICULOS lia
                            WHERE li.NUMERO_DOC_INTERNO = ALBARAN_COMPRAS_C.NUMERO_DOC_INTERNO AND li.CODIGO_EMPRESA = ALBARAN_COMPRAS_C.CODIGO_EMPRESA AND lia.CODIGO_EMPRESA = li.CODIGO_EMPRESA AND lia.CODIGO_ARTICULO = li.CODIGO_ARTICULO)
                    AND STATUS_ANULADO = 'N'
                    AND NUMERO_DOC_EXT = :num_doc_ext
                    AND CODIGO_ALMACEN IN ('00', '01', '02', 'E01', 'E02', 'E03', 'E04', 'E05')
                ORDER BY FECHA DESC
            """
        stock = oracle.consult(sql, {'num_doc_ext': r['NUMERO_DOC_EXT']}) or []
        out += [{'exped': r, 'textos': textos, 'stock': stock}] 
    oracle.close()
    return out







def aviso_diario_comp_98(request):
    oracle = OracleConnector()
    oracle.connect()
    avisos = []
    out    = []
    current_day = get_short_date()

    sql = """SELECT NUMERO_DOC_EXT,
                    NUMERO_DOC_INTERNO,
                    TO_CHAR(FECHA, 'YYYY-MM-DD') AS FECHA_SUPERVISION,
                    CODIGO_ALMACEN,
                    (select a.NOMBRE from ALMACENES a WHERE a.ALMACEN = CODIGO_ALMACEN) AS D_ALMACEN,
                    TIPO_PEDIDO_COM,
                    (SELECT t.DESCRIPCION
                       FROM TIPOS_PEDIDO_COM t
                      WHERE t.TIPO_PEDIDO = c.TIPO_PEDIDO_COM AND t.ORGANIZACION_COMPRAS = c.ORGANIZACION_COMPRAS) AS D_TIPO_PEDIDO_COM,
                    CODIGO_PROVEEDOR,
                    (SELECT prlv.nombre
                        FROM proveedores prlv
                        WHERE prlv.codigo_rapido = c.codigo_proveedor AND prlv.codigo_empresa = c.codigo_empresa) AS D_CODIGO_PROVEEDOR
    
            FROM ALBARAN_COMPRAS_C c
            WHERE TRUNC(c.FECHA) >= DATE '2025-08-01'
                AND c.CODIGO_EMPRESA = '001'
                AND c.ORGANIZACION_COMPRAS = '01'
                AND c.CENTRO_CONTABLE IN (
                    SELECT DISTINCT gru.CODIGO_CENTRO
                    FROM CENTROS_GRUPO_CCONT gru
                    WHERE gru.EMPRESA = c.CODIGO_EMPRESA AND gru.CODIGO_GRUPO = '01')
                AND EXISTS (
                    SELECT 1
                    FROM ALBARAN_COMPRAS_L li
                    WHERE li.NUMERO_DOC_INTERNO = c.NUMERO_DOC_INTERNO AND li.CODIGO_EMPRESA = c.CODIGO_EMPRESA)
                AND c.STATUS_ANULADO = 'N'
                AND CODIGO_ALMACEN = '98'
                AND TO_CHAR(FECHA, 'YYYY-MM-DD') = :current_day          
            ORDER BY FECHA DESC
            """

    containers = oracle.consult(sql, {'current_day':current_day}) or []
    
    for r in containers:
        sql = """SELECT 
                    NUMERO_DOC_EXT,
                    NUMERO_DOC_INTERNO,
                    TO_CHAR(FECHA, 'YYYY-MM-DD') AS FECHA_SUPERVISION,
                    CODIGO_ALMACEN,
                    (select a.NOMBRE from ALMACENES a WHERE a.ALMACEN = CODIGO_ALMACEN) AS D_ALMACEN,
                    TIPO_PEDIDO_COM,
                    (SELECT t.DESCRIPCION
                       FROM TIPOS_PEDIDO_COM t
                      WHERE t.TIPO_PEDIDO = ALBARAN_COMPRAS_C.TIPO_PEDIDO_COM AND t.ORGANIZACION_COMPRAS = ALBARAN_COMPRAS_C.ORGANIZACION_COMPRAS) AS D_TIPO_PEDIDO_COM,
                    CODIGO_PROVEEDOR,
                    (SELECT prlv.nombre
                        FROM proveedores prlv
                        WHERE prlv.codigo_rapido = albaran_compras_c.codigo_proveedor AND prlv.codigo_empresa = albaran_compras_c.codigo_empresa) AS D_CODIGO_PROVEEDOR
                FROM ALBARAN_COMPRAS_C
                WHERE FECHA >= TO_DATE('2025-08-01', 'YYYY-MM-DD')
                    AND CODIGO_EMPRESA = '001'
                    AND ORGANIZACION_COMPRAS = '01'
                    AND CENTRO_CONTABLE IN (
                            SELECT DISTINCT gru.CODIGO_CENTRO
                            FROM CENTROS_GRUPO_CCONT gru
                            WHERE gru.EMPRESA = ALBARAN_COMPRAS_C.CODIGO_EMPRESA AND gru.CODIGO_GRUPO = '01')
                    AND EXISTS (
                            SELECT 1
                            FROM ALBARAN_COMPRAS_L li, ARTICULOS lia
                            WHERE li.NUMERO_DOC_INTERNO = ALBARAN_COMPRAS_C.NUMERO_DOC_INTERNO AND li.CODIGO_EMPRESA = ALBARAN_COMPRAS_C.CODIGO_EMPRESA AND lia.CODIGO_EMPRESA = li.CODIGO_EMPRESA AND lia.CODIGO_ARTICULO = li.CODIGO_ARTICULO)
                    AND STATUS_ANULADO = 'N'
                    AND NUMERO_DOC_EXT = :num_doc_ext
                    AND CODIGO_ALMACEN = '25'
                ORDER BY FECHA DESC
            """
        textos = oracle.consult(sql, {'num_doc_ext': r['NUMERO_DOC_EXT']}) or []


        sql = """SELECT 
                    NUMERO_DOC_EXT,
                    NUMERO_DOC_INTERNO,
                    TO_CHAR(FECHA, 'YYYY-MM-DD') AS FECHA_SUPERVISION,
                    CODIGO_ALMACEN,
                    (select a.NOMBRE from ALMACENES a WHERE a.ALMACEN = CODIGO_ALMACEN) AS D_ALMACEN,
                    TIPO_PEDIDO_COM,
                    (SELECT t.DESCRIPCION
                       FROM TIPOS_PEDIDO_COM t
                      WHERE t.TIPO_PEDIDO = ALBARAN_COMPRAS_C.TIPO_PEDIDO_COM AND t.ORGANIZACION_COMPRAS = ALBARAN_COMPRAS_C.ORGANIZACION_COMPRAS) AS D_TIPO_PEDIDO_COM,
                    CODIGO_PROVEEDOR,
                    (SELECT prlv.nombre
                        FROM proveedores prlv
                        WHERE prlv.codigo_rapido = albaran_compras_c.codigo_proveedor AND prlv.codigo_empresa = albaran_compras_c.codigo_empresa) AS D_CODIGO_PROVEEDOR
                FROM ALBARAN_COMPRAS_C
                WHERE FECHA >= TO_DATE('2025-08-01', 'YYYY-MM-DD')
                    AND CODIGO_EMPRESA = '001'
                    AND ORGANIZACION_COMPRAS = '01'
                    AND CENTRO_CONTABLE IN (
                            SELECT DISTINCT gru.CODIGO_CENTRO
                            FROM CENTROS_GRUPO_CCONT gru
                            WHERE gru.EMPRESA = ALBARAN_COMPRAS_C.CODIGO_EMPRESA AND gru.CODIGO_GRUPO = '01')
                    AND EXISTS (
                            SELECT 1
                            FROM ALBARAN_COMPRAS_L li, ARTICULOS lia
                            WHERE li.NUMERO_DOC_INTERNO = ALBARAN_COMPRAS_C.NUMERO_DOC_INTERNO AND li.CODIGO_EMPRESA = ALBARAN_COMPRAS_C.CODIGO_EMPRESA AND lia.CODIGO_EMPRESA = li.CODIGO_EMPRESA AND lia.CODIGO_ARTICULO = li.CODIGO_ARTICULO)
                    AND STATUS_ANULADO = 'N'
                    AND NUMERO_DOC_EXT = :num_doc_ext
                    AND CODIGO_ALMACEN IN ('00', '01', '02', 'E01', 'E02', 'E03', 'E04', 'E05')

                    AND STATUS_ANULADO = 'BORRAR'

                ORDER BY FECHA DESC
            """
        stock = oracle.consult(sql, {'num_doc_ext': r['NUMERO_DOC_EXT']}) or []
        out += [{'exped': r, 'textos': textos, 'stock': stock }] # stock

    oracle.close()
    
    message = ''
    for o in out:
        if len(o['textos']) == 0 or len(o['stock']) == 0:
            if len(o['textos']) == 0:
                message += ' No encontramos albaran de gastos, '
            if len(o['stock']) == 0:
                message += ' No encontramos albaran de entrada almacén, '
            avisos += [{'Fecha': o['exped']['FECHA_SUPERVISION'],  'Doc. Exterior': o['exped']['NUMERO_DOC_EXT'],  'Doc. Interior': o['exped']['NUMERO_DOC_INTERNO'],  'Almacen': o['exped']['CODIGO_ALMACEN']+' '+o['exped']['D_ALMACEN'], 'Proveedor': o['exped']['CODIGO_PROVEEDOR']+' '+o['exped']['D_CODIGO_PROVEEDOR'],  'Aviso': message }]
            message = ''


    if len(avisos)> 0:
        file_url = crear_excel_sin_pandas(avisos, '0', 'alm98')

        SMailer.send_email(
            ['alexey.suzdalenko@froxa.com'],
            'Consulta Albaranes de compra',
            'Las compras del almacén 98 no coinciden con los albaranes de compra de los almacenes 00, 01, 02, E01, E02, E03, E04, E05 y 25',
            file_url[0]
        )

    return {'file_url': file_url}






