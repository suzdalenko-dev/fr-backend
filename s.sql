select ehs.fecha_prev_llegada,
       ehs.num_expediente as num_expediente,
       eae.articulo as articulo,
       eae.precio,
       (
          case
             when ei.divisa = 'USD' then
                eae.precio * ei.valor_cambio
             else
                eae.precio
          end
       ) as precio_eur_original,
       eae.cantidad as cantidad,
       ehs.fecha_llegada,
       ehs.codigo_entrada,
       ec.contenedor as numero,
       ei.divisa,
       ei.valor_cambio,
       'EXP' as entidad,
       - 23123 as precio_eur
  from expedientes_hojas_seguim ehs
  join expedientes_articulos_embarque eae
on ehs.num_expediente = eae.num_expediente
   and ehs.num_hoja = eae.num_hoja
   and ehs.empresa = eae.empresa
  join expedientes_imp ei
on ei.codigo = eae.num_expediente
   and ei.empresa = eae.empresa
  join expedientes_contenedores ec
on ec.num_expediente = eae.num_expediente
   and ec.num_hoja = eae.num_hoja
   and ec.empresa = eae.empresa
 where ei.codigo = 273
   and ehs.codigo_entrada is null
   and ehs.empresa = '001'
 order by ehs.fecha_prev_llegada asc;


select ehs.fecha_prev_llegada,
       ehs.num_expediente as num_expediente,
       eae.articulo as articulo,
       eae.precio,
       (
          case
             when ei.divisa = 'USD' then
                eae.precio * ei.valor_cambio
             else
                eae.precio
          end
       ) as precio_eur_original,
       eae.cantidad as cantidad,
       ehs.fecha_llegada,
       ehs.codigo_entrada,
       ec.contenedor as numero,
       ei.divisa,
       ei.valor_cambio,
       'EXP' as entidad,
       - 234234 as precio_eur
  from expedientes_hojas_seguim ehs
  join expedientes_articulos_embarque eae
on ehs.num_expediente = eae.num_expediente
   and ehs.num_hoja = eae.num_hoja
   and ehs.empresa = eae.empresa
  join expedientes_imp ei
on ei.codigo = eae.num_expediente
   and ei.empresa = eae.empresa
  join expedientes_contenedores ec
on ec.num_expediente = eae.num_expediente
   and ec.num_hoja = eae.num_hoja
   and ec.empresa = eae.empresa
 where ehs.fecha_prev_llegada >= to_date('2025-06-11','YYYY-MM-DD')
   and ehs.codigo_entrada is null
   and ehs.empresa = '001'
   and ehs.num_expediente = 273
   and ( eae.articulo = '40095' )
 order by ehs.fecha_prev_llegada desc;


-- eae.articulo = '41210' or
-- drrWq9SNsFJH AND (ec.contenedor IS NULL OR ec.contenedor != 'CNT')  AND eae.ARTICULO = '40342'

-- 01 PN ENT M
-- 02 PR M PRS
-- 03 PC
-- 04 PX M


-- 2025-PX-84
select *
  from pedidos_ventas_lin
 where ejercicio = '2025'
   and numero_serie = 'PX'
   and numero_pedido = '84';


select empresa as last_change_value,
       (
          select lvemp.nombre
            from empresas_conta lvemp
           where lvemp.codigo = froxa_seguros_cambio.empresa
       ) as d_gc1,
       periodo as gc2,
       cambio as gn1
  from froxa_seguros_cambio
 where 1 = 1
   and rownum = 1
 order by gc2 desc;


select empresa,
       (
          select lvemp.nombre
            from empresas_conta lvemp
           where lvemp.codigo = froxa_seguros_cambio.empresa
       ) as d_gc1,
       periodo as gc2,
       cambio as gn1
  from froxa_seguros_cambio
 where 1 = 1
   and rownum = 1
 order by gc2 desc;


select empresa,
       periodo,
       cambio
  from froxa_seguros_cambio
 where 1 = 1
   and rownum = 1
 order by periodo desc;

