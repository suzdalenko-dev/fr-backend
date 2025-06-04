-- el ultimo expediente con contenedor drrWq9SNsFJH art= 41210 prec= 6,0081
  "precio": 6.0081,
  "stock": 119313.84

SELECT
                      ehs.FECHA_PREV_LLEGADA,
                      ehs.num_expediente,
                      eae.articulo,
                      eae.PRECIO,
                      (CASE WHEN ei.divisa = 'USD' THEN eae.precio * ei.valor_cambio ELSE eae.precio END) AS PRECIO_EUR,
                      eae.cantidad as CANTIDAD,
                      ehs.fecha_llegada,
                      ehs.codigo_entrada,
                      ec.contenedor,
                      ei.divisa,
                      ei.valor_cambio,
                      'EXPEDIENTE' AS ENTIDAD
                    FROM expedientes_hojas_seguim ehs
                    JOIN expedientes_articulos_embarque eae ON ehs.num_expediente = eae.num_expediente AND ehs.num_hoja = eae.num_hoja AND ehs.empresa = eae.empresa
                    JOIN expedientes_imp ei ON ei.codigo = eae.num_expediente AND ei.empresa = eae.empresa
                    JOIN expedientes_contenedores ec ON ec.num_expediente = eae.num_expediente AND ec.num_hoja = eae.num_hoja AND ec.empresa = eae.empresa
                    WHERE 
                        ehs.codigo_entrada IS NULL
                        AND (ec.contenedor IS NULL OR ec.contenedor != 'CNT')
                        AND ehs.empresa = '001'
                    ORDER by ehs.FECHA_PREV_LLEGADA desc ;