-- pedidos y linea compra pendientes 
SELECT
                      pc.numero_pedido,
                      pc.fecha_pedido,
                      pc.organizacion_compras,
                      pc.codigo_proveedor,
                      pc.codigo_divisa,
                      pc.importe_total_pedido,
                      pcl.numero_linea,
                      pcl.codigo_articulo,
                      pcl.descripcion AS descripcion_articulo,
                      pcl.unidades_pedidas,
                      pcl.unidades_entregadas,
                      pcl.precio_presentacion,
                      pcl.importe_lin_neto,
                      pc.status_cierre
                    FROM
                      pedidos_compras pc
                    JOIN
                      pedidos_compras_lin pcl
                      ON pc.numero_pedido = pcl.numero_pedido
                      AND pc.serie_numeracion = pcl.serie_numeracion
                      AND pc.organizacion_compras = pcl.organizacion_compras
                      AND pc.codigo_empresa = pcl.codigo_empresa
                    WHERE
                      pc.codigo_empresa = '001'
                      AND pc.status_cierre = 'E'
                      AND pc.fecha_pedido >=  '29/05/25' AND pc.fecha_pedido <=  '29/05/25'
                      AND pcl.codigo_articulo = '41069'
;



SELECT
  ehs.FECHA_PREV_LLEGADA,
  ehs.num_expediente,
  ehs.num_hoja,
  eae.articulo,
  eae.PRECIO,
  (eae.precio * ei.valor_cambio) AS precio_eur,
  eae.cantidad,
  ehs.fecha_llegada,
  ehs.codigo_entrada,
  ec.contenedor,
  ei.divisa,
  ei.valor_cambio
FROM
  expedientes_hojas_seguim ehs
JOIN
  expedientes_articulos_embarque eae
    ON ehs.num_expediente = eae.num_expediente
    AND ehs.num_hoja = eae.num_hoja
    AND ehs.empresa = eae.empresa
JOIN
  expedientes_imp ei
    ON ei.codigo = eae.num_expediente
    AND ei.empresa = eae.empresa
LEFT JOIN
  expedientes_contenedores ec
    ON ec.num_expediente = eae.num_expediente
    AND ec.num_hoja = eae.num_hoja
    AND ec.empresa = eae.empresa
WHERE
  ehs.empresa = '001'
  AND ehs.codigo_entrada IS NULL
  AND (ec.contenedor IS NULL OR ec.contenedor != 'CNT') 
ORDER BY  ehs.FECHA_PREV_LLEGADA DESC
;


SELECT
  ehs.FECHA_PREV_LLEGADA,
  ehs.num_expediente,
  ehs.num_hoja,
  eae.articulo,
  eae.PRECIO,
  (eae.precio * ei.valor_cambio) AS precio_eur,
  eae.cantidad,
  ehs.fecha_llegada,
  ehs.codigo_entrada,
  ec.contenedor,
  ei.divisa,
  ei.valor_cambio
FROM
  expedientes_hojas_seguim ehs
JOIN
  expedientes_articulos_embarque eae
    ON ehs.num_expediente = eae.num_expediente
    AND ehs.num_hoja = eae.num_hoja
    AND ehs.empresa = eae.empresa
JOIN
  expedientes_imp ei
    ON ei.codigo = eae.num_expediente
    AND ei.empresa = eae.empresa
LEFT JOIN
  expedientes_contenedores ec
    ON ec.num_expediente = eae.num_expediente
    AND ec.num_hoja = eae.num_hoja
    AND ec.empresa = eae.empresa
WHERE
  ehs.empresa = '001'
  AND eae.articulo = '40054'
  -- Puedes activar el filtro por rango de fechas si lo necesitas:
  -- AND ehs.fecha_llegada BETWEEN TO_DATE('2025-06-01', 'YYYY-MM-DD') AND TO_DATE('2025-06-30', 'YYYY-MM-DD')
  -- Puedes incluir este filtro si solo quieres registros sin entrada:
  AND ehs.codigo_entrada IS NULL
  --- AND (ec.contenedor IS NULL OR ec.contenedor != 'CNT')
;