select empresa,
       periodo,
       cambio
  from froxa_seguros_cambio
 where 1 = 1
   and rownum = 1
 order by periodo desc;



select expedientes_articulos_embarque.articulo c3,
       decode(
          coalesce(
             expedientes_hojas_seguim.valor_cambio,
             expedientes_imp.valor_cambio,
             1
          ),
          0,
          expedientes_articulos_embarque.precio,
          expedientes_articulos_embarque.precio * coalesce(
             expedientes_hojas_seguim.valor_cambio,
             expedientes_imp.valor_cambio,
             1
          )
       ) n9,
       ( ( (
          select sum(hs.importe_portes)
            from reparto_portes_hs hs
           where hs.codigo_empresa = expedientes_hojas_seguim.empresa
             and hs.numero_expediente = expedientes_hojas_seguim.num_expediente
             and hs.hoja_seguimiento = expedientes_hojas_seguim.num_hoja
             and hs.codigo_articulo = expedientes_articulos_embarque.articulo
       ) / decode(
          articulos.unidad_valoracion,
          1,
          expedientes_articulos_embarque.cantidad_unidad1,
          2,
          expedientes_articulos_embarque.cantidad_unidad2
       ) ) + ( expedientes_articulos_embarque.precio * decode(
          expedientes_hojas_seguim.tipo_cambio,
          'E',
          decode(
             expedientes_imp.cambio_asegurado,
             'S',
             expedientes_imp.valor_cambio,
             'N',
             1
          ),
          'S',
          expedientes_hojas_seguim.valor_cambio,
          'N',
          coalesce(
             expedientes_hojas_seguim.valor_cambio,
             expedientes_imp.valor_cambio,
             1
          )
       ) ) ) n10
  from (
   select articulos.*,
          decode(
             articulos.codigo_familia,
             null,
             null,
             (
                select lvfm.descripcion
                  from familias lvfm
                 where lvfm.codigo_familia = articulos.codigo_familia
                   and lvfm.numero_tabla = 1
                   and lvfm.codigo_empresa = articulos.codigo_empresa
             )
          ) d_codigo_familia
     from articulos
) articulos,
       (
          select expedientes_imp.*,
                 decode(
                    expedientes_imp.clave_arancel,
                    null,
                    null,
                    (
                       select lvarimp.descripcion
                         from aranceles_imp lvarimp
                        where lvarimp.clave_arancel = expedientes_imp.clave_arancel
                          and lvarimp.codigo_empresa = expedientes_imp.empresa
                    )
                 ) d_clave_arancel,
                 decode(
                    expedientes_imp.plantilla,
                    null,
                    null,
                    (
                       select lvpltimp.nombre
                         from plantillas_impor lvpltimp
                        where lvpltimp.codigo = expedientes_imp.plantilla
                          and lvpltimp.empresa = expedientes_imp.empresa
                    )
                 ) d_plantilla,
                 (
                    select lvexpc.descripcion
                      from expedientes_cab lvexpc
                     where lvexpc.codigo = expedientes_imp.codigo
                       and lvexpc.empresa = expedientes_imp.empresa
                 ) d_descripcion_expediente
            from expedientes_imp
       ) expedientes_imp,
       (
          select expedientes_hojas_seguim.*,
                 (
                    select descripcion
                      from expedientes_hojas_situacion
                     where codigo = expedientes_hojas_seguim.situacion_logistica
                 ) d_situacion_logistica,
                 nvl(
                    (
                       select pr.nombre
                         from proveedores pr
                        where pr.codigo_rapido = expedientes_hojas_seguim.proveedor
                          and pr.codigo_empresa = expedientes_hojas_seguim.empresa
                    ),
                    (
                       select pr.nombre
                         from proveedores pr,
                              expedientes_imp ei
                        where ei.codigo = expedientes_hojas_seguim.num_expediente
                          and ei.empresa = expedientes_hojas_seguim.empresa
                          and pr.codigo_rapido = ei.proveedor
                          and pr.codigo_empresa = ei.empresa
                    )
                 ) d_proveedor_hoja,

            from expedientes_hojas_seguim
       ) expedientes_hojas_seguim,
       (
          select expedientes_articulos_embarque.*,
                 (
                    select (
                       select decode(
                          usuarios.tipo_desc_art,
                          'V',
                          articulos.descrip_comercial,
                          'C',
                          articulos.descrip_compra,
                          'T',
                          articulos.descrip_tecnica,
                          articulos.descrip_comercial
                       )
                         from usuarios
                        where usuarios.usuario = pkpantallas.usuario_validado
                    )
                      from articulos
                     where articulos.codigo_articulo = expedientes_articulos_embarque.articulo
                       and articulos.codigo_empresa = expedientes_articulos_embarque.empresa
                 ) d_articulo,
                 (
                    select decode(
                       ar.unidad_precio_coste,
                       1,
                       cantidad_unidad1 * precio,
                       cantidad_unidad2 * precio
                    )
                      from articulos ar
                     where ar.codigo_articulo = expedientes_articulos_embarque.articulo
                       and ar.codigo_empresa = expedientes_articulos_embarque.empresa
                 ) importe
            from expedientes_articulos_embarque
       ) expedientes_articulos_embarque,
       expedientes_contenedores
 where ( expedientes_contenedores.num_expediente = expedientes_articulos_embarque.num_expediente
   and expedientes_contenedores.num_hoja = expedientes_articulos_embarque.num_hoja
   and expedientes_contenedores.empresa = expedientes_articulos_embarque.empresa
   and expedientes_contenedores.linea = expedientes_articulos_embarque.linea_contenedor
   and expedientes_hojas_seguim.num_expediente = expedientes_articulos_embarque.num_expediente
   and expedientes_hojas_seguim.num_hoja = expedientes_articulos_embarque.num_hoja
   and expedientes_hojas_seguim.empresa = expedientes_articulos_embarque.empresa
   and expedientes_imp.codigo = expedientes_hojas_seguim.num_expediente
   and expedientes_imp.empresa = expedientes_hojas_seguim.empresa
   and expedientes_articulos_embarque.empresa = '001'
   and articulos.codigo_articulo = expedientes_articulos_embarque.articulo
   and articulos.codigo_empresa = expedientes_articulos_embarque.empresa
   and ( expedientes_hojas_seguim.status not in ( 'C' ) ) )
   and ( articulos.codigo_empresa = '001' )
   and ( expedientes_imp.empresa = '001' )
   and ( expedientes_hojas_seguim.empresa = '001' )
   and ( expedientes_articulos_embarque.empresa = '001' )
   and ( expedientes_contenedores.empresa = '001' )
   and expedientes_hojas_seguim.num_expediente = 280
   and expedientes_articulos_embarque.articulo = 40069;



   SELECT *
