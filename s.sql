 SELECT
              pc.numero_pedido AS NUMERO,
              pc.fecha_pedido AS FECHA_PREV_LLEGADA,
              pc.codigo_proveedor,
              pc.codigo_divisa,
              pcl.codigo_articulo AS ARTICULO,
              pcl.descripcion AS descripcion_articulo,
              pcl.precio_presentacion AS PRECIO_EUR,
              pcl.unidades_pedidas as CANTIDAD,
              pcl.unidades_entregadas,
              pcl.precio_presentacion,
              pcl.importe_lin_neto,
              pc.status_cierre,
              'PED' AS ENTIDAD
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
                AND pc.numero_pedido = 581
                AND (pcl.unidades_entregadas is NULL OR pcl.unidades_entregadas = 0)
            ORDER BY pc.fecha_pedido ASC;