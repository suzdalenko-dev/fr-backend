SELECT
  (SELECT TO_CHAR(OFB.FECHA_INI_FABRI, 'YYYY-MM-DD') FROM ORDENES_FABRICA_CAB OFB WHERE OFB.ORDEN_DE_FABRICACION = c.ORDEN_DE_FABRICACION) AS FECHA_INI_FABRI,
  ((SELECT descrip_comercial FROM articulos artx WHERE artx.CODIGO_ARTICULO = c.CODIGO_ARTICULO_CONSUMIDO) || ' ' || CODIGO_ARTICULO_CONSUMIDO) AS NOMBRE_ARTICULO,  
  (
    SELECT ar.unidad_codigo1
    FROM articulos ar
    WHERE ar.codigo_articulo = c.CODIGO_ARTICULO_CONSUMIDO
      AND ar.codigo_empresa = '001'
  ) AS CODIGO_PRESENTACION_COMPO,
  c.CANTIDAD_UNIDAD1,
  c.ORDEN_DE_FABRICACION,
  (
    SELECT f.descripcion
    FROM familias f
    WHERE f.numero_tabla = '1'
      AND f.codigo_empresa = '001'
      AND f.codigo_familia = (
        SELECT a.codigo_familia
        FROM articulos a
        WHERE a.codigo_articulo = c.CODIGO_ARTICULO_CONSUMIDO
          AND a.codigo_empresa = '001'
      )
  ) AS D_CODIGO_FAMILIA,
  (
    SELECT SUBSTR(f2.descripcion, 1, 20)
    FROM familias f2
    WHERE f2.numero_tabla = '2'
      AND f2.codigo_empresa = '001'
      AND f2.codigo_familia = (
        SELECT a2.codigo_estad2
        FROM articulos a2
        WHERE a2.codigo_articulo = c.CODIGO_ARTICULO_CONSUMIDO
          AND a2.codigo_empresa = '001'
      )
  ) AS SUBFAMILIA
FROM COSTES_ORDENES_FAB_MAT_CTD c;