SELECT
  ehs.FECHA_PREV_LLEGADA,
  ehs.num_expediente,
  eae.articulo,
  eae.PRECIO,
  CASE WHEN ei.divisa = 'USD' THEN eae.precio * ei.valor_cambio ELSE eae.precio END AS precio_eur,
  eae.cantidad,
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
WHERE ehs.empresa = '001'
  AND eae.articulo = '41478'
  AND ehs.codigo_entrada IS NULL
  AND (ec.contenedor IS NULL OR ec.contenedor != 'CNT')
  ;

-- consumed

select 
    (SELECT ofc.FECHA_ENTREGA_PREVISTA FROM ORDENES_FABRICA_CAB ofc WHERE ofc.ORDEN_DE_FABRICACION = cofmc.ORDEN_DE_FABRICACION) AS FECHA_ENTREGA_PREVISTA,
    cofmc.ORDEN_DE_FABRICACION,
    cofmc.CODIGO_ARTICULO_CONSUMIDO,
    (select a.DESCRIP_COMERCIAL from articulos a where a.codigo_articulo = cofmc.CODIGO_ARTICULO_CONSUMIDO) AS DESCRIP_CONSUMIDO,
    (select a.unidad_codigo1 from  articulos a where a.codigo_articulo = cofmc.CODIGO_ARTICULO_CONSUMIDO) AS CODIGO_PRESENTACION,
    CANTIDAD_UNIDAD1
from COSTES_ORDENES_FAB_MAT_CTD cofmc
where codigo_articulo_consumido = '40765'
;


select *
FROM COSTES_ORDENES_FAB_MAT_CTD;

select FECHA_ENTREGA_PREVISTA 
from ORDENES_FABRICA_CAB;


select *

from ORDENES_FABRICA_CAB;


SELECT 
    ofc.FECHA_ENTREGA_PREVISTA AS FECHA_ENTREGA_PREVISTA_OF,
    cofmc.ORDEN_DE_FABRICACION,
    cofmc.CODIGO_ARTICULO_CONSUMIDO,
    a.DESCRIP_COMERCIAL AS DESCRIP_CONSUMIDO,
    a.unidad_codigo1 AS CODIGO_PRESENTACION,
    cofmc.CANTIDAD_UNIDAD1,
    'OFS_CONSUMO' AS CONSUMO_OFS
FROM 
    COSTES_ORDENES_FAB_MAT_CTD cofmc
JOIN 
    ORDENES_FABRICA_CAB ofc 
    ON ofc.ORDEN_DE_FABRICACION = cofmc.ORDEN_DE_FABRICACION
JOIN 
    articulos a 
    ON a.codigo_articulo = cofmc.CODIGO_ARTICULO_CONSUMIDO
WHERE 
    ofc.FECHA_ENTREGA_PREVISTA BETWEEN TO_DATE('01/01/01', 'DD/MM/YY') AND TO_DATE('01/01/99', 'DD/MM/YY');


SELECT
    c.fecha_pedido AS FECHA_VENTA,
    l.articulo AS CODIGO_ARTICULO,
    l.uni_seralm AS KG_VENDIDOS
FROM
    albaran_ventas_lin l
JOIN
    albaran_ventas c ON l.numero_albaran = c.numero_albaran AND l.numero_serie = c.numero_serie AND l.ejercicio = c.ejercicio AND l.organizacion_comercial = c.organizacion_comercial AND l.empresa = c.empresa
JOIN
    articulos a ON a.codigo_articulo = l.articulo
WHERE
    l.empresa = '001'
    AND NVL(l.linea_anulada, 'N') = 'N'
    AND l.articulo = '40218'
    AND c.fecha_pedido BETWEEN TO_DATE('2025-01-01', 'YYYY-MM-DD') AND TO_DATE('2025-12-31', 'YYYY-MM-DD')
ORDER BY
    c.fecha_pedido DESC;

select * from albaran_ventas_lin;




9240.0 31 2
596.1290322580645 ......................
mes actual = 2025-05-31
3781.0 31 2
243.93548387096774 ......................
mes actual = 2025-05-31
1722.0 31 2
111.09677419354838 ......................
mes actual = 2025-05-31
2211.0 31 2
142.6451612903226 ......................
mes actual = 2025-05-31
155.0 31 2
10.0 ......................
mes actual = 2025-05-31
3625.1999999999994 31 2
233.8838709677419 ......................
mes actual = 2025-05-31
1947.0 31 2
125.61290322580645