FROM (
    SELECT
        eae.articulo AS c3,
        DECODE(
            COALESCE(ehs.valor_cambio, ei.valor_cambio, 1),
            0,
            eae.precio,
            eae.precio * COALESCE(ehs.valor_cambio, ei.valor_cambio, 1)
        ) AS n9,
        (
            (
                SELECT SUM(hs.importe_portes)
                FROM reparto_portes_hs hs
                WHERE hs.codigo_empresa = ehs.empresa
                  AND hs.numero_expediente = ehs.num_expediente
                  AND hs.hoja_seguimiento = ehs.num_hoja
                  AND hs.codigo_articulo = eae.articulo
            ) / DECODE(
                art.unidad_valoracion,
                1, eae.cantidad_unidad1,
                2, eae.cantidad_unidad2
            )
        ) + (
            eae.precio * DECODE(
                ehs.tipo_cambio,
                'E', DECODE(ei.cambio_asegurado, 'S', ei.valor_cambio, 'N', 1),
                'S', ehs.valor_cambio,
                'N', COALESCE(ehs.valor_cambio, ei.valor_cambio, 1)
            )
        ) AS n10,
        ehs.num_hoja
    FROM articulos art
    JOIN expedientes_articulos_embarque eae ON art.codigo_articulo = eae.articulo AND art.codigo_empresa = eae.empresa
    JOIN expedientes_hojas_seguim ehs ON ehs.num_expediente = eae.num_expediente AND ehs.num_hoja = eae.num_hoja AND ehs.empresa = eae.empresa
    JOIN expedientes_imp ei ON ei.codigo = ehs.num_expediente AND ei.empresa = ehs.empresa
    JOIN expedientes_contenedores ec ON ec.num_expediente = eae.num_expediente AND ec.num_hoja = eae.num_hoja AND ec.empresa = eae.empresa AND ec.linea = eae.linea_contenedor
    WHERE eae.empresa = '001'
      AND eae.articulo = 40069
      AND ehs.num_expediente = 280
      AND ehs.status NOT IN ('C')
    ORDER BY ehs.num_hoja DESC
)
WHERE ROWNUM = 1;

