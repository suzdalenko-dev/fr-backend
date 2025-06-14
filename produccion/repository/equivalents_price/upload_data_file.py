import json
import requests, os
from froxa.utils.utilities.funcions_file import end_of_month_dates, get_keys, tCSV
from produccion.models import DetalleEntradasEquivCC, EquivalentsHead

def upload_csv(table_name):
    keys = get_keys('pbi.froxa.json')
    file_name = 'upload/'+table_name+'.csv'

    route_dir = os.path.dirname(file_name)
    if not os.path.exists(route_dir):
        os.makedirs(route_dir)
    
    content_file = generate_content_csv(table_name)
    with open(file_name, 'w', encoding='utf-8') as f:
        f.write(content_file)

    with open(file_name, 'rb') as f:
        files = {'file': (file_name, f)}
        response = requests.post(keys['host']+'?key0='+keys['key0']+'&key1='+keys['key1'], files=files)
        return response
    

def generate_content_csv(table_name):
    if table_name == 'detalle_entradas_equiv_cc':
        fields = ["name;entrada;stock_actual;pcm_actual;consumo_prod;consumo_vent;entrada_kg;entrada_eur;calc_kg;calc_eur"] 
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
            
    if table_name == 'equivalents_head':
        list_dates = end_of_month_dates()
        fields = ["article_name;fecha;kg_act;price_act"]
        for obj in EquivalentsHead.objects.all():
            NAME = str(obj.article_name or "")
            for x in [0, 1, 2, 3]:
                line = [NAME, list_dates[x]]
                if x == 0:
                    line += [tCSV(obj.kg0 or ""), tCSV(obj.price0 or "")]
                if x == 1:
                    line += [tCSV(obj.kg1 or ""), tCSV(obj.price1 or "")]
                if x == 2:
                    line += [tCSV(obj.kg2 or ""), tCSV(obj.price2 or "")]
                if x == 3:
                    line += [tCSV(obj.kg3 or ""), tCSV(obj.price3 or "")]
                fields.append(";".join(line))
           
                   
    if table_name == 'x':
        pass


    return "\n".join(fields)


