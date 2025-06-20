from froxa.utils.connectors.libra_connector import OracleConnector
from produccion.repository.embarcado_con_sin_cont.articulos_file import give_me_that_are_in_play
from produccion.utils.get_me_stock_file import consumo_pasado, get_me_stock_now, obtener_rangos_meses12


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
            # r_fechas['llegadas'] = llegadas_pendientes(oracle, eq4['code'], r_fechas, EXPEDIENTES_SIN_PRECIO_FINAL, iterations)
            r_fechas['consumo']  = consumo_pasado(oracle, [eq4['code']], r_fechas) 
            iterations += 1






    oracle.close()
    return codigos_art_11_month