# http://127.0.0.1:8000/finanzas/get/0/0/payments_and_receipts/

from django.db import connection
from finanzas.fin_utils.inf_expedientes.save_line_invoice_file import save_line_invoice_line
from finanzas.models import InvoicesSales
from froxa.utils.connectors.libra_connector import OracleConnector
from froxa.utils.utilities.funcions_file import get_current_date, invoices_list_of_current_month



def payments_and_receipts(request):
    currentDate = get_current_date()
    InvoicesSales.objects.all().delete()
    with connection.cursor() as cursor:
        cursor.execute("ALTER SEQUENCE finanzas_invoicessales_id_seq RESTART WITH 1;")

    x = []
    oracle = OracleConnector()
    oracle.connect()
    
    fechas_mes_a_mes = invoices_list_of_current_month('2025-01-01')
    for start_month, end_month in fechas_mes_a_mes:
        sql2 = """SELECT 
                        FORMA_COBRO,
                        TO_NUMBER(fv.LIQUIDO_FACTURA) AS LIQUIDO_FACTURA,
                        
                        NVL((SELECT TO_NUMBER(hc.IMPORTE_COBRADO) 
                        FROM HISTORICO_COBROS hc
                        WHERE hc.DOCUMENTO = fv.NUMERO_FRA_CONTA AND hc.CODIGO_CLIENTE = fv.CLIENTE AND hc.FECHA_FACTURA = fv.FECHA_FACTURA), 0) AS IMPORTE_COBRADO,

                        TO_CHAR(fv.FECHA_FACTURA, 'YYYY-MM-DD') AS FECHA_FACTURA,
                        TO_CHAR(fv.FECHA_FACTURA, 'YYYY') AS EJERCICIO,
                        fv.EMPRESA, 
                        fv.CLIENTE, 
                        fv.NUMERO_FRA_CONTA AS DOCUMENTO,

                        (SELECT cli.NOMBRE || ' ' || cli.CODIGO_RAPIDO 
                            FROM VA_CLIENTES cli
                            WHERE cli.CODIGO_RAPIDO = fv.CLIENTE 
                              AND cli.CODIGO_EMPRESA = fv.EMPRESA 
                              AND ROWNUM = 1
                        ) AS NOMBRE_CLIENTE,

                        (SELECT org.NOMBRE
                            FROM VA_CLIENTES cli
                            JOIN ORGANIZACION_COMERCIAL org
                              ON cli.ORG_COMER = org.CODIGO_ORG_COMER
                             AND cli.CODIGO_EMPRESA = org.CODIGO_EMPRESA
                            WHERE cli.CODIGO_RAPIDO = fv.CLIENTE
                              AND cli.CODIGO_EMPRESA = fv.EMPRESA
                              AND org.NOMBRE NOT IN ('VENTA LOGISTICA FROXA', 'VENTA TIENDA CARTES FROXA')
                              AND org.NOMBRE IS NOT NULL
                              AND ROWNUM = 1
                        ) AS DESCRIPCION_ORG_COMER,

                        (SELECT ag.NOMBRE
                        FROM agentes_clientes ac, agentes ag
                        WHERE ac.CODIGO_CLIENTE = fv.CLIENTE
                          AND ac.AGENTE = ag.CODIGO
                          AND ROWNUM = 1
                        ) AS NOMBRE_AGENTE,

                        (SELECT TO_CHAR(hc.FECHA_VENCIMIENTO, 'YYYY-MM-DD')
                        FROM HISTORICO_COBROS hc
                        WHERE hc.DOCUMENTO = fv.NUMERO_FRA_CONTA AND hc.CODIGO_CLIENTE = fv.CLIENTE AND hc.FECHA_FACTURA = fv.FECHA_FACTURA AND ROWNUM = 1
                        ) AS FECHA_VENCIMIENTO,

                        (SELECT hc.DOCUMENTO_VIVO
                        FROM HISTORICO_COBROS hc
                        WHERE hc.DOCUMENTO = fv.NUMERO_FRA_CONTA AND hc.CODIGO_CLIENTE = fv.CLIENTE AND hc.FECHA_FACTURA = fv.FECHA_FACTURA AND ROWNUM = 1
                        ) AS DOCUMENTO_VIVO,

                        NVL(
                            (SELECT TO_CHAR(MAX(ha.FECHA_ASIENTO), 'YYYY-MM-DD')
                             FROM HISTORICO_DETALLADO_APUNTES ha
                             WHERE ha.DOCUMENTO = fv.NUMERO_FRA_CONTA AND ha.EMPRESA = fv.EMPRESA AND ha.CODIGO_ENTIDAD = fv.CLIENTE AND ha.CODIGO_CONCEPTO = 'COB' AND ha.ENTIDAD = 'CL'
                            ), 'dont_charged'
                        ) AS FECHA_ASIENTO_COBRO

                    FROM 
                        facturas_ventas fv
                    WHERE 
                        'suzdalenko'='suzdalenko'
                        AND fv.FECHA_FACTURA >= TO_DATE('2025-02-01', 'YYYY-MM-DD')
                        AND fv.FECHA_FACTURA >= TO_DATE(:start_month, 'YYYY-MM-DD') AND fv.FECHA_FACTURA <= TO_DATE(:end_month, 'YYYY-MM-DD')
                        -- AND fv.CLIENTE = '003341'                                     -- 001918 004242 003341
                        -- AND fv.NUMERO_FRA_CONTA = 'FN1/003191'       -- 'FR1/003211' FR1/005277
                        AND fv.LIQUIDO_FACTURA > 0
                    ORDER BY 
                        fv.FECHA_FACTURA, 
                        fv.NUMERO_FRA_CONTA
                """

        invoices = oracle.consult(sql2, {'start_month':start_month, 'end_month':end_month}) or []

        # listado facturas
        for invoice in invoices:
            documentoString   = str(invoice['DOCUMENTO']).strip()
            yearString        = str(invoice['EJERCICIO']).strip()
        
            # FACTURA CON TIPO COBRO "CREDITO 60 DIAS"
            if invoice['FORMA_COBRO'] in ['C6', 'T99']:
                if invoice['FECHA_ASIENTO_COBRO'] == 'dont_charged':
                    # DAG para una factura
                    agrupacionesSql = """select * from AGRUPACIONES_DESGLOSES WHERE DOCUMENTO = :documentoString"""
                    existeNumeroAgrupacion = oracle.consult(agrupacionesSql, {'documentoString':documentoString})
                    if existeNumeroAgrupacion  is not None and len(existeNumeroAgrupacion) > 0:
                        numeros_dags       = []
                        numeros_agrupacion = []
                        for dagLine in existeNumeroAgrupacion:
                            num_agrupacion = str(dagLine['NUMERO_AGRUPACION']).strip()
                            if num_agrupacion not in numeros_agrupacion:
                                numeros_agrupacion += [num_agrupacion]
                                dagsSql = """select * from AGRUPACIONES_DESGLOSES WHERE NUMERO_AGRUPACION = :num_agrupacion"""
                                getDagsLine = oracle.consult(dagsSql, {'num_agrupacion':num_agrupacion})
                                if getDagsLine  is not None and len(getDagsLine) > 0:
                                    for dLine in getDagsLine:
                                        documentoDag = str(dLine['DOCUMENTO']).strip()
                                        if documentoDag != documentoString:
                                            if documentoDag not in numeros_dags:
                                                numeros_dags += [documentoDag]
                                                sqlEsFactura = """SELECT 1 FROM facturas_ventas fv WHERE fv.numero_fra_conta = :documentoDag"""
                                                esFactura    = oracle.consult(sqlEsFactura, {'documentoDag': documentoDag})
                                                # quito las facturas rectificativas que se mezclan con los dags
                                                if esFactura is not None and len(esFactura) > 0:
                                                    continue
                                                yaUsoDag = InvoicesSales.objects.filter(dag=documentoDag, ejercicio=yearString).exists()
                                                if yaUsoDag:
                                                    continue
                                                # print(documentoDag)
                                                saleLine, created = InvoicesSales.objects.get_or_create(documento=documentoString, ejercicio=yearString, dag=documentoDag)
                                                # print(documentoString)
                                                chargeSql  = """select TO_NUMBER(hc.IMPORTE) AS IMPORTE, TO_NUMBER(hc.IMPORTE_COBRADO) AS IMPORTE_COBRADO, TO_CHAR(hda.FECHA_ASIENTO, 'YYYY-MM-DD') AS FECHA_COBRO
                                                                from historico_detallado_apuntes hda, HISTORICO_COBROS hc
                                                                where hda.DOCUMENTO = hc.DOCUMENTO 
                                                                    AND hda.DOCUMENTO = :documentoDag 
                                                                    AND hda.CODIGO_CONCEPTO = 'COB' 
                                                                    AND hda.ENTIDAD = 'CL'
                                                                    AND hda.CODIGO_ENTIDAD = hc.CODIGO_CLIENTE
                                                                    AND NOT EXISTS ( SELECT 1 FROM facturas_ventas fv WHERE fv.numero_fra_conta = :documentoDag)
                                                                ORDER BY hda.FECHA_ASIENTO DESC
                                                            """
                                                chargeInfo = oracle.consult(chargeSql, {'documentoDag':documentoDag})
                                                # print(chargeInfo)
                                                if chargeInfo is not None and len(chargeInfo) > 0:
                                                    invoice['fecha_cobro_dag_TOP'] = f"COBRADO {documentoDag} {chargeInfo[0]['FECHA_COBRO']}"
                                                    save_line_invoice_line(saleLine, chargeInfo[0]['FECHA_COBRO'], currentDate, invoice, chargeInfo[0]['IMPORTE'], chargeInfo[0]['IMPORTE_COBRADO'])
                                                else:
                                                    # aqui estan las facturas con el DAG no cobrado aun
                                                    invoice['fecha_cobro_dag_BOTTOM'] = f"NO COBRADO DAG BOTTOM {documentoDag}"
                                                    save_line_invoice_line(saleLine, "", currentDate, invoice, invoice['LIQUIDO_FACTURA'], invoice['IMPORTE_COBRADO'])
                                else:
                                    # aun no existe en numero del DAG
                                    saleLine, created = InvoicesSales.objects.get_or_create(documento=documentoString, ejercicio=yearString)
                                    invoice['fecha_cobro_dag'] = 'FACTURA SIN DAGS 2'
                                    save_line_invoice_line(saleLine, "", currentDate, invoice, invoice['LIQUIDO_FACTURA'], invoice['IMPORTE_COBRADO'])
                    else:
                        saleLine, created = InvoicesSales.objects.get_or_create(documento=documentoString, ejercicio=yearString)
                        invoice['fecha_cobro_dag'] = 'FACTURA SIN DAGS 3'
                        save_line_invoice_line(saleLine, "", currentDate, invoice, invoice['LIQUIDO_FACTURA'], invoice['IMPORTE_COBRADO'])
                else:
                    saleLine, created = InvoicesSales.objects.get_or_create(documento=documentoString, ejercicio=yearString)
                    invoice['fecha_cobro_dag'] = 'FACTURA CON FECHA'
                    save_line_invoice_line(saleLine, invoice['FECHA_ASIENTO_COBRO'], currentDate, invoice, invoice['LIQUIDO_FACTURA'], invoice['IMPORTE_COBRADO'])
            


         
            # 003341 FN1/000582 => 05/03/2025 DAR26
            if invoice['FORMA_COBRO'] in ['G10']:
                if invoice['FECHA_ASIENTO_COBRO'] == 'dont_charged':
                    # FACTURA CON TIPO COBRO GIRO
                    saleLine, created = InvoicesSales.objects.get_or_create(documento=documentoString, ejercicio=yearString)                                    
                    save_line_invoice_line(saleLine, "", currentDate, invoice, invoice['LIQUIDO_FACTURA'], invoice['IMPORTE_COBRADO'])
                    # print(documentoString)
                    buscar_fecha_pago_sql = """select FECHA_ASIENTO, IMPORTE from HISTORICO_DETALLADO_APUNTES where documento = :documentoString AND DIARIO='BANC' AND ROWNUM=1 ORDER BY FECHA_ASIENTO DESC"""
                    buscar_fecha_pago_sql = oracle.consult(buscar_fecha_pago_sql, {'documentoString':documentoString})
                    # print(buscar_fecha_pago_sql)
                    if buscar_fecha_pago_sql is not None and len(buscar_fecha_pago_sql) > 0:
                        save_line_invoice_line(saleLine, buscar_fecha_pago_sql[0]['FECHA_ASIENTO'], currentDate, invoice, invoice['LIQUIDO_FACTURA'], buscar_fecha_pago_sql[0]['IMPORTE'])
                    else:
                        # en la factura existen los DAR ?¿
                        agrupacionesSql = """select * from AGRUPACIONES_DESGLOSES WHERE DOCUMENTO = :documentoString"""
                        existeNumeroAgrupacion = oracle.consult(agrupacionesSql, {'documentoString':documentoString})
                        if existeNumeroAgrupacion  is not None and len(existeNumeroAgrupacion) > 0:
                            numeros_dags       = []
                            numeros_agrupacion = []
                            for dagLine in existeNumeroAgrupacion:
                                num_agrupacion = str(dagLine['NUMERO_AGRUPACION']).strip()
                                if num_agrupacion not in numeros_agrupacion:
                                    numeros_agrupacion += [num_agrupacion]
                                    dagsSql = """select * from AGRUPACIONES_DESGLOSES WHERE NUMERO_AGRUPACION = :num_agrupacion"""
                                    getDagsLine = oracle.consult(dagsSql, {'num_agrupacion':num_agrupacion})
                                    if getDagsLine  is not None and len(getDagsLine) > 0:
                                        for dLine in getDagsLine:
                                            documentoDag = str(dLine['DOCUMENTO']).strip()
                                            sqlEsFactura = """SELECT 1 FROM facturas_ventas fv WHERE fv.numero_fra_conta = :documentoDag"""
                                            esFactura    = oracle.consult(sqlEsFactura, {'documentoDag': documentoDag})
                                            # quito las facturas y facturas rectificativas que se mezclan con los dags
                                            if esFactura is not None and len(esFactura) > 0:
                                                continue
                                            chargeSql  = """select TO_NUMBER(hda.IMPORTE) AS IMPORTE_COBRADO, TO_CHAR(hda.FECHA_ASIENTO, 'YYYY-MM-DD') AS FECHA_COBRO
                                                                from historico_detallado_apuntes hda, HISTORICO_COBROS hc
                                                                where hda.DOCUMENTO = hc.DOCUMENTO 
                                                                    AND hda.DOCUMENTO = :documentoDag 
                                                                    AND hda.CODIGO_CONCEPTO = 'REM' 
                                                                    AND hda.ENTIDAD = 'CL'
                                                                    AND hda.CODIGO_ENTIDAD = hc.CODIGO_CLIENTE
                                                                    AND NOT EXISTS ( SELECT 1 FROM facturas_ventas fv WHERE fv.numero_fra_conta = :documentoDag)
                                                                ORDER BY hda.FECHA_ASIENTO DESC
                                                            """
                                            chargeInfo = oracle.consult(chargeSql, {'documentoDag':documentoDag})
                                            if chargeInfo is not None and len(chargeInfo) > 0:
                                                    invoice['fecha_cobro_dag_TOP'] = f"COBRADO {documentoDag} {chargeInfo[0]['FECHA_COBRO']}"
                                                    show_IMPORTE_COBRADO = chargeInfo[0]['IMPORTE_COBRADO']
                                                    if float(chargeInfo[0]['IMPORTE_COBRADO'] or 0) > float(invoice['LIQUIDO_FACTURA'] or 0):
                                                        show_IMPORTE_COBRADO = invoice['LIQUIDO_FACTURA']
                                                    save_line_invoice_line(saleLine, chargeInfo[0]['FECHA_COBRO'], currentDate, invoice, invoice['LIQUIDO_FACTURA'], show_IMPORTE_COBRADO)
                                            else:
                                                # aqui estan las facturas con el DAG no cobrado aun
                                                invoice['fecha_cobro_dag_BOTTOM'] = f"NO COBRADO DAG BOTTOM {documentoDag}"
                                                save_line_invoice_line(saleLine, "", currentDate, invoice, invoice['LIQUIDO_FACTURA'], invoice['IMPORTE_COBRADO'])

                        else:
                            saleLine, created = InvoicesSales.objects.get_or_create(documento=documentoString, ejercicio=yearString)
                            invoice['fecha_cobro_dag'] = 'FACTURA SIN DARS'
                            save_line_invoice_line(saleLine, "", currentDate, invoice, invoice['LIQUIDO_FACTURA'], invoice['IMPORTE_COBRADO'])

                else:
                    saleLine, created = InvoicesSales.objects.get_or_create(documento=documentoString, ejercicio=yearString)
                    invoice['fecha_cobro_dag'] = 'FACTURA CON FECHA'
                    save_line_invoice_line(saleLine, invoice['FECHA_ASIENTO_COBRO'], currentDate, invoice, invoice['LIQUIDO_FACTURA'], invoice['IMPORTE_COBRADO'])
                                                  
       
            
              
    

               


           
            

  
            

            x += [invoice]


    

    oracle.close()
    return x





"""
FX1/000035 -- 2 vencimiento sin pagar y mill items
FN1/000067 -- sin cobrar , documento en vivo
FN1/000068 -- sin cobrar , documento en vivo
FN1/000757 -- COBRADO "DOCUMENTO_VIVO": "N"


"""