D_CODIGO_ESTAD8

select CODIGO_ESTAD8 from VA_ARTICULOS;

SELECT CODIGO_ESTAD8
FROM VA_ARTICULOS
WHERE CODIGO_EMPRESA = '001'
  AND CODIGO_ARTICULO = '40330';


  SELECT 
    A.CODIGO_ESTAD8,
    F.DESCRIPCION AS DESCRIPCION_MERCADO
FROM VA_ARTICULOS A
LEFT JOIN FAMILIAS F 
    ON F.CODIGO_EMPRESA = A.CODIGO_EMPRESA
    AND F.CODIGO_FAMILIA = A.CODIGO_ESTAD8
    AND F.NUMERO_TABLA = 8
WHERE A.CODIGO_EMPRESA = '001'
  AND A.CODIGO_ARTICULO = '40330';


select * from FAMILIAS where numero_tabla = 8;



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
                AND pcl.codigo_articulo = '40926'
                AND (pcl.unidades_entregadas IS NULL OR pcl.unidades_entregadas = 0)
            ORDER BY pc.fecha_pedido ASC;



SELECT V_FECHA_PEDIDO,V_CODIGO_ARTICULO,V_CODIGO_PROVEEDOR,D_CODIGO_PROVEEDOR,V_CANTIDAD_PRESENTACION,V_CANTIDAD_PRESENTACION_ENT,V_PRESENTACION_PEDIDO,V_PRECIO_PRESENTACION,V_DTO_1,V_DTO_2,V_DTO_3,V_IMPORTE_LIN_NETO,V_ORGANIZACION_COMPRAS,D_ORGANIZACION_COMPRAS,V_DESCRIPCION,V_USUARIO_ALTA,V_CODIGO_ALMACEN,V_CENTRO_CONTABLE,D_CODIGO_ALMACEN,D_CENTRO_CONTABLE,V_REFERENCIA_PROVEEDOR,V_CODIGO_DIVISA,V_FECHA_ENTREGA,V_FECHA_ENTREGA_TOPE,V_FECHA_ENTREGA_CONFIRM,V_UNIDADES_PEDIDAS,V_UNIDADES_ENTREGADAS,V_UNIDADES_PEDIDAS2,V_UNIDADES_ENTREGADAS2,V_PRECIO_NETO,V_SERIE_NUMERACION,V_NUMERO_PEDIDO,V_SOLICITUD_COMPRA,HAY_REPLICACION_VTA,NUMERO_LINEA,NUMERO_EXPEDIENTE FROM (SELECT  v.* ,(SELECT lvcc.nombre FROM caracteres_asiento lvcc WHERE lvcc.codigo = v.centro_contable AND lvcc.empresa = v.codigo_empresa) D_CENTRO_CONTABLE,(SELECT lval.nombre FROM almacenes lval WHERE lval.almacen = v.codigo_almacen AND lval.codigo_empresa = v.codigo_empresa) D_CODIGO_ALMACEN,DECODE(v.codigo_proveedor,NULL,NULL,(SELECT prlv.nombre FROM proveedores prlv WHERE prlv.codigo_rapido = v.codigo_proveedor AND codigo_empresa = v.codigo_empresa)) D_CODIGO_PROVEEDOR,(SELECT lvcpr.nombre FROM organizacion_compras lvcpr WHERE lvcpr.codigo_org_compras = v.organizacion_compras AND lvcpr.codigo_empresa = v.codigo_empresa) D_ORGANIZACION_COMPRAS,pkconsgen.hay_replicacion_pedcom_vta(v.numero_pedido, v.serie_numeracion, v.organizacion_compras, v.codigo_empresa, v.numero_linea) HAY_REPLICACION_VTA,CANTIDAD_PRESENTACION V_CANTIDAD_PRESENTACION,pkconsgen.cantidad_servida_pres_ped_com(p_empresa => codigo_empresa, p_numero_pedido => numero_pedido, p_numero_serie => serie_numeracion, p_organizacion_compras => organizacion_compras, p_numero_linea => numero_linea, p_articulo => codigo_articulo, p_presentacion_pedido => presentacion_pedido, p_cantidad_presentacion => cantidad_presentacion, p_unidades_pedidas => unidades_pedidas) V_CANTIDAD_PRESENTACION_ENT,CENTRO_CONTABLE V_CENTRO_CONTABLE,CODIGO_ALMACEN V_CODIGO_ALMACEN,CODIGO_ARTICULO V_CODIGO_ARTICULO,PKCONSGEN.DIVISA(codigo_divisa) V_CODIGO_DIVISA,CODIGO_PROVEEDOR V_CODIGO_PROVEEDOR,DESCRIPCION V_DESCRIPCION,dto_1 V_DTO_1,dto_2 V_DTO_2,dto_3 V_DTO_3,FECHA_ENTREGA V_FECHA_ENTREGA,FECHA_ENTREGA_CONFIRM V_FECHA_ENTREGA_CONFIRM,FECHA_ENTREGA_TOPE V_FECHA_ENTREGA_TOPE,FECHA_PEDIDO V_FECHA_PEDIDO,PKCONSGEN.IMPORTE_TXT(importe_lin_neto, importe_lin_neto_div, codigo_divisa) V_IMPORTE_LIN_NETO,NUMERO_PEDIDO V_NUMERO_PEDIDO,ORGANIZACION_COMPRAS V_ORGANIZACION_COMPRAS,DECODE((SELECT a.unidad_precio_coste FROM articulos a WHERE a.codigo_articulo = v.codigo_articulo AND a.codigo_empresa = v.codigo_empresa), 1, DECODE(unidades_pedidas, 0, PKCONSGEN.PRECIO_TXT(0, 0, codigo_divisa), PKCONSGEN.PRECIO_TXT(importe_lin_neto / unidades_pedidas, importe_lin_neto_div / unidades_pedidas, codigo_divisa)), DECODE(NVL(unidades_pedidas2, 0), 0, PKCONSGEN.PRECIO_TXT(0, 0, codigo_divisa), PKCONSGEN.PRECIO_TXT(importe_lin_neto  / unidades_pedidas2, importe_lin_neto_div / unidades_pedidas2, codigo_divisa))) V_PRECIO_NETO,PKCONSGEN.PRECIO_TXT(DECODE(tipo_precio, 'P', precio_presentacion, precio_coste) * cambio, DECODE(tipo_precio, 'P', precio_presentacion, precio_coste), codigo_divisa) V_PRECIO_PRESENTACION,PRESENTACION_PEDIDO V_PRESENTACION_PEDIDO,REFERENCIA_PROVEEDOR V_REFERENCIA_PROVEEDOR,SERIE_NUMERACION V_SERIE_NUMERACION,UNIDADES_ENTREGADAS V_UNIDADES_ENTREGADAS,UNIDADES_ENTREGADAS2 V_UNIDADES_ENTREGADAS2,UNIDADES_PEDIDAS V_UNIDADES_PEDIDAS,UNIDADES_PEDIDAS2 V_UNIDADES_PEDIDAS2,USUARIO_ALTA V_USUARIO_ALTA,SUBSTR(pkconsgen.f_solicitud_mat_pedido_compras(codigo_empresa, organizacion_compras, numero_pedido, serie_numeracion, numero_linea), 3) V_SOLICITUD_COMPRA FROM (SELECT l.codigo_empresa, l.codigo_articulo, c.codigo_almacen, l.unidades_entregadas, l.unidades_entregadas2, l.unidades_pedidas2, l.precio_presentacion, l.precio_coste, l.tipo_precio, l.organizacion_compras, c.centro_contable, c.fecha_pedido, l.fecha_entrega, l.fecha_entrega_confirm, l.fecha_entrega_tope, l.serie_numeracion, l.numero_pedido, l.numero_linea, DECODE(PKCONSGEN.VER_PRO_BLOQUEADOS, 'S', c.codigo_proveedor, DECODE(PKCONSGEN.PROVEEDOR_BLOQUEADO(c.codigo_empresa, c.codigo_proveedor), 'S', NULL, c.codigo_proveedor)) codigo_proveedor, l.referencia_proveedor, l.unidades_pedidas, l.unidades_facturadas, l.status_cierre, l.cantidad_presentacion, l.presentacion_pedido, l.dto_1, l.dto_2, l.dto_3, l.importe_lin_neto, l.importe_lin_neto_div, c.usuario_alta, c.codigo_divisa, c.cambio, l.descripcion,c.numero_expediente  FROM pedidos_compras c, pedidos_compras_lin l WHERE c.numero_pedido = l.numero_pedido AND c.serie_numeracion = l.serie_numeracion AND c.organizacion_compras = l.organizacion_compras AND c.codigo_empresa = l.codigo_empresa ORDER BY /*PKLBOB*/c.fecha_pedido DESC ) v)  v WHERE codigo_articulo = '40926' AND codigo_empresa = '001' AND status_cierre = 'E';



