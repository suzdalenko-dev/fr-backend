import io
import json
import requests, os
from froxa.utils.utilities.funcions_file import end_of_month_dates, get_keys, tCSV
from produccion.models import DetalleEntradasEquivCC, EmbarkedIndividualRatingDetail, EmbarkedIndividualRatingHorizontal, EquivalentsHead, ExcelLinesEditable

def upload_csv(table_name):

    keys = get_keys('pbi.froxa.json')

    # Generar el contenido CSV en memoria
    content_file = generate_content_csv(table_name)
    buffer = io.StringIO()
    buffer.write(content_file)
    buffer.seek(0)

    # Simular envío de archivo sin crear localmente
    files = {'file': ('{}.csv'.format(table_name), buffer.getvalue(), 'text/csv')}
    response = requests.post(keys['host'] + '?key0=' + keys['key0'] + '&key1=' + keys['key1'], files=files)
    # print("Código de estado: ", response.status_code)
    # print("Respuesta: ", response.text)
    return response
    

def generate_content_csv(table_name):
    if table_name == '1detalle_entradas_equiv_cc':
        fields = ["name;entrada;stock_actual;pcm_actual;consumo_prod;consumo_vent;entrada_kg;entrada_eur;calc_kg;calc_eur;"] 
        for obj in DetalleEntradasEquivCC.objects.all():
            fila = [ str(obj.name or ""),
                str(obj.entrada or ""),
                tCSV(obj.stock_actual or ""), 
                tCSV(obj.pcm_actual or ""), 
                tCSV(obj.consumo_prod or ""), 
                tCSV(obj.consumo_vent or ""),
                tCSV(obj.entrada_kg or ""),
                tCSV(obj.entrada_eur or ""),
                tCSV(obj.calc_kg or ""),
                tCSV(obj.calc_eur or "")
            ]
            fields.append(";".join(fila))


    if table_name == '2equivalents_head':
        list_dates = end_of_month_dates()
        fields = ["article_name;fecha;kg_act;price_act;"]
        for obj in EquivalentsHead.objects.all():
            NAME = str(obj.article_name or "")
            for x in [0, 1, 2, 3, 4]:
                line = [NAME, list_dates[x]]
                if x == 0:
                    line += [tCSV(obj.kg_act or ""), tCSV(obj.price_act or "")]
                if x == 1:
                    line += [tCSV(obj.kg0 or ""), tCSV(obj.price0 or "")]
                if x == 2:
                    line += [tCSV(obj.kg1 or ""), tCSV(obj.price1 or "")]
                if x == 3:
                    line += [tCSV(obj.kg2 or ""), tCSV(obj.price2 or "")]
                if x == 4:
                    line += [tCSV(obj.kg3 or ""), tCSV(obj.price3 or "")]
    
                fields.append(";".join(line)+';')

    
    if table_name == '3proyeccion-costes-con-contenedor':
        list_dates = end_of_month_dates()
        fields = ["article_name;fecha;price;y;title;"]
        for obj in ExcelLinesEditable.objects.all():
            NAME = str(obj.article_name or "")+" "+str(obj.article_code or "")
            y0 = float(obj.final_coste_act  or 0) - float(obj.precio_padre_mas_gastos or 0)
            y1 = float(obj.final_coste_mas1 or 0) - float(obj.final_coste_act or 0)
            y2 = float(obj.final_coste_mas2 or 0) - float(obj.final_coste_mas1 or 0)
            y3 = float(obj.final_coste_mas3 or 0) - float(obj.final_coste_mas2 or 0)
            y  = y0 + y1 + y2 + y3
            title = 'Estable'
            if y >= 0.099:
                title = 'Precio sube'
            if y <= -0.099:
                title = 'Precio baja'

            for x in [0, 1, 2, 3, 4]:
                line = [NAME, list_dates[x]]
                if x == 0:
                    line += [tCSV(obj.precio_padre_mas_gastos or 0), tCSV(y), title]
                if x == 1:
                    line += [tCSV(obj.final_coste_act or 0), tCSV(y), title]
                if x == 2:
                    line += [tCSV(obj.final_coste_mas1 or 0), tCSV(y), title]
                if x == 3:
                    line += [tCSV(obj.final_coste_mas2 or 0), tCSV(y), title]
                if x == 4:
                    line += [tCSV(obj.final_coste_mas3 or 0), tCSV(y), title]

                fields.append(";".join(line)+';')
           

    if table_name == '4entradas-con-sin-contenedor-calculo-precio-stock':
        fields = ["id;name;entrada;stock_actual;pcm_actual;consumo_prod;consumo_vent;entrada_kg;entrada_eur;calc_kg;calc_eur;mercado;"]
        for obj in EmbarkedIndividualRatingDetail.objects.all():
            fila = [ 
               str(obj.id or ""),
               str(obj.name or "")+" "+str(obj.code or ""),
               str(obj.entrada or ""),
               tCSV(obj.stock_actual or ""), 
               tCSV(obj.pcm_actual or ""), 
               tCSV(obj.consumo_prod or ""), 
               tCSV(obj.consumo_vent or ""),
               tCSV(obj.entrada_kg or ""),
               tCSV(obj.entrada_eur or ""),
               tCSV(obj.calc_kg or ""),
               tCSV(obj.calc_eur or ""),
               str(obj.mercado or ""),
            ]
            fields.append(";".join(fila)+';')


    if table_name == '5entradas-con-sin-contenedor-calculo-precio-stock-horizontal':
        fields = ["name;mercado;fecha;stock;precio;familia;subfamilia;"]
        for obj in EmbarkedIndividualRatingHorizontal.objects.all():
            fila = [ 
               str(obj.name or "")+" "+str(obj.code or ""),
               str(obj.mercado or ""),
               str(obj.fecha or ""),
               tCSV(obj.stock or ""), 
               tCSV(obj.precio or ""),
               str(obj.familia or ""),
               str(obj.subfamilia or ""),
            ]

            fields.append(";".join(fila)+';')

                   
    if table_name == 'x':
        x = 0
        pass


    return "\n".join(fields)













# file_name = os.path.join("/var/log/froxa", str(table_name)+'.csv')
# 
# content_file = generate_content_csv(table_name)
# with open(file_name, 'w', encoding='utf-8') as f:
#     f.write(content_file)
# 
# with open(file_name, 'rb') as f:
#     files = {'file': (file_name, f)}
#     response = requests.post(keys['host']+'?key0='+keys['key0']+'&key1='+keys['key1'], files=files)
#     print("Código de respuesta:", response.status_code)
#     print("Contenido de respuesta:", response.text)
#     return response