SELECT
  om.ORDEN_DE_FABRICACION              AS ORDEN_DE_FABRICACION,
  om.CODIGO_COMPONENTE                         AS CODIGO_ARTICULO_CONSUMIDO,
  om.DESC_ARTICULO                  AS DESCRIP_CONSUMIDO,
  om.CODIGO_PRESENTACION_COMPO           AS CODIGO_PRESENTACION,
  om.CANT_REAL_CONSUMO_UNIDAD1 AS CANTIDAD_UNIDAD1
FROM OF_MATERIALES_UTILIZADOS om
WHERE om.ORDEN_DE_FABRICACION = '1039'
;

-- 2356199.6000000006

     SELECT
  (SELECT descripcion 
    FROM familias where numero_tabla = '7' AND codigo_familia = (
      SELECT a.codigo_estad7 
      FROM ARTICULOS a 
      WHERE a.CODIGO_ARTICULO = c.CODIGO_ARTICULO_CONSUMIDO AND ROWNUM = 1
    )) AS tipo_descr,
  (SELECT TO_CHAR(OFB.FECHA_INI_FABRI, 'YYYY-MM-DD') FROM ORDENES_FABRICA_CAB OFB WHERE OFB.ORDEN_DE_FABRICACION = c.ORDEN_DE_FABRICACION) AS FECHA_INI_FABRI,
  ((SELECT descrip_comercial FROM articulos artx WHERE artx.CODIGO_ARTICULO = c.CODIGO_ARTICULO_CONSUMIDO) || ' ' || CODIGO_ARTICULO_CONSUMIDO) AS NOMBRE_ARTICULO,  
  (
    SELECT ar.unidad_codigo1
    FROM articulos ar
    WHERE ar.codigo_articulo = c.CODIGO_ARTICULO_CONSUMIDO AND ar.codigo_empresa = '001'
  ) AS CODIGO_PRESENTACION_COMPO,
  TO_NUMBER(c.CANTIDAD_UNIDAD1) AS CANTIDAD_UNIDAD1,
  c.ORDEN_DE_FABRICACION,
  (
    SELECT f.descripcion
    FROM familias f
    WHERE f.numero_tabla = '1' AND f.codigo_empresa = '001'
      AND f.codigo_familia = (
        SELECT a.codigo_familia
        FROM articulos a
        WHERE a.codigo_articulo = c.CODIGO_ARTICULO_CONSUMIDO
          AND a.codigo_empresa = '001'
      )
  ) AS D_CODIGO_FAMILIA,
  (
    SELECT f2.descripcion
    FROM familias f2
    WHERE f2.numero_tabla = '2' AND f2.codigo_empresa = '001' AND f2.codigo_familia = (
        SELECT a2.codigo_estad2
        FROM articulos a2
        WHERE a2.codigo_articulo = c.CODIGO_ARTICULO_CONSUMIDO AND a2.codigo_empresa = '001'
      )
  ) AS SUBFAMILIA
FROM COSTES_ORDENES_FAB_MAT_CTD c
WHERE c.ORDEN_DE_FABRICACION = '1039';


-- # por alguan razon en esta tabla no estan los consumos de articulos fantasmas
-- # material_consumed = """select ORDEN_DE_FABRICACION,
-- #                         CODIGO_ARTICULO_PRODUCIDO,
-- #                         NUMERO_LOTE_INT_PRODUCIDO,
-- #                         CODIGO_ARTICULO_CONSUMIDO,
-- #                         (select DESCRIP_COMERCIAL from articulos where codigo_articulo = CODIGO_ARTICULO_CONSUMIDO) AS DESCRIP_CONSUMIDO,
-- #                         (select unidad_codigo1 from  articulos where codigo_articulo = CODIGO_ARTICULO_CONSUMIDO) AS CODIGO_PRESENTACION,
-- #                         NUMERO_LOTE_INT_CONSUMIDO,
-- #                         CANTIDAD_UNIDAD1,
-- #                         (select MAX(FECHA_CREACION) from historico_lotes where NUMERO_LOTE_INT  = NUMERO_LOTE_INT_CONSUMIDO and CODIGO_ARTICULO =  CODIGO_ARTICULO_CONSUMIDO) AS FECHA_CREACION,
-- #                         (select MAX(FECHA_CADUCIDAD) from historico_lotes where NUMERO_LOTE_INT = NUMERO_LOTE_INT_CONSUMIDO and CODIGO_ARTICULO =  CODIGO_ARTICULO_CONSUMIDO) AS FECHA_CADUCIDAD
-- #                     from COSTES_ORDENES_FAB_MAT_CTD
-- #                     where ORDEN_DE_FABRICACION = :of_id"""
-- # res[0]['MATERIAL_CONSUMIDO'] = oracle.consult(material_consumed, {"of_id": of_id})