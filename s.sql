SELECT
    ehs.FECHA_PREV_LLEGADA,
    ehs.num_expediente AS NUM_EXPEDIENTE,
    eae.articulo AS ARTICULO,
    eae.PRECIO,
    (CASE WHEN ei.divisa = 'USD' THEN eae.precio * ei.valor_cambio ELSE eae.precio END) AS PRECIO_EUR_ORIGINAL,
    eae.cantidad as CANTIDAD,
    ehs.fecha_llegada,
    ehs.codigo_entrada,
    ec.contenedor AS NUMERO,
    ei.divisa,
    ei.valor_cambio,
    'EXP' AS ENTIDAD,
    -23123 as PRECIO_EUR
  FROM expedientes_hojas_seguim ehs
  JOIN expedientes_articulos_embarque eae ON ehs.num_expediente = eae.num_expediente AND ehs.num_hoja = eae.num_hoja AND ehs.empresa = eae.empresa
  JOIN expedientes_imp ei ON ei.codigo = eae.num_expediente AND ei.empresa = eae.empresa
  JOIN expedientes_contenedores ec ON ec.num_expediente = eae.num_expediente AND ec.num_hoja = eae.num_hoja AND ec.empresa = eae.empresa
  WHERE 
      ei.codigo = 273
      AND ehs.codigo_entrada IS NULL
      AND ehs.empresa = '001'
  ORDER BY ehs.FECHA_PREV_LLEGADA ASC;


SELECT
    ehs.FECHA_PREV_LLEGADA,
    ehs.num_expediente AS NUM_EXPEDIENTE,
    eae.articulo AS ARTICULO,
    eae.PRECIO,
    (CASE WHEN ei.divisa = 'USD' THEN eae.precio * ei.valor_cambio ELSE eae.precio END) AS PRECIO_EUR_ORIGINAL,
    eae.cantidad as CANTIDAD,
    ehs.fecha_llegada,
    ehs.codigo_entrada,
    ec.contenedor AS NUMERO,
    ei.divisa,
    ei.valor_cambio,
    'EXP' AS ENTIDAD,
    -234234 as PRECIO_EUR
  FROM expedientes_hojas_seguim ehs
  JOIN expedientes_articulos_embarque eae ON ehs.num_expediente = eae.num_expediente AND ehs.num_hoja = eae.num_hoja AND ehs.empresa = eae.empresa
  JOIN expedientes_imp ei ON ei.codigo = eae.num_expediente AND ei.empresa = eae.empresa
  JOIN expedientes_contenedores ec ON ec.num_expediente = eae.num_expediente AND ec.num_hoja = eae.num_hoja AND ec.empresa = eae.empresa
  WHERE 
      ehs.FECHA_PREV_LLEGADA >= TO_DATE('2025-06-11', 'YYYY-MM-DD')
      AND ehs.codigo_entrada IS NULL
      AND ehs.empresa = '001' and ehs.num_expediente = 273
      AND ( eae.articulo = '40095')
  ORDER BY ehs.FECHA_PREV_LLEGADA DESC;


-- eae.articulo = '41210' or
-- drrWq9SNsFJH AND (ec.contenedor IS NULL OR ec.contenedor != 'CNT')  AND eae.ARTICULO = '40342'