SELECT
  pc.numero_pedido AS NUMERO,
  pc.fecha_pedido AS FECHA_PREV_LLEGADA,
  pc.codigo_proveedor,
  (SELECT pr.nombre 
   FROM proveedores pr 
   WHERE pr.codigo_rapido = pc.codigo_proveedor 
     AND pr.codigo_empresa = pc.codigo_empresa) AS nombre_proveedor,

  pc.codigo_divisa,

  pcl.codigo_articulo AS ARTICULO,
  pcl.descripcion AS descripcion_articulo,
  
  -- Precio neto equivalente
  DECODE(
    (SELECT a.unidad_precio_coste 
     FROM articulos a 
     WHERE a.codigo_articulo = pcl.codigo_articulo 
       AND a.codigo_empresa = pcl.codigo_empresa),
    1,
      CASE 
        WHEN pcl.unidades_pedidas = 0 THEN 0
        ELSE pcl.importe_lin_neto / pcl.unidades_pedidas
      END,
    CASE 
      WHEN NVL(pcl.unidades_pedidas2, 0) = 0 THEN 0
      ELSE pcl.importe_lin_neto / pcl.unidades_pedidas2
    END
  ) AS PRECIO_EUR,

  -- Cantidad presentación
  pcl.cantidad_presentacion AS CANTIDAD,
  
  -- Unidades entregadas
  pkconsgen.cantidad_servida_pres_ped_com(
    p_empresa => pcl.codigo_empresa,
    p_numero_pedido => pcl.numero_pedido,
    p_numero_serie => pcl.serie_numeracion,
    p_organizacion_compras => pcl.organizacion_compras,
    p_numero_linea => pcl.numero_linea,
    p_articulo => pcl.codigo_articulo,
    p_presentacion_pedido => pcl.presentacion_pedido,
    p_cantidad_presentacion => pcl.cantidad_presentacion,
    p_unidades_pedidas => pcl.unidades_pedidas
  ) AS unidades_entregadas_calc,

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
  AND pcl.codigo_articulo = '40926'
  AND (pcl.unidades_entregadas IS NULL OR pcl.unidades_entregadas = 0)

