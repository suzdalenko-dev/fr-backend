from datetime import date
from dateutil.relativedelta import relativedelta


def give_me_that_are_in_play(oracle):
    fechaDesde = (date.today() - relativedelta(months=11)).strftime('%Y-%m-%d')
    sql = """SELECT
            ehs.FECHA_PREV_LLEGADA,
            ehs.num_expediente AS NUM_EXPEDIENTE,
            eae.articulo AS ARTICULO,
            (SELECT DESCRIP_COMERCIAL FROM ARTICULOS WHERE CODIGO_ARTICULO = eae.articulo AND ROWNUM = 1) AS DESCRIPTION_ART,
            eae.PRECIO,
            (CASE WHEN ei.divisa = 'USD' THEN eae.precio * ei.valor_cambio ELSE eae.precio END) AS PRECIO_EUR_ORIGINAL,
            eae.cantidad as CANTIDAD,
            ehs.fecha_llegada,
            ehs.codigo_entrada,
            ec.contenedor AS NUMERO,
            ei.divisa,
            ei.valor_cambio,
            'EXP' AS ENTIDAD,
            -2222 as PRECIO_EUR
          FROM expedientes_hojas_seguim ehs
          JOIN expedientes_articulos_embarque eae ON ehs.num_expediente = eae.num_expediente AND ehs.num_hoja = eae.num_hoja AND ehs.empresa = eae.empresa
          JOIN expedientes_imp ei ON ei.codigo = eae.num_expediente AND ei.empresa = eae.empresa
          JOIN expedientes_contenedores ec ON ec.num_expediente = eae.num_expediente AND ec.num_hoja = eae.num_hoja AND ec.empresa = eae.empresa
          WHERE 
              ehs.FECHA_PREV_LLEGADA >= TO_DATE(:fechaDesde, 'YYYY-MM-DD')
              AND ehs.codigo_entrada IS NULL
              AND ehs.empresa = '001'
                                                                                        AND ( eae.articulo = '40417')                                  
          ORDER BY ehs.FECHA_PREV_LLEGADA DESC
    """
    
    
    res = oracle.consult(sql, {'fechaDesde':fechaDesde})

    unique_articles = []
    out_articles    = []
    for r in res:
        if not r['ARTICULO'] in unique_articles:
            unique_articles.append(r['ARTICULO'])
            x = {'name': r['DESCRIPTION_ART'], 'code': r['ARTICULO']}
            out_articles.append(x)

    return out_articles