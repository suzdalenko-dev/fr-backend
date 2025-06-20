import calendar
from datetime import datetime
from dateutil.relativedelta import relativedelta
from froxa.utils.connectors.libra_connector import OracleConnector
from produccion.repository.embarcado_con_sin_cont.articulos_file import give_me_that_are_in_play, llegadas_pendientes
from produccion.utils.get_me_stock_file import consumo_pasado, get_me_stock_now, obtener_dias_restantes_del_mes, obtener_rangos_meses12, pedidos_pendientes, verificar_mes


def embarcado_art_con_sin_cont(request):
    oracle = OracleConnector()
    oracle.connect()

    codigos_art_11_month = give_me_that_are_in_play(oracle)
    
    
    # we hare looking current stock and price for each article

    for eq1 in codigos_art_11_month:
        eq1['precio_stock'] = get_me_stock_now(eq1['code'], oracle)
   

    # obtain range months
    rango_meses = obtener_rangos_meses12()
    for eq3 in codigos_art_11_month:
        fechas_desde_hasta = []
        for rango in rango_meses:
            fechas_desde_hasta += [{'desde':rango[0], 'hasta':rango[1], 'info_suma_llegadas': 0, 'info_suma_consumo':0}]
        eq3['rango'] = fechas_desde_hasta


    EXPEDIENTES_SIN_PRECIO_FINAL = []


    # I iterante the data ranges and search for  arrivals WITCHOUT CONTAINER AND WITH CONTAINER
    for eq4 in codigos_art_11_month:
        iterations = 0

        for r_fechas in eq4['rango']:
            r_fechas['llegadas'] = llegadas_pendientes(oracle, [eq4['code']], r_fechas, EXPEDIENTES_SIN_PRECIO_FINAL, iterations)
            r_fechas['consumo']  = consumo_pasado(oracle, [eq4['code']], r_fechas) 
            iterations += 1

    oracle.close()

    # 9. STOCK AND PRICE
    for eq5 in codigos_art_11_month:
        PRECIO    = float(eq5['precio_stock'][0]['precio'] or 0)
        STOCK     = float(eq5['precio_stock'][0]['stock'] or 0)
 
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


    # 10.
    today = datetime.today()
    mes_actual = (today.replace(day=1) + relativedelta(months=1, days=-1)).strftime("%Y-%m-%d")
    mes_mas1   = ((today + relativedelta(months=1)).replace(day=1) + relativedelta(months=1, days=-1)).strftime("%Y-%m-%d")
    mes_mas2   = ((today + relativedelta(months=2)).replace(day=1) + relativedelta(months=1, days=-1)).strftime("%Y-%m-%d")
    mes_mas3   = ((today + relativedelta(months=3)).replace(day=1) + relativedelta(months=1, days=-1)).strftime("%Y-%m-%d")

    for itemQ in codigos_art_11_month:
        
        eqArt = EquivalentsHead.objects.get(id=itemQ['id'])
        eqArt.kg_act    = float(itemQ['padre_valoracion_actual']['stock_kg'] or 0)
        eqArt.price_act = float(itemQ['padre_valoracion_actual']['precio_kg'] or 0)

        for rango in itemQ['rango']:                                 
            if rango['hasta'] == mes_actual:
               eqArt.kg0    = float(rango['stock_final_rango'] or 0)
               eqArt.price0 = float(rango['precio_con_llegada'] or 0)

            if rango['hasta'] == mes_mas1:
               eqArt.kg1    = float(rango['stock_final_rango'] or 0)
               eqArt.price1 = float(rango['precio_con_llegada'] or 0)

            if rango['hasta'] == mes_mas2:
               eqArt.kg2    = float(rango['stock_final_rango'] or 0)
               eqArt.price2 = float(rango['precio_con_llegada'] or 0)

            if rango['hasta'] == mes_mas3:
               eqArt.kg3    = float(rango['stock_final_rango'] or 0)
               eqArt.price3 = float(rango['precio_con_llegada'] or 0)

        eqArt.save()



    
    return codigos_art_11_month