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
WHERE ROWNUM = 1



