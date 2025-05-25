import json
from froxa.utils.utilities.funcions_file import json_encode_all
from produccion.models import ArticleCostsHead, ArticleCostsLines


def recalculate_price_projections(request):

    # 1. FROXA DB going to look for parent articles 
    
    # articulos_pardes = ArticleCostsHead.objects.all()
    articulos_pardes = ArticleCostsHead.objects.filter(article_code  =  40127).values('article_code','article_name')
    #articulos_pardes = json_encode_all(articulos_pardes)

    # 2. FROXA DB going to look for the ingredientes of parent articles
    
    articulos_data = []
    for a in articulos_pardes:
        lineas = ArticleCostsLines.objects.filter(parent_article=a['article_code']).values('parent_article', 'article_code', 'article_name','percentage','alternative')
        lineas = list(lineas)

        articulos_data += [{
            '__article__erp'  : a['article_code'],
            '__article__name' : a['article_name'], 
            'lineas'          : lineas,
            'costes_fecha'    : [],
            'precio_padre_act': 0
        }]

    # 3. FROXA DB convert erp codes into a string +"codigos_erp": "306302401, 306302431"

    for itemA in articulos_data:
        lineas_array = itemA['lineas']

        for lineas_itemA in lineas_array:
            codigos   = [lineas_itemA['article_code']]
            alternatives = json.loads(lineas_itemA['alternative'])
            if len(alternatives) > 0:
                for altArtA in alternatives:
                    codigos += [altArtA['code']]
            lineas_itemA['codigos_erp_arr'] = codigos
            lineas_itemA['consiste_de_alternativos'] = []


    # 4. FROXA DB search for prices and stock in all alternative articles 

    for itemB in articulos_data:
        lineas_array = itemB['lineas']
        for lineas_itemB in lineas_array:
            for one_erp_code in lineas_itemB['codigos_erp_arr']:
                # stock_price = AUtil::get_me_stock_now(one_erp_code)
                stock_price = 1       
                lineas_itemB['consiste_de_alternativos'] += [stock_price]


    return articulos_data