import json
from froxa.utils.connectors.libra_connector import OracleConnector
from froxa.utils.utilities.funcions_file import json_encode_all
from produccion.models import ArticleCostsHead, ArticleCostsLines
from produccion.utils.get_me_stock_file import consumo_pasado, get_me_stock_now, obtener_rangos_meses, pedidos_pendientes

"""
1. comentar si no tengo STOCK se coge asi todo el precio que marca libra
2. hay articulos que tienen precio 0, los mostrare en rojo
3. los expedientes en $ que valor de cambio aplicar y si hay que cambia el valor de cambio que se aplica
4. solo se usan los expedientes que tienen contenedor asignado
5. 
"""

def recalculate_price_projections(request):
    oracle = OracleConnector()
    oracle.connect()

    # 1. FROXA DB going to look for parent articles 
    
    # articulos_pardes = ArticleCostsHead.objects.all().values('article_code','article_name')
    articulos_pardes = ArticleCostsHead.objects.filter(article_code=40128).values('article_code','article_name')
    # # # # # # # # articulos_pardes = json_encode_all(articulos_pardes)

    # 2. FROXA DB going to look for the ingredientes of parent articles
    
    articulos_data = []
    for a in articulos_pardes:
        lineas = ArticleCostsLines.objects.filter(parent_article=a['article_code']).values('parent_article', 'article_code', 'article_name','percentage','alternative')
        lineas = list(lineas)

        articulos_data += [{
            '__article__erp'  : str(a['article_code']),
            '__article__name' : a['article_name'], 
            'lineas'          : lineas,
            'precio_padre_act': 0,
            'costes_fecha'    : []
        }]

    # 3. FROXA DB convert erp codes into a string +"codigos_erp": "306302401, 306302431"

    for itemA in articulos_data:
        lineas_array = itemA['lineas']

        for lineas_itemA in lineas_array:
            lineas_itemA['parent_article'] = str(lineas_itemA['parent_article'])
            lineas_itemA['article_code']   = str(lineas_itemA['article_code'])
            codigos   = [str(lineas_itemA['article_code'])]
            alternatives = json.loads(lineas_itemA['alternative'])
            if len(alternatives) > 0:
                for altArtA in alternatives:
                    codigos += [str(altArtA['code'])]
            lineas_itemA['codigos_erp_arr'] = codigos
            lineas_itemA['consiste_de_alternativos'] = []

    # 4. FROXA DB search for prices and stock in all alternative articles 

    for itemB in articulos_data:
        lineas_array = itemB['lineas']
        for lineas_itemB in lineas_array:
            for one_erp_code in lineas_itemB['codigos_erp_arr']:
                stock_price = get_me_stock_now(one_erp_code, oracle)
                lineas_itemB['consiste_de_alternativos'] += [stock_price]
            
    # 5. calculate the price of the alternative article consisting of substitate items

    for itemC in articulos_data:
        lineas_array  = itemC['lineas'];
        for lineas_itemC in lineas_array:
            formula_top_ud   = 0
            unidades_stock   = 0
            suma_precios     = 0
            percentage       = lineas_itemC['percentage']
            i = 0
            for infoItemC in lineas_itemC['consiste_de_alternativos']:
                i += 1
                formula_top_ud += float(infoItemC[0]['stock']) * float(infoItemC[0]['precio'])
                unidades_stock += float(infoItemC[0]['stock'])
                suma_precios   += float(infoItemC[0]['precio'])
               
            if unidades_stock == 0:
                lineas_itemC['resumen_alternativos'] = {'precio_kg': float(suma_precios) / float(i), 'stock_kg': float(unidades_stock), 'parte_proporcional': float(suma_precios) / float(i) / 100 * float(percentage) }
            else:
                lineas_itemC['resumen_alternativos'] = {'precio_kg': float(formula_top_ud) /  float(unidades_stock), 'stock_kg': unidades_stock, 'parte_proporcional':  float((formula_top_ud / unidades_stock)) / 100 * float(percentage) }
                

    # 6. calculate price actuality of parent article PUEDE SER QUE NO HACE FALTA

    for itemJU in articulos_data:
        father_price = 0
        lineas_array  = itemJU['lineas']
        for lineas_itemJUI in lineas_array:
            resum_alternate = lineas_itemJUI['resumen_alternativos']
            father_price   += float(resum_alternate['parte_proporcional'])
         
        itemJU['precio_padre_act'] = father_price
        

    
    # 7. obtain range months 
    rango_meses = obtener_rangos_meses()
    for itemD in articulos_data:
        lineas_array  = itemD['lineas']
        for lineas_itemD in lineas_array:
            fechas_desde_hasta = []
            for rango in rango_meses:
                fechas_desde_hasta += [{'desde':rango[0], 'hasta':rango[1], 'info_suma_llegadas': 0, 'info_suma_consumo':0}]
            lineas_itemD['rango'] = fechas_desde_hasta
            
        

    # 8. I iterante the data ranges and search for 1. container arrivals
    for itemF in articulos_data:
        lineas_array  = itemF['lineas'];
        for lineas_itemF in lineas_array:
            arr_codigos_erp = lineas_itemF['codigos_erp_arr']
            
            for r_fechas in lineas_itemF['rango']:
                r_fechas['llegadas'] = pedidos_pendientes(oracle, arr_codigos_erp, r_fechas)
                r_fechas['consumo']  = consumo_pasado(oracle, arr_codigos_erp, r_fechas)

               
     
    # 9. 
    for itemG in articulos_data:
        lineas_array  = itemG['lineas']
        for lineas_itemG in lineas_array:
            pecentage = float(lineas_itemG['percentage'])
            PRECIO    = float(lineas_itemG['resumen_alternativos']['precio_kg'])
            STOCK     = float(lineas_itemG['resumen_alternativos']['stock_kg'])
            for rango_fechasG in lineas_itemG['rango']:
                # exist arrivals START
                if rango_fechasG['llegadas'] and len(rango_fechasG['llegadas']) > 0:
                    for llegadaG in rango_fechasG['llegadas']:      
                        PRECIO = ((float(PRECIO) * float(STOCK)) + (float(llegadaG['CANTIDAD']) * float(llegadaG['PRECIO_EUR']))) / (float(llegadaG['CANTIDAD']) + STOCK)
                        rango_fechasG['info_suma_llegadas'] += float(llegadaG['CANTIDAD'])
                        STOCK                               += float(llegadaG['CANTIDAD'])
                # exist arrivals FIN
        
                rango_fechasG['precio_con_llegada']    = PRECIO;
                rango_fechasG['precio_and_percentage'] = PRECIO / 100 * pecentage

                # exist consum START
                if rango_fechasG['consumo'] and len(rango_fechasG['consumo']) > 0:     
                    for consumA in rango_fechasG['consumo']:
                        STOCK -= float(consumA['CANTIDAD'])
                        rango_fechasG['info_suma_consumo'] -= float(consumA['CANTIDAD'])
                # exist consum FIN      
                if STOCK < 0:
                    STOCK = 0
                rango_fechasG['stock_final_rango'] = STOCK


    oracle.close()
    return articulos_data


