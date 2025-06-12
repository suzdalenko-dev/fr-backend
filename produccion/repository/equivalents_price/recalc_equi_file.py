import calendar
from datetime import datetime
import json
from froxa.utils.connectors.libra_connector import OracleConnector
from produccion.models import EquivalentsHead
from produccion.utils.get_me_stock_file import consumo_pasado, get_me_stock_now, obtener_dias_restantes_del_mes, obtener_rangos_meses, obtener_rangos_meses7, pedidos_pendientes, verificar_mes


def recalculate_equiv_with_contaner(request, action, entity, code):

    id = request.GET.get('id')
    equiv_data = []
    oracle     = OracleConnector()
    oracle.connect()
    
    if id and id.isdigit() and int(id) > 0:
        equiv = EquivalentsHead.objects.filter(id=id).values('id', 'article_name', 'alternative')
    else:
        equiv = EquivalentsHead.objects.all().values('id', 'article_name', 'alternative')
    equiv = list(equiv)

    for eq in equiv:
        listArtEquiv = json.loads(eq['alternative'])
        only_code    = []
        for article in listArtEquiv:
            only_code += [str(article['code'])]
        equiv_data += [
            {
                'id'                        : eq['id'],
                'padre_name'                : eq['article_name'],
                'articles'                  : only_code,
                'consiste_de_alternativos'  : [],
                'costes_fecha'              : [],
                'expediente_sin_precios'    : [],
            }
        ]

    # we hare looking current stock and price for each article

    for eq1 in equiv_data:
        estado_actual = []
        listadoArticulos = eq1['articles']
        for codeArt in listadoArticulos:
            stockPrice = get_me_stock_now(codeArt, oracle)
            estado_actual += [stockPrice]
        eq1['consiste_de_alternativos'] = estado_actual

    
    # calculate the common of price and stock of the equivalents

    for eq2 in equiv_data:
        formula_top_ud   = 0
        unidades_stock   = 0
        suma_precios     = 0
        i = 0
        lineas_array  = eq2['consiste_de_alternativos']

        for customArticle in lineas_array:
            i += 1
            formula_top_ud += float(customArticle[0]['stock'] or 0) * float(customArticle[0]['precio'] or 0)
            unidades_stock += float(customArticle[0]['stock'] or 0)
            suma_precios   += float(customArticle[0]['precio'] or 0)
               
            if unidades_stock == 0:
                eq2['padre_valoracion_actual'] = {'precio_kg': suma_precios / i, 'stock_kg': unidades_stock }
            else:
                eq2['padre_valoracion_actual'] = {'precio_kg': formula_top_ud /  unidades_stock, 'stock_kg': unidades_stock }
           

    EXPEDIENTES_SIN_PRECIO_FINAL = []
    
    # obtain range months
    rango_meses = obtener_rangos_meses()
    for eq3 in equiv_data:
        fechas_desde_hasta = []
        for rango in rango_meses:
            fechas_desde_hasta += [{'desde':rango[0], 'hasta':rango[1], 'info_suma_llegadas': 0, 'info_suma_consumo':0}]
        eq3['rango'] = fechas_desde_hasta


    # I iterante the data ranges and search for  arrivals WITCHOUT CONTAINER AND WITH CONTAINER
    for eq4 in equiv_data:
        arr_codigos_erp = eq4['articles']
            
        for r_fechas in eq4['rango']:
            r_fechas['llegadas'] = pedidos_pendientes(oracle, arr_codigos_erp, r_fechas, EXPEDIENTES_SIN_PRECIO_FINAL)
            r_fechas['consumo']  = consumo_pasado(oracle, arr_codigos_erp, r_fechas) 


    # 9. STOCK AND PRICE
    for eq5 in equiv_data:
        PRECIO    = float(eq5['padre_valoracion_actual']['precio_kg'] or 0)
        STOCK     = float(eq5['padre_valoracion_actual']['stock_kg'] or 0)
 
        for rango_fechasG in eq5['rango']:
            
            # exist arrivals START
            if rango_fechasG['llegadas'] and len(rango_fechasG['llegadas']) > 0:
                for llegadaG in rango_fechasG['llegadas']:
                    PRECIO = ((float(PRECIO) * float(STOCK)) + (float(llegadaG['CANTIDAD'] or 0) * float(llegadaG['PRECIO_EUR'] or 0))) / (float(llegadaG['CANTIDAD'] or 0) + STOCK)
                    rango_fechasG['info_suma_llegadas'] += float(llegadaG['CANTIDAD'] or 0)
                    STOCK                               += float(llegadaG['CANTIDAD'] or 0)
                    
            # exist arrivals FIN
            rango_fechasG['precio_con_llegada'] = PRECIO
            CONSUMO = 0

            # exist consum START
            if rango_fechasG['consumo'] and len(rango_fechasG['consumo']) > 0:     
                for consumA in rango_fechasG['consumo']:
                    CONSUMO += float(consumA['CANTIDAD'])
                
                    if verificar_mes(rango_fechasG['hasta']) == "mes actual":
                        print("MES ACTUAL")
                        fecha_dt = datetime.strptime(rango_fechasG['hasta'], "%Y-%m-%d").date()
                        numero_dias = calendar.monthrange(fecha_dt.year, fecha_dt.month)[1]
                        dias_restantes = obtener_dias_restantes_del_mes()
                        CONSUMO = CONSUMO / numero_dias * dias_restantes
                        
                rango_fechasG['info_suma_consumo'] -= CONSUMO
            # exist consum FIN      
    
            STOCK = STOCK - CONSUMO
            if STOCK < 0:
                STOCK = 0
            rango_fechasG['stock_final_rango'] = STOCK



    oracle.close()
    return equiv_data