ORDER BY pc.fecha_pedido ASC;


SELECT 
    A.CODIGO_ESTAD8,
    F.DESCRIPCION AS DESCRIPCION_MERCADO,
    (SELECT DESCRIPCION FROM FAMILIAS WHERE CODIGO_EMPRESA = A.CODIGO_EMPRESA AND NUMERO_TABLA = 1 AND CODIGO_FAMILIA = A.CODIGO_FAMILIA) AS D_CODIGO_FAMILIA,
    (SELECT DESCRIPCION FROM FAMILIAS WHERE CODIGO_EMPRESA = A.CODIGO_EMPRESA AND NUMERO_TABLA = 2 AND CODIGO_FAMILIA = A.CODIGO_ESTAD2) AS D_CODIGO_SUBFAMILIA
FROM VA_ARTICULOS A
LEFT JOIN FAMILIAS F 
    ON F.CODIGO_EMPRESA = A.CODIGO_EMPRESA
    AND F.CODIGO_FAMILIA = A.CODIGO_ESTAD8
    AND F.NUMERO_TABLA = 8
WHERE A.CODIGO_EMPRESA = '001'
  AND A.CODIGO_ARTICULO = '40000' AND ROWNUM = 1;



  SELECT *
FROM (
    SELECT
        eae.articulo AS c3,
        DECODE(
            COALESCE(ehs.valor_cambio, ei.valor_cambio, 1),
            0,
            eae.precio,
            eae.precio * COALESCE(ehs.valor_cambio, ei.valor_cambio, 1)
        ) AS n9,
        (
            (
                SELECT SUM(hs.importe_portes)
                FROM reparto_portes_hs hs
                WHERE hs.codigo_empresa = ehs.empresa
                  AND hs.numero_expediente = ehs.num_expediente
                  AND hs.hoja_seguimiento = ehs.num_hoja
                  AND hs.codigo_articulo = eae.articulo
            ) / DECODE(
                art.unidad_valoracion,
                1, eae.cantidad_unidad1,
                2, eae.cantidad_unidad2
            )
        ) + (
            eae.precio * DECODE(
                ehs.tipo_cambio,
                'E', DECODE(ei.cambio_asegurado, 'S', ei.valor_cambio, 'N', 1),
                'S', ehs.valor_cambio,
                'N', COALESCE(ehs.valor_cambio, ei.valor_cambio, 1)
            )
        ) AS n10,
        ehs.num_hoja,
        ehs.num_expediente
    FROM articulos art
    JOIN expedientes_articulos_embarque eae
      ON art.codigo_articulo = eae.articulo AND art.codigo_empresa = eae.empresa
    JOIN expedientes_hojas_seguim ehs
      ON ehs.num_expediente = eae.num_expediente AND ehs.num_hoja = eae.num_hoja AND ehs.empresa = eae.empresa
    JOIN expedientes_imp ei
      ON ei.codigo = ehs.num_expediente AND ei.empresa = ehs.empresa
    JOIN expedientes_contenedores ec
      ON ec.num_expediente = eae.num_expediente AND ec.num_hoja = eae.num_hoja AND ec.empresa = eae.empresa AND ec.linea = eae.linea_contenedor
    WHERE eae.empresa = '001'
      AND eae.articulo = '40030'
      AND ehs.status NOT IN ('C')
) 
WHERE n9 > 0 AND n10 > 0
ORDER BY num_expediente DESC, num_hoja DESC
FETCH FIRST 1 ROWS ONLY;
