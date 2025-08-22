-- 10 inventario
select ( v_froxa_stocks_nacional.codigo_almacen
         || ' '
         || (
   select nombre
     from almacenes
    where almacen = v_froxa_stocks_nacional.codigo_almacen
      and rownum = 1
) ) as almacen,
       v_froxa_stocks_nacional.codigo_almacen,
       (
          select descripcion
            from familias
           where numero_tabla = '7'
             and codigo_familia = (
             select a.codigo_estad7
               from articulos a
              where a.codigo_articulo = articulos.codigo_articulo
                and rownum = 1
          )
       ) as tipo_consumo_articulo,
       (
          select descripcion
            from familias
           where numero_tabla = '8'
             and codigo_familia = articulos.codigo_estad8
             and codigo_empresa = '001'
       ) d_codigo_estad8,
       substr(
          articulos.d_codigo_familia,
          1,
          20
       ) as familia,
       substr(
          articulos.d_codigo_estad2,
          1,
          20
       ) as subfamilia,
       articulos.codigo_familia as codigo_familia,
       articulos.codigo_estad2 as codigo_subfamilia,
       v_froxa_stocks_nacional.cliente as cliente,
       substr(
          v_froxa_stocks_nacional.codigo_articulo,
          1,
          12
       ) as codigo_articulo,
       substr(
          v_froxa_stocks_nacional.descrip_comercial,
          1,
          25
       ) as nombre_articulo,
       v_froxa_stocks_nacional.descrip_comercial
       || ' '
       || v_froxa_stocks_nacional.codigo_articulo as nombre_completo,
       v_froxa_stocks_nacional.cantidad_dis as cajas,
       v_froxa_stocks_nacional.cantidad_sob as unidades,
       v_froxa_stocks_nacional.cantidad_con as kilos,
       (
          select max(av.precio_standard)
            from articulos_valoracion av
           where av.codigo_empresa (+) = v_froxa_stocks_nacional.codigo_empresa
             and av.codigo_articulo (+) = v_froxa_stocks_nacional.codigo_articulo
             and av.codigo_almacen (+) = '00'
             and av.ejercicio = (
             select max(av2.ejercicio)
               from articulos_valoracion av2
              where av2.codigo_empresa (+) = v_froxa_stocks_nacional.codigo_empresa
                and av2.codigo_articulo (+) = v_froxa_stocks_nacional.codigo_articulo
                and av2.codigo_almacen (+) = '00'
          )
       ) as precio_standard,
       v_froxa_stocks_nacional.precio_medio_ponderado as precio_medio_ponderado,
       v_froxa_stocks_nacional.valor_pmp as valor_pmp,
       v_froxa_stocks_nacional.ultimo_precio_compra as ultimo_precio_compra,
       v_froxa_stocks_nacional.valor_upc as valor_upc,
       v_froxa_stocks_nacional.precio_consumo as precio_consumo,
       v_froxa_stocks_nacional.margen_pvp as margen_pvp,
       v_froxa_stocks_nacional.valor_pvp as valor_pvp,
       v_froxa_stocks_nacional.margen_unitario as margen_unitario
  from v_froxa_stocks_nacional,
       (
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
                 ) d_codigo_familia,
                 decode(
                    articulos.codigo_estad2,
                    null,
                    null,
                    (
                       select lvfm.descripcion
                         from familias lvfm
                        where lvfm.codigo_familia = articulos.codigo_estad2
                          and lvfm.numero_tabla = 2
                          and lvfm.codigo_empresa = articulos.codigo_empresa
                    )
                 ) d_codigo_estad2
            from articulos
       ) articulos
 where ( v_froxa_stocks_nacional.codigo_empresa = '001'
   and v_froxa_stocks_nacional.codigo_empresa = articulos.codigo_empresa
   and v_froxa_stocks_nacional.codigo_articulo = articulos.codigo_articulo )
   and ( articulos.codigo_empresa = '001' )
   and v_froxa_stocks_nacional.codigo_almacen in ( '00',
                                                   '02',
                                                   '80',
                                                   '98' )
   and v_froxa_stocks_nacional.cliente like '999999%';



-- 11 consumo produccion
select (
   select descripcion
     from familias
    where numero_tabla = '7'
      and codigo_familia = (
      select a.codigo_estad7
        from articulos a
       where a.codigo_articulo = c.codigo_articulo_consumido
         and rownum = 1
   )
) as tipo_descr,
       (
          select to_char(
             ofb.fecha_ini_fabri,
             'YYYY-MM-DD'
          )
            from ordenes_fabrica_cab ofb
           where ofb.orden_de_fabricacion = c.orden_de_fabricacion
       ) as fecha_ini_fabri,
       ( (
          select descrip_comercial
            from articulos artx
           where artx.codigo_articulo = c.codigo_articulo_consumido
       )
         || ' '
         || codigo_articulo_consumido ) as nombre_articulo,
       (
          select ar.unidad_codigo1
            from articulos ar
           where ar.codigo_articulo = c.codigo_articulo_consumido
             and ar.codigo_empresa = '001'
       ) as codigo_presentacion_compo,
       to_number(c.cantidad_unidad1) as cantidad_unidad1,
       c.orden_de_fabricacion,
       (
          select f.descripcion
            from familias f
           where f.numero_tabla = '1'
             and f.codigo_empresa = '001'
             and f.codigo_familia = (
             select a.codigo_familia
               from articulos a
              where a.codigo_articulo = c.codigo_articulo_consumido
                and a.codigo_empresa = '001'
          )
       ) as d_codigo_familia,
       (
          select f2.descripcion
            from familias f2
           where f2.numero_tabla = '2'
             and f2.codigo_empresa = '001'
             and f2.codigo_familia = (
             select a2.codigo_estad2
               from articulos a2
              where a2.codigo_articulo = c.codigo_articulo_consumido
                and a2.codigo_empresa = '001'
          )
       ) as subfamilia
  from costes_ordenes_fab_mat_ctd c;















-- llegadas de contenedores PRIMERO CONSULTA COMPLETA Y LUEGO LA CORTA
-- expedientes_articulos_embarque

select expedientes_articulos_embarque.articulo,
       expedientes_hojas_seguim.num_expediente,
       expedientes_hojas_seguim.num_hoja,
       expedientes_articulos_embarque.contenedor,
  -- expedientes_imp.forma_envio,
       expedientes_articulos_embarque.cantidad,
       (
          case
  -- Si la situación logística es '00', se realiza la operación de resta
             when exists (
                select 1
                  from expedientes_hojas_seguim h3
                 where expedientes_articulos_embarque.num_expediente = h3.num_expediente
                   and expedientes_articulos_embarque.num_hoja = h3.num_hoja
                   and h3.situacion_logistica = '00'
             ) then
                (
    -- Suma de las cantidades de las hojas de seguimiento donde la situación es '00'
                 (
                   select sum(h2.cantidad)
                     from expedientes_articulos_embarque h2
                    where expedientes_articulos_embarque.num_expediente = h2.num_expediente
                      and expedientes_articulos_embarque.articulo = h2.articulo
                      and exists (
                      select 1
                        from expedientes_hojas_seguim h3
                       where h2.num_expediente = h3.num_expediente
                         and h2.num_hoja = h3.num_hoja
                         and h3.situacion_logistica = '00'
                   )
                ) - (
      -- Resta de las cantidades de las hojas de seguimiento donde la situación no es '00'
                   select sum(h2.cantidad)
                     from expedientes_articulos_embarque h2
                    where expedientes_articulos_embarque.num_expediente = h2.num_expediente
                      and expedientes_articulos_embarque.articulo = h2.articulo
                      and exists (
                      select 1
                        from expedientes_hojas_seguim h3
                       where h2.num_expediente = h3.num_expediente
                         and h2.num_hoja = h3.num_hoja
                         and h3.situacion_logistica != '00'
                   )
                ) )
             else
    -- Si la situación no es '00', se devuelve la cantidad de expedientes_articulos_embarque
                expedientes_articulos_embarque.cantidad
          end
       ) as log_00,
       expedientes_articulos_embarque.presentacion as pres,
 -- expedientes_articulos_embarque.destino_especial,
 -- expedientes_articulos_embarque.deposito_aduanero,
       expedientes_articulos_embarque.precio,
       expedientes_articulos_embarque.importe,
       decode(
          nvl(
             expedientes_imp.valor_cambio,
             0
          ),
          0,
          expedientes_articulos_embarque.precio,
          expedientes_articulos_embarque.precio * expedientes_imp.valor_cambio
       ) coste_eur,
       coalesce(
          expedientes_hojas_seguim.valor_cambio,
          expedientes_imp.valor_cambio,
          1
       ) valor_cambio,
       expedientes_hojas_seguim.tipo_cambio,
 -- 1 / coalesce(EXPEDIENTES_HOJAS_SEGUIM.VALOR_CAMBIO, EXPEDIENTES_IMP.VALOR_CAMBIO,1) eur_usd,
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
       ) conste_s_g,
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
       ) ) ) conste_c_g_eur,
       expedientes_imp.d_clave_arancel as origen,
       expedientes_hojas_seguim.d_situacion_logistica,
       expedientes_hojas_seguim.documentacion_x_contenedor,
       expedientes_hojas_seguim.fecha_prev_llegada,
       expedientes_hojas_seguim.fecha_prev_embarque,
       expedientes_imp.d_plantilla,
       nvl(
          expedientes_hojas_seguim.proveedor,
          expedientes_imp.proveedor
       ) cod_prov,
       expedientes_hojas_seguim.d_proveedor_hoja proveedor_d,
       expedientes_imp.d_descripcion_expediente contrato,
       expedientes_hojas_seguim.codigo_entrada,
       expedientes_hojas_seguim.id_seguro_cambio,
        -- (select nombre from bancos b, Seguros_cambio c where b.codigo_rapido = c.banco and b.empresa = c.empresa and c.id = expedientes_hojas_seguim.id_seguro_cambio) nombre_bank,
       (
          select max(documento)
            from seguros_cambio c
           where c.id = expedientes_hojas_seguim.id_seguro_cambio
       ) as doc_seg_cam,
       (
          select sum(importe)
            from seguros_cambio c
           where c.id = expedientes_hojas_seguim.id_seguro_cambio
       ) as imorte_seguro,
       expedientes_hojas_seguim.carta_credito,
       (
          select max(fecha_vencimiento)
            from cartas_credito c
           where c.numero_carta_credito = expedientes_hojas_seguim.carta_credito
       ) venc_cart_cred
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
                 (
                    select
                       listagg(ec.num_carta_credito,
                               ',') within group(
                        order by ec.num_carta_credito)
                      from expedientes_hojas_seguim_mov ec
                     where ec.num_expediente = expedientes_hojas_seguim.num_expediente
                       and ec.num_hoja = expedientes_hojas_seguim.num_hoja
                       and ec.empresa = expedientes_hojas_seguim.empresa
                 ) carta_credito
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
   and ( '' is null
    or exists (
   select 1
     from expedientes_contenedores ec
    where ec.num_expediente = expedientes_hojas_seguim.num_expediente
      and ec.num_hoja = expedientes_hojas_seguim.num_hoja
      and ec.empresa = expedientes_hojas_seguim.empresa
      and contenedor like ''
) )
   and ( '' is null
    or exists (
   select 1
     from expedientes_contenedores ec
    where ec.num_expediente = expedientes_hojas_seguim.num_expediente
      and ec.num_hoja = expedientes_hojas_seguim.num_hoja
      and ec.empresa = expedientes_hojas_seguim.empresa
      and tipo = ''
) )
   and ( '' is null
    or ( exists (
   select 1
     from con_impor co,
          expedientes_hojas_seguim_con ec
    where co.codigo = ec.concepto
      and co.tipo = 'PO'
      and co.codigo_empresa = ec.empresa
      and ec.num_expediente = expedientes_hojas_seguim.num_expediente
      and ec.num_hoja = expedientes_hojas_seguim.num_hoja
      and ec.empresa = expedientes_hojas_seguim.empresa
      and proveedor = ''
) ) )
   and ( '' is null
    or ( exists (
   select 1
     from con_impor co,
          expedientes_hojas_seguim_con ec
    where co.codigo = ec.concepto
      and co.tipo = 'FL'
      and ec.num_expediente = expedientes_hojas_seguim.num_expediente
      and ec.num_hoja = expedientes_hojas_seguim.num_hoja
      and ec.empresa = expedientes_hojas_seguim.empresa
      and proveedor = ''
) ) )
   and ( '' is null
    or ( exists (
   select 1
     from con_impor co,
          expedientes_hojas_seguim_con ec
    where co.codigo = ec.concepto
      and co.tipo = 'DE'
      and co.codigo_empresa = ec.empresa
      and ec.num_expediente = expedientes_hojas_seguim.num_expediente
      and ec.num_hoja = expedientes_hojas_seguim.num_hoja
      and ec.empresa = expedientes_hojas_seguim.empresa
      and proveedor = ''
) ) )
   and ( '' is null
    or exists (
   select 1
     from expedientes_hojas_seguim_mov ec
    where ec.num_expediente = expedientes_hojas_seguim.num_expediente
      and ec.num_hoja = expedientes_hojas_seguim.num_hoja
      and ec.empresa = expedientes_hojas_seguim.empresa
      and num_carta_credito like ''
) )
   and ( '' is null
    or exists (
   select 1
     from expedientes_hojas_seguim_mov ec
    where ec.num_expediente = expedientes_hojas_seguim.num_expediente
      and ec.num_hoja = expedientes_hojas_seguim.num_hoja
      and ec.empresa = expedientes_hojas_seguim.empresa
      and num_bill_lading like ''
) )
   and ( '' is null
    or exists (
   select 1
     from expedientes_articulos_embarque ec
    where ec.num_expediente = expedientes_hojas_seguim.num_expediente
      and ec.num_hoja = expedientes_hojas_seguim.num_hoja
      and ec.empresa = expedientes_hojas_seguim.empresa
      and ec.lote like ''
) )
   and ( '' is null
    or exists (
   select 1
     from expedientes_hojas_seguim_mov ec
    where ec.num_expediente = expedientes_hojas_seguim.num_expediente
      and ec.num_hoja = expedientes_hojas_seguim.num_hoja
      and ec.empresa = expedientes_hojas_seguim.empresa
      and numero_booking like ''
) )
   and ( '' is null
    or exists (
   select 1
     from expedientes_hojas_seguim_mov ec
    where ec.num_expediente = expedientes_hojas_seguim.num_expediente
      and ec.num_hoja = expedientes_hojas_seguim.num_hoja
      and ec.empresa = expedientes_hojas_seguim.empresa
      and banco like ''
) )
   and ( '' is null
    or expedientes_hojas_seguim.numero_dua like ''
    or ( exists (
   select 1
     from expedientes_contenedores_docs ec
    where ec.num_expediente = expedientes_hojas_seguim.num_expediente
      and ec.num_hoja = expedientes_hojas_seguim.num_hoja
      and ec.empresa = expedientes_hojas_seguim.empresa
      and codigo_dua like ''
)
    or expedientes_imp.numero_dua like '' ) )
   and ( '' is null
    or exists (
   select 1
     from expedientes_hojas_seguim_mov ec
    where ec.num_expediente = expedientes_hojas_seguim.num_expediente
      and ec.num_hoja = expedientes_hojas_seguim.num_hoja
      and ec.empresa = expedientes_hojas_seguim.empresa
      and ec.cod_movimiento in (
      select col_value
        from table ( pktmp_select_in.split_cadena_vch2('') )
   )
) )
   and ( '' is null
    or not exists (
   select 1
     from expedientes_hojas_seguim_mov ec
    where ec.num_expediente = expedientes_hojas_seguim.num_expediente
      and ec.num_hoja = expedientes_hojas_seguim.num_hoja
      and ec.empresa = expedientes_hojas_seguim.empresa
      and ec.cod_movimiento in (
      select col_value
        from table ( pktmp_select_in.split_cadena_vch2('') )
   )
) )
   and ( '' is null
    or exists (
   select 1
     from albaran_compras_c ac
    where ac.numero_expediente = expedientes_hojas_seguim.num_expediente
      and ac.codigo_empresa = expedientes_hojas_seguim.empresa
      and ( ac.hoja_seguimiento is null
       or ac.hoja_seguimiento = expedientes_hojas_seguim.num_hoja )
      and ac.numero_doc_interno = ''
) )
   and ( '' is null
    or exists (
   select 1
     from facturas_compras_lin fc,
          albaran_compras_l al,
          albaran_compras_c ac
    where ac.numero_expediente = expedientes_hojas_seguim.num_expediente
      and ac.codigo_empresa = expedientes_hojas_seguim.empresa
      and ( ac.hoja_seguimiento is null
       or ac.hoja_seguimiento = expedientes_hojas_seguim.num_hoja )
      and al.numero_doc_interno = ac.numero_doc_interno
      and al.codigo_empresa = ac.codigo_empresa
      and fc.num_albaran_int = al.numero_doc_interno
      and fc.linea_albaran = al.numero_linea
      and fc.numero_factura = ''
      and fc.codigo_empresa = al.codigo_empresa
) )
   and ( '' is null
    or nvl(
   expedientes_hojas_seguim.proveedor,
   (
      select ei.proveedor
        from expedientes_imp ei
       where ei.codigo = expedientes_hojas_seguim.num_expediente
         and ei.empresa = expedientes_hojas_seguim.empresa
   )
) = '' )
   and ( ( '' is null
   and '' is null
   and '' is null
   and '' is null )
    or exists (
   select 1
     from pedidos_ventas pv
    where pv.empresa = expedientes_hojas_seguim.empresa
      and pv.numero_expediente = expedientes_hojas_seguim.num_expediente
      and ( pv.hoja_seguimiento is null
       or pv.hoja_seguimiento = expedientes_hojas_seguim.num_hoja )
      and ( pv.organizacion_comercial = ''
       or '' is null )
      and ( pv.ejercicio = ''
       or '' is null )
      and ( pv.numero_pedido = ''
       or '' is null )
      and ( pv.numero_serie = ''
       or '' is null )
      and nvl(
      pv.anulado,
      'N'
   ) = 'N'
) )
   and ( ( '' is null
   and '' is null
   and '' is null
   and '' is null )
    or exists (
   select 1
     from albaran_ventas pv
    where pv.empresa = expedientes_hojas_seguim.empresa
      and pv.numero_expediente = expedientes_hojas_seguim.num_expediente
      and ( pv.hoja_seguimiento is null
       or pv.hoja_seguimiento = expedientes_hojas_seguim.num_hoja )
      and ( pv.organizacion_comercial = ''
       or '' is null )
      and ( pv.ejercicio = ''
       or '' is null )
      and ( pv.numero_albaran = ''
       or '' is null )
      and ( pv.numero_serie = ''
       or '' is null )
      and nvl(
      pv.anulado,
      'N'
   ) = 'N'
) )
   and ( ( '' is null
   and '' is null
   and '' is null )
    or exists (
   select 1
     from albaran_ventas pv
    where pv.empresa = expedientes_hojas_seguim.empresa
      and pv.numero_expediente = expedientes_hojas_seguim.num_expediente
      and ( pv.hoja_seguimiento is null
       or pv.hoja_seguimiento = expedientes_hojas_seguim.num_hoja )
      and ( pv.ejercicio_factura = ''
       or '' is null )
      and ( pv.numero_factura = ''
       or '' is null )
      and ( pv.numero_serie_fra = ''
       or '' is null )
      and nvl(
      pv.anulado,
      'N'
   ) = 'N'
) )
   and ( '' is null
    or exists (
   select 1
     from expedientes_imp_agentes ea
    where ea.numero_expediente = expedientes_imp.codigo
      and ea.agente = ''
      and ea.empresa = expedientes_imp.empresa
) )
   and ( expedientes_hojas_seguim.status not in ( 'C' ) ) )
   and ( articulos.codigo_empresa = '001' )
   and ( expedientes_imp.empresa = '001' )
   and ( expedientes_hojas_seguim.empresa = '001' )
   and ( expedientes_articulos_embarque.empresa = '001' )
   and ( expedientes_contenedores.empresa = '001' )

   and expedientes_articulos_embarque.articulo = 40030
   and expedientes_hojas_seguim.num_expediente = 9;




-- ahora la consulta corta de caterina
select expedientes_articulos_embarque.articulo,
       expedientes_hojas_seguim.num_expediente,
       expedientes_hojas_seguim.num_hoja,
       expedientes_articulos_embarque.contenedor,
  -- expedientes_imp.forma_envio,
       expedientes_articulos_embarque.cantidad,
       (
          case
  -- Si la situación logística es '00', se realiza la operación de resta
             when exists (
                select 1
                  from expedientes_hojas_seguim h3
                 where expedientes_articulos_embarque.num_expediente = h3.num_expediente
                   and expedientes_articulos_embarque.num_hoja = h3.num_hoja
                   and h3.situacion_logistica = '00'
             ) then
                (
    -- Suma de las cantidades de las hojas de seguimiento donde la situación es '00'
                 (
                   select sum(h2.cantidad)
                     from expedientes_articulos_embarque h2
                    where expedientes_articulos_embarque.num_expediente = h2.num_expediente
                      and expedientes_articulos_embarque.articulo = h2.articulo
                      and exists (
                      select 1
                        from expedientes_hojas_seguim h3
                       where h2.num_expediente = h3.num_expediente
                         and h2.num_hoja = h3.num_hoja
                         and h3.situacion_logistica = '00'
                   )
                ) - (
      -- Resta de las cantidades de las hojas de seguimiento donde la situación no es '00'
                   select sum(h2.cantidad)
                     from expedientes_articulos_embarque h2
                    where expedientes_articulos_embarque.num_expediente = h2.num_expediente
                      and expedientes_articulos_embarque.articulo = h2.articulo
                      and exists (
                      select 1
                        from expedientes_hojas_seguim h3
                       where h2.num_expediente = h3.num_expediente
                         and h2.num_hoja = h3.num_hoja
                         and h3.situacion_logistica != '00'
                   )
                ) )
             else
    -- Si la situación no es '00', se devuelve la cantidad de expedientes_articulos_embarque
                expedientes_articulos_embarque.cantidad
          end
       ) as log_00,
       expedientes_articulos_embarque.presentacion as pres,
 -- expedientes_articulos_embarque.destino_especial,
 -- expedientes_articulos_embarque.deposito_aduanero,
       expedientes_articulos_embarque.precio,
       expedientes_articulos_embarque.importe,
       decode(
          nvl(
             expedientes_imp.valor_cambio,
             0
          ),
          0,
          expedientes_articulos_embarque.precio,
          expedientes_articulos_embarque.precio * expedientes_imp.valor_cambio
       ) coste_eur,
       coalesce(
          expedientes_hojas_seguim.valor_cambio,
          expedientes_imp.valor_cambio,
          1
       ) valor_cambio,
       expedientes_hojas_seguim.tipo_cambio,
 -- 1 / coalesce(EXPEDIENTES_HOJAS_SEGUIM.VALOR_CAMBIO, EXPEDIENTES_IMP.VALOR_CAMBIO,1) eur_usd,
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
       ) conste_s_g,
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
       ) ) ) conste_c_g_eur,
       expedientes_imp.d_clave_arancel as origen,
       expedientes_hojas_seguim.d_situacion_logistica,
       expedientes_hojas_seguim.documentacion_x_contenedor,
       expedientes_hojas_seguim.fecha_prev_llegada,
       expedientes_hojas_seguim.fecha_prev_embarque,
       expedientes_imp.d_plantilla,
       nvl(
          expedientes_hojas_seguim.proveedor,
          expedientes_imp.proveedor
       ) cod_prov,
       expedientes_hojas_seguim.d_proveedor_hoja proveedor_d,
       expedientes_imp.d_descripcion_expediente contrato,
       expedientes_hojas_seguim.codigo_entrada,
       expedientes_hojas_seguim.id_seguro_cambio,
        -- (select nombre from bancos b, Seguros_cambio c where b.codigo_rapido = c.banco and b.empresa = c.empresa and c.id = expedientes_hojas_seguim.id_seguro_cambio) nombre_bank,
       (
          select max(documento)
            from seguros_cambio c
           where c.id = expedientes_hojas_seguim.id_seguro_cambio
       ) as doc_seg_cam,
       (
          select sum(importe)
            from seguros_cambio c
           where c.id = expedientes_hojas_seguim.id_seguro_cambio
       ) as imorte_seguro,
       expedientes_hojas_seguim.carta_credito,
       (
          select max(fecha_vencimiento)
            from cartas_credito c
           where c.numero_carta_credito = expedientes_hojas_seguim.carta_credito
       ) venc_cart_cred,
       expedientes_hojas_seguim.status
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
                 (
                    select
                       listagg(ec.num_carta_credito,
                               ',') within group(
                        order by ec.num_carta_credito)
                      from expedientes_hojas_seguim_mov ec
                     where ec.num_expediente = expedientes_hojas_seguim.num_expediente
                       and ec.num_hoja = expedientes_hojas_seguim.num_hoja
                       and ec.empresa = expedientes_hojas_seguim.empresa
                 ) carta_credito
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
   and expedientes_hojas_seguim.status not in ( 'C XX' ) -- en C estan las OS que estan en el contrato
   
   

   and expedientes_hojas_seguim.num_expediente IN (308) -- 273, 260, 
  )
  order by expedientes_hojas_seguim.fecha_prev_llegada ASC, expedientes_hojas_seguim.num_expediente ASC
  ;



select * 
from expedientes_hojas_seguim
where '' is null
;
-- Listado de los articulos a recepcionar de los contenedores


SELECT cont.__cban, 
  lcc.__articulo____erp, 
  SUBSTR(lcc.__articulo____descripcion,1,45) AS __articulo____descripcion,
  cc.__cartacreditoproveedor____referencia,
  lcc.__contenedorcompra____referencia,
  cont.id,
  lcc.__peso,
  lcc.__precio,
  lcc.__cambiodivisa,
  lcc.__preciocongastos,
  lcc.__costeunitario,
  cc.__paisorigen, 
  IF(lcc.__contenedorcompra____referencia IS NULL, 'O', 'X') AS E, 
  IF(cont.__analitica IS NULL, 'O', 'X') AS A, 
  IF(cont.__documentado IS NULL, 'O', 'X') AS D, 
  IF(lcc.__cambioaseguado IS NULL, 'O', 'X') AS P, 
  DATE_FORMAT(lcc.__fechasalida,'%d/%m/%Y') AS __fechasalida, 
  DATE_FORMAT(lcc.__fechallegada,'%d/%m/%Y') AS __fechallegada,
  cc.__puertodestino,
  p.__erp,
  p.__business,
  cc.__contratoproveedor,
  cc.__doc,
  (SELECT MAX(__pedidocompra__id) FROM lineapedidocompra WHERE __lineacontratocompra__id = lcc.id) AS ped FROM lineacontratocompra lcc INNER 
  JOIN contratocompra cc ON cc.id = lcc.__contratocompra__id LEFT JOIN contenedorescompras cont ON cont.id = lcc.__contenedorcompra__id 
  LEFT JOIN proveedores p ON p.id = cc.__proveedor__id WHERE lcc.__state != 'completada' AND lcc.__articulo____erp &articulo 
    AND lcc.__fechallegada >= '&fechallegadaDesde' and lcc.__fechallegada <= '&fechallegadaHasta' AND p.__erp &proveedor 
    
    ORDER BY E DESC, lcc.__fechallegada, cc.id, cont.id, lcc.__articulo____erp;


  select expedientes_articulos_embarque.articulo,
                   (SELECT DESCRIP_COMERCIAL FROM ARTICULOS WHERE CODIGO_ARTICULO = expedientes_articulos_embarque.articulo AND ROWNUM = 1) AS DESCRIP_COMERCIAL,
                   expedientes_hojas_seguim.num_expediente,
                   expedientes_hojas_seguim.num_hoja,
                   expedientes_articulos_embarque.contenedor,
              -- expedientes_imp.forma_envio,
                   expedientes_articulos_embarque.cantidad,
                   (
                      case
              -- Si la situación logística es '00', se realiza la operación de resta
                         when exists (
                            select 1
                              from expedientes_hojas_seguim h3
                             where expedientes_articulos_embarque.num_expediente = h3.num_expediente
                               and expedientes_articulos_embarque.num_hoja = h3.num_hoja
                               and h3.situacion_logistica = '00'
                         ) then
                            (
                -- Suma de las cantidades de las hojas de seguimiento donde la situación es '00'
                             (
                               select sum(h2.cantidad)
                                 from expedientes_articulos_embarque h2
                                where expedientes_articulos_embarque.num_expediente = h2.num_expediente
                                  and expedientes_articulos_embarque.articulo = h2.articulo
                                  and exists (
                                  select 1
                                    from expedientes_hojas_seguim h3
                                   where h2.num_expediente = h3.num_expediente
                                     and h2.num_hoja = h3.num_hoja
                                     and h3.situacion_logistica = '00'
                               )
                            ) - (
                  -- Resta de las cantidades de las hojas de seguimiento donde la situación no es '00'
                               select sum(h2.cantidad)
                                 from expedientes_articulos_embarque h2
                                where expedientes_articulos_embarque.num_expediente = h2.num_expediente
                                  and expedientes_articulos_embarque.articulo = h2.articulo
                                  and exists (
                                  select 1
                                    from expedientes_hojas_seguim h3
                                   where h2.num_expediente = h3.num_expediente
                                     and h2.num_hoja = h3.num_hoja
                                     and h3.situacion_logistica != '00'
                               )
                            ) )
                         else
                -- Si la situación no es '00', se devuelve la cantidad de expedientes_articulos_embarque
                            expedientes_articulos_embarque.cantidad
                      end
                   ) as log_00,
                   expedientes_articulos_embarque.presentacion as pres,
             -- expedientes_articulos_embarque.destino_especial,
             -- expedientes_articulos_embarque.deposito_aduanero,
                   expedientes_articulos_embarque.precio,
                   expedientes_articulos_embarque.importe,
                   decode(
                      nvl(
                         expedientes_imp.valor_cambio,
                         0
                      ),
                      0,
                      expedientes_articulos_embarque.precio,
                      expedientes_articulos_embarque.precio * expedientes_imp.valor_cambio
                   ) coste_eur,
                   coalesce(
                      expedientes_hojas_seguim.valor_cambio,
                      expedientes_imp.valor_cambio,
                      1
                   ) valor_cambio,
                   expedientes_hojas_seguim.tipo_cambio,
             -- 1 / coalesce(EXPEDIENTES_HOJAS_SEGUIM.VALOR_CAMBIO, EXPEDIENTES_IMP.VALOR_CAMBIO,1) eur_usd,
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
                   ) conste_s_g,
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
                   ) ) ) conste_c_g_eur,
                   expedientes_imp.d_clave_arancel as origen,
                   expedientes_hojas_seguim.d_situacion_logistica,
                   expedientes_hojas_seguim.documentacion_x_contenedor,
                   expedientes_hojas_seguim.fecha_prev_llegada,
                   expedientes_hojas_seguim.fecha_prev_embarque,
                   expedientes_imp.d_plantilla,
                   nvl(
                      expedientes_hojas_seguim.proveedor,
                      expedientes_imp.proveedor
                   ) cod_prov,
                   expedientes_hojas_seguim.d_proveedor_hoja proveedor_d,
                   expedientes_imp.d_descripcion_expediente contrato,
                   expedientes_hojas_seguim.codigo_entrada,
                   expedientes_hojas_seguim.id_seguro_cambio,
                    -- (select nombre from bancos b, Seguros_cambio c where b.codigo_rapido = c.banco and b.empresa = c.empresa and c.id = expedientes_hojas_seguim.id_seguro_cambio) nombre_bank,
                   (
                      select max(documento)
                        from seguros_cambio c
                       where c.id = expedientes_hojas_seguim.id_seguro_cambio
                   ) as doc_seg_cam,
                   (
                      select sum(importe)
                        from seguros_cambio c
                       where c.id = expedientes_hojas_seguim.id_seguro_cambio
                   ) as imorte_seguro,
                   expedientes_hojas_seguim.carta_credito,
                   (
                      select max(fecha_vencimiento)
                        from cartas_credito c
                       where c.numero_carta_credito = expedientes_hojas_seguim.carta_credito
                   ) venc_cart_cred,
                   expedientes_hojas_seguim.status
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
                             (
                                select
                                   listagg(ec.num_carta_credito,
                                           ',') within group(
                                    order by ec.num_carta_credito)
                                  from expedientes_hojas_seguim_mov ec
                                 where ec.num_expediente = expedientes_hojas_seguim.num_expediente
                                   and ec.num_hoja = expedientes_hojas_seguim.num_hoja
                                   and ec.empresa = expedientes_hojas_seguim.empresa
                             ) carta_credito
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
             where  expedientes_contenedores.num_expediente = expedientes_articulos_embarque.num_expediente
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

               -- and expedientes_hojas_seguim.status not in ( 'C' ) -- en C estan las OS que estan en el contrato
               -- and expedientes_hojas_seguim.codigo_entrada IS NULL
               -- and expedientes_articulos_embarque.articulo = 40030
               AND expedientes_hojas_seguim.num_expediente IN (319)
               ;


select *
from expedientes_hojas_seguim --.codigo_entrada
;

select * 
from expedientes_articulos_embarque
;

40786

SELECT              CODIGO_ARTICULO,
                    V_CODIGO_ALMACEN,
                    D_CODIGO_ALMACEN,
                    V_TIPO_SITUACION,
                    V_CANTIDAD_PRESENTACION,
                    V_PRESENTACION
                FROM 
                (
                    SELECT  s.* , 
                        CANTIDAD_PRESENTACION V_CANTIDAD_PRESENTACION,
                        CODIGO_ALMACEN V_CODIGO_ALMACEN,
                        PRESENTACION V_PRESENTACION,
                        STOCK_UNIDAD1 V_STOCK_UNIDAD1,
                        TIPO_SITUACION V_TIPO_SITUACION 
                    FROM 
                        (
                            SELECT codigo_empresa, 
                            codigo_almacen,
                            (SELECT a.nombre FROM almacenes a WHERE a.almacen = s.codigo_almacen AND a.codigo_empresa = s.codigo_empresa) d_codigo_almacen, 
                            codigo_articulo, 
                            tipo_situacion, 
                            presentacion, 
                            SUM(cantidad_unidad1) stock_unidad1,
                            SUM(NVL(cantidad_presentacion, 0)) cantidad_presentacion
                            FROM stocks_detallado s  
                            WHERE NOT EXISTS 
                                (SELECT 1
                                FROM almacenes_zonas az
                                WHERE az.codigo_empresa = s.codigo_empresa
                                       AND az.codigo_almacen = s.codigo_almacen
                                       AND az.codigo_zona = s.codigo_zona
                                       AND az.es_zona_reserva_virtual = 'S') 
                                GROUP BY codigo_empresa, codigo_almacen, codigo_articulo, tipo_situacion, presentacion
                        ) s 
                )  s WHERE (NVL(stock_unidad1, 0) != 0) ;




SELECT  SUBSTR(articulos.d_codigo_familia,1,20) c1,
        SUBSTR(articulos.d_codigo_estad2,1,20) c2,
        SUBSTR(v_froxa_stocks_nacional.codigo_almacen,1,5) c3,
        articulos.codigo_familia c4,
        articulos.codigo_estad2 c5,
        v_froxa_stocks_nacional.cliente c6,
        SUBSTR(v_froxa_stocks_nacional.codigo_articulo,1,12) c7,
        SUBSTR(v_froxa_stocks_nacional.descrip_comercial,1,25) c8,
        v_froxa_stocks_nacional.cantidad_dis n1,
        v_froxa_stocks_nacional.cantidad_sob n2,
        v_froxa_stocks_nacional.cantidad_con n3,(SELECT 
    MAX(av.precio_standard)
FROM 
    articulos_valoracion av
WHERE 
    av.codigo_empresa(+) = V_FROXA_STOCKS_NACIONAL.codigo_empresa
    AND av.codigo_articulo(+) = V_FROXA_STOCKS_NACIONAL.codigo_articulo    
    -- AND av.codigo_almacen(+) = '00'
    AND av.ejercicio = (
        SELECT MAX(av2.ejercicio)
        FROM articulos_valoracion av2
        WHERE av2.codigo_empresa(+) = V_FROXA_STOCKS_NACIONAL.codigo_empresa
          AND av2.codigo_articulo(+) = V_FROXA_STOCKS_NACIONAL.codigo_articulo
          -- AND av2.codigo_almacen(+) = '00'
    )
) n4,v_froxa_stocks_nacional.precio_medio_ponderado n5,v_froxa_stocks_nacional.valor_pmp n6,v_froxa_stocks_nacional.ultimo_precio_compra n7,v_froxa_stocks_nacional.valor_upc n8,v_froxa_stocks_nacional.precio_consumo n9,v_froxa_stocks_nacional.margen_pvp n10,v_froxa_stocks_nacional.valor_pvp n11,v_froxa_stocks_nacional.margen_unitario n12,NULL gi$color   FROM V_FROXA_STOCKS_NACIONAL,(SELECT ARTICULOS.*,DECODE(articulos.codigo_familia,NULL,NULL,(SELECT lvfm.descripcion FROM familias lvfm WHERE lvfm.codigo_familia = articulos.codigo_familia AND lvfm.numero_tabla = 1 AND lvfm.codigo_empresa = articulos.codigo_empresa)) D_CODIGO_FAMILIA,DECODE(articulos.codigo_estad2,NULL,NULL,(SELECT lvfm.descripcion FROM familias lvfm WHERE lvfm.codigo_familia = articulos.codigo_estad2 AND lvfm.numero_tabla = 2 AND lvfm.codigo_empresa = articulos.codigo_empresa)) D_CODIGO_ESTAD2 FROM ARTICULOS) ARTICULOS WHERE (V_FROXA_STOCKS_NACIONAL.CODIGO_EMPRESA= '001' and V_FROXA_STOCKS_NACIONAL.CODIGO_EMPRESA=ARTICULOS.CODIGO_EMPRESA and V_FROXA_STOCKS_NACIONAL.CODIGO_ARTICULO=ARTICULOS.CODIGO_ARTICULO) 
AND v_froxa_stocks_nacional.cliente LIKE '999999%' 
AND v_froxa_stocks_nacional.codigo_articulo IN ('40295')  ORDER BY  1,2,3,4,5,8;



    SELECT  
        (SELECT descripcion 
        FROM familias where numero_tabla = '7' AND codigo_familia = (
        SELECT a.codigo_estad7 
        FROM ARTICULOS a 
        WHERE a.CODIGO_ARTICULO = articulos.CODIGO_ARTICULO AND ROWNUM = 1
        )) AS tipo_consumo_articulo,
        (select descripcion from familias where numero_tabla = '8' AND codigo_familia = articulos.codigo_estad8 AND codigo_empresa = '001') d_codigo_estad8,
        SUBSTR(articulos.d_codigo_familia,1,20) AS FAMILIA,
        SUBSTR(articulos.d_codigo_estad2,1,20) AS SUBFAMILIA,
        (v_froxa_stocks_nacional.codigo_almacen || ' ' || (SELECT NOMBRE FROM ALMACENES WHERE ALMACEN = v_froxa_stocks_nacional.codigo_almacen AND ROWNUM = 1)) AS ALMACEN,
        articulos.codigo_familia AS CODIGO_FAMILIA,
        articulos.codigo_estad2 AS CODIGO_SUBFAMILIA,
        v_froxa_stocks_nacional.cliente AS CLIENTE,
        SUBSTR(v_froxa_stocks_nacional.codigo_articulo,1,12) AS CODIGO_ARTICULO,
        SUBSTR(v_froxa_stocks_nacional.descrip_comercial,1,25) AS NOMBRE_ARTICULO,
        v_froxa_stocks_nacional.descrip_comercial || ' ' || v_froxa_stocks_nacional.codigo_articulo AS NOMBRE_COMPLETO,
        v_froxa_stocks_nacional.cantidad_dis AS CAJAS,
        v_froxa_stocks_nacional.cantidad_sob AS UNIDADES,
        v_froxa_stocks_nacional.cantidad_con AS KILOS,
        (SELECT MAX(av.precio_standard) 
            FROM articulos_valoracion av WHERE av.codigo_empresa(+) = V_FROXA_STOCKS_NACIONAL.codigo_empresa AND av.codigo_articulo(+) = V_FROXA_STOCKS_NACIONAL.codigo_articulo AND av.codigo_almacen(+) = '00' AND av.ejercicio = (
                SELECT MAX(av2.ejercicio) FROM articulos_valoracion av2 WHERE av2.codigo_empresa(+) = V_FROXA_STOCKS_NACIONAL.codigo_empresa AND av2.codigo_articulo(+) = V_FROXA_STOCKS_NACIONAL.codigo_articulo AND av2.codigo_almacen(+) = '00' )
        ) AS precio_standard,
        v_froxa_stocks_nacional.precio_medio_ponderado AS precio_medio_ponderado,
        v_froxa_stocks_nacional.valor_pmp as valor_pmp,
        v_froxa_stocks_nacional.ultimo_precio_compra AS ultimo_precio_compra,
        v_froxa_stocks_nacional.valor_upc AS valor_upc,
        v_froxa_stocks_nacional.precio_consumo AS precio_consumo,
        v_froxa_stocks_nacional.margen_pvp AS margen_pvp,
        v_froxa_stocks_nacional.valor_pvp AS valor_pvp,
        v_froxa_stocks_nacional.margen_unitario AS margen_unitario   
        FROM V_FROXA_STOCKS_NACIONAL,
        (SELECT ARTICULOS.*, DECODE(articulos.codigo_familia,NULL,NULL,
                                (SELECT lvfm.descripcion FROM familias lvfm WHERE lvfm.codigo_familia = articulos.codigo_familia AND lvfm.numero_tabla = 1 AND lvfm.codigo_empresa = articulos.codigo_empresa)) D_CODIGO_FAMILIA,
                            DECODE(articulos.codigo_estad2,NULL,NULL,
                                (SELECT lvfm.descripcion FROM familias lvfm WHERE lvfm.codigo_familia = articulos.codigo_estad2 AND lvfm.numero_tabla = 2 AND lvfm.codigo_empresa = articulos.codigo_empresa)) D_CODIGO_ESTAD2 
            FROM ARTICULOS) ARTICULOS 
            WHERE (V_FROXA_STOCKS_NACIONAL.CODIGO_EMPRESA= '001' and V_FROXA_STOCKS_NACIONAL.CODIGO_EMPRESA=ARTICULOS.CODIGO_EMPRESA and V_FROXA_STOCKS_NACIONAL.CODIGO_ARTICULO=ARTICULOS.CODIGO_ARTICULO) 
                AND (articulos.codigo_empresa = '001') 
                AND v_froxa_stocks_nacional.codigo_almacen IN ('00','02','80','98') 
                AND v_froxa_stocks_nacional.cliente LIKE '999999%'
                AND v_froxa_stocks_nacional.codigo_articulo IN ('40074');



-- !!! 10-inventario !!!
  SELECT  
        SUBSTR(articulos.d_codigo_familia,1,20) AS FAMILIA,
        SUBSTR(articulos.d_codigo_estad2,1,20) AS SUBFAMILIA,
        (v_froxa_stocks_nacional.codigo_almacen || ' ' || (SELECT NOMBRE FROM ALMACENES WHERE ALMACEN = v_froxa_stocks_nacional.codigo_almacen AND ROWNUM = 1)) AS ALMACEN,
        v_froxa_stocks_nacional.descrip_comercial || ' ' || v_froxa_stocks_nacional.codigo_articulo AS NOMBRE_COMPLETO,
        v_froxa_stocks_nacional.cantidad_dis AS CAJAS,
        v_froxa_stocks_nacional.cantidad_sob AS UNIDADES,
        v_froxa_stocks_nacional.cantidad_con AS KILOS,
        (SELECT MAX(av.precio_standard) 
            FROM articulos_valoracion av WHERE av.codigo_empresa(+) = V_FROXA_STOCKS_NACIONAL.codigo_empresa AND av.codigo_articulo(+) = V_FROXA_STOCKS_NACIONAL.codigo_articulo 
                AND av.codigo_almacen(+) = '00' 
                AND av.ejercicio = (
                  SELECT MAX(av2.ejercicio) FROM articulos_valoracion av2 WHERE av2.codigo_empresa(+) = V_FROXA_STOCKS_NACIONAL.codigo_empresa AND av2.codigo_articulo(+) = V_FROXA_STOCKS_NACIONAL.codigo_articulo 
                    AND av2.codigo_almacen(+) = '00' 
                )
        ) AS precio_standard,
        v_froxa_stocks_nacional.precio_medio_ponderado AS precio_medio_ponderado,
        v_froxa_stocks_nacional.valor_pmp as valor_pmp,
        v_froxa_stocks_nacional.ultimo_precio_compra AS ultimo_precio_compra,
        v_froxa_stocks_nacional.valor_upc AS valor_upc
        FROM V_FROXA_STOCKS_NACIONAL,
        (SELECT ARTICULOS.*, DECODE(articulos.codigo_familia,NULL,NULL,
                                (SELECT lvfm.descripcion FROM familias lvfm WHERE lvfm.codigo_familia = articulos.codigo_familia AND lvfm.numero_tabla = 1 AND lvfm.codigo_empresa = articulos.codigo_empresa)) D_CODIGO_FAMILIA,
                            DECODE(articulos.codigo_estad2,NULL,NULL,
                                (SELECT lvfm.descripcion FROM familias lvfm WHERE lvfm.codigo_familia = articulos.codigo_estad2 AND lvfm.numero_tabla = 2 AND lvfm.codigo_empresa = articulos.codigo_empresa)) D_CODIGO_ESTAD2 
            FROM ARTICULOS) ARTICULOS 
            WHERE (V_FROXA_STOCKS_NACIONAL.CODIGO_EMPRESA= '001' and V_FROXA_STOCKS_NACIONAL.CODIGO_EMPRESA=ARTICULOS.CODIGO_EMPRESA and V_FROXA_STOCKS_NACIONAL.CODIGO_ARTICULO=ARTICULOS.CODIGO_ARTICULO) 
                AND (articulos.codigo_empresa = '001') 
                AND v_froxa_stocks_nacional.codigo_almacen IN ('00','02','80','98') 
                AND v_froxa_stocks_nacional.cliente LIKE '999999%'
                AND v_froxa_stocks_nacional.codigo_articulo = 40295
                ;


SELECT st.almacen_valoracion, 
      st.codigo_articulo, 
      st.descrip_comercial, 
      st.pmp, 
      st.upc,
      st.cantidad_dis, 
      st.cantidad_sob, 
      st.cantidad_con,
      ROUND(st.pmp * st.cantidad_valoracion, st.decimales_significativos) AS valor_pmp,
      ROUND(st.upc * st.cantidad_valoracion, st.decimales_significativos) AS valor_upc, 
      st.pvp,
      ROUND(st.pvp * st.cantidad_valoracion, st.decimales_significativos) valor_pvp
  FROM (
    SELECT dt.codigo_empresa, 
            dt.almacen_valoracion, 
            dt.codigo_articulo, 
            dt.tipo_cadena_logistica,
            dt.descrip_comercial, 
            dt.divisa_empresa, 
            dt.codigo_cliente,
                (SELECT DECODE(NVL(null, 'CON'), 'CON',
                 pl.precio_consumo, 'SOB', pl.precio_sobreembal)
                    FROM precios_listas pl
                   WHERE pl.codigo_empresa = dt.codigo_empresa
                     AND pl.codigo_articulo = dt.codigo_articulo
                     AND pl.tipo_cadena = dt.tipo_cadena_logistica
                     AND pl.divisa = dt.divisa_empresa
                     AND pl.organizacion_comercial = '001'
                     AND pl.numero_lista = pkpantallas.get_variable_env_varchar2('COD_LISTA')
                     AND pl.fecha_validez = (SELECT MAX(pl2.fecha_validez)
                                               FROM precios_listas pl2
                                              WHERE pl2.codigo_empresa = pl.codigo_empresa
                                                AND pl2.codigo_articulo = pl.codigo_articulo
                                                AND pl2.organizacion_comercial = pl.organizacion_comercial
                                                AND pl2.tipo_cadena = pl.tipo_cadena
                                                AND pl2.divisa = pl.divisa
                                                AND pl2.numero_lista = pl.numero_lista
                                                AND pl2.fecha_validez <= TRUNC(f_current_date))) pvp,
                                                dt.cantidad_con, dt.cantidad_sob, dt.cantidad_dis,
                pkcostes.precio_coste(dt.codigo_empresa, dt.almacen_valoracion, dt.codigo_articulo, NULL, NULL, dt.divisa_empresa,
                TRUNC(f_current_date), EXTRACT(YEAR FROM TRUNC(f_current_date)),
                                       dt.fecha_ult_cierre, 2, 'S', dt.decimales_precios) *
                 DECODE(NVL(pkpantallas.get_variable_env_varchar2('PRESENTACION_PVP'), 'CON'), 'CON', 1, 'SOB', dt.convers_u_sob) pmp,
                pkcostes.precio_coste(dt.codigo_empresa, dt.almacen_valoracion, dt.codigo_articulo, NULL, NULL, dt.divisa_empresa,
                TRUNC(f_current_date), EXTRACT(YEAR FROM TRUNC(f_current_date)),
                                       dt.fecha_ult_cierre, 1, 'S', dt.decimales_precios) *
                 DECODE(NVL(pkpantallas.get_variable_env_varchar2('PRESENTACION_PVP'), 'CON'), 'CON', 1, 'SOB', dt.convers_u_sob) upc,
                  dt.decimales_significativos,
                DECODE(NVL(pkpantallas.get_variable_env_varchar2('PRESENTACION_PVP'), 'CON'), 'CON',
                dt.cantidad_con, 'SOB', dt.cantidad_sob) cantidad_valoracion
           FROM (SELECT sc.codigo_empresa, sc.codigo_articulo, ar.tipo_cadena_logistica, ar.descrip_comercial, ec.divisa divisa_empresa,
                         pkalmutil.f_almacen_valoracion(p_empresa => sc.codigo_empresa, p_almacen => sc.codigo_almacen) almacen_valoracion,
                          sc.codigo_cliente, SUM(sc.cantidad_sob) cantidad_sob,
                         SUM(sc.cantidad_con) cantidad_con, SUM(sc.cantidad_dis) cantidad_dis, al.fecha_ult_cierre, di.decimales_precios,
                         di.decimales_significativos, cd.convers_u_sob
                    FROM cadena_logistica cd, divisas di, al_param01 al, empresas_conta ec, articulos ar, stocks_deposito_cli sc
                   WHERE sc.cantidad_unidad1 != 0
                     AND ec.codigo = sc.codigo_empresa
                     AND di.codigo = ec.divisa
                     AND (pkpantallas.get_variable_env_varchar2('GRUPO_SITUACION') IS NULL OR EXISTS
                          (SELECT 1
                             FROM detalles_situacion_stock dx
                            WHERE dx.tipo_situacion = sc.tipo_situacion
                              AND dx.codigo_grupo = pkpantallas.get_variable_env_varchar2('GRUPO_SITUACION')
                              AND dx.codigo_empresa = sc.codigo_empresa))
                     AND (pkpantallas.get_variable_env_varchar2('ALMACEN') IS NULL OR
                         sc.codigo_almacen IN (SELECT col_value
                                                  FROM TABLE(pktmp_select_in.split_cadena_vch2(pkpantallas.get_variable_env_varchar2('ALMACEN')))))
                     AND al.codigo_empresa = sc.codigo_empresa
                     AND ar.codigo_articulo = sc.codigo_articulo
                     AND ar.codigo_empresa = sc.codigo_empresa
                     AND cd.codigo_articulo = ar.codigo_articulo
                     AND cd.tipo_cadena = ar.tipo_cadena_logistica
                     AND cd.codigo_empresa = ar.codigo_empresa
                     -- AND st.codigo_articulo = 40295
                   GROUP BY sc.codigo_empresa, sc.codigo_articulo, ar.tipo_cadena_logistica, ar.descrip_comercial, ec.divisa,
                    sc.codigo_cliente, al.fecha_ult_cierre, di.decimales_precios,
                            di.decimales_significativos, pkalmutil.f_almacen_valoracion(p_empresa => sc.codigo_empresa,
                             p_almacen => sc.codigo_almacen), cd.convers_u_sob) dt) st;


SELECT  SUBSTR(articulos.d_codigo_familia,1,20) c1,
SUBSTR(articulos.d_codigo_estad2,1,20) c2,
SUBSTR(v_froxa_stocks_nacional.codigo_almacen,1,5) c3,
articulos.codigo_familia c4,articulos.codigo_estad2 c5,
v_froxa_stocks_nacional.cliente c6,
SUBSTR(v_froxa_stocks_nacional.codigo_articulo,1,12) c7,
SUBSTR(v_froxa_stocks_nacional.descrip_comercial,1,25) c8,
v_froxa_stocks_nacional.cantidad_dis n1,
v_froxa_stocks_nacional.cantidad_sob n2,
v_froxa_stocks_nacional.cantidad_con n3,
  (SELECT  MAX(av.precio_standard) FROM articulos_valoracion av WHERE 
    av.codigo_empresa(+) = V_FROXA_STOCKS_NACIONAL.codigo_empresa
    AND av.codigo_articulo(+) = V_FROXA_STOCKS_NACIONAL.codigo_articulo    
    AND av.codigo_almacen(+) = '00'
    AND av.ejercicio = (
        SELECT MAX(av2.ejercicio)
        FROM articulos_valoracion av2
        WHERE av2.codigo_empresa(+) = V_FROXA_STOCKS_NACIONAL.codigo_empresa
          AND av2.codigo_articulo(+) = V_FROXA_STOCKS_NACIONAL.codigo_articulo
          AND av2.codigo_almacen(+) = '00'
    )
) n4,v_froxa_stocks_nacional.precio_medio_ponderado n5,v_froxa_stocks_nacional.valor_pmp n6,v_froxa_stocks_nacional.ultimo_precio_compra n7,v_froxa_stocks_nacional.valor_upc n8,v_froxa_stocks_nacional.precio_consumo n9,v_froxa_stocks_nacional.margen_pvp n10,v_froxa_stocks_nacional.valor_pvp n11,v_froxa_stocks_nacional.margen_unitario n12,NULL gi$color   FROM V_FROXA_STOCKS_NACIONAL,(SELECT ARTICULOS.*,DECODE(articulos.codigo_familia,NULL,NULL,(SELECT lvfm.descripcion FROM familias lvfm WHERE lvfm.codigo_familia = articulos.codigo_familia AND lvfm.numero_tabla = 1 AND lvfm.codigo_empresa = articulos.codigo_empresa)) D_CODIGO_FAMILIA,DECODE(articulos.codigo_estad2,NULL,NULL,(SELECT lvfm.descripcion FROM familias lvfm WHERE lvfm.codigo_familia = articulos.codigo_estad2 AND lvfm.numero_tabla = 2 AND lvfm.codigo_empresa = articulos.codigo_empresa)) D_CODIGO_ESTAD2 FROM ARTICULOS) ARTICULOS WHERE (V_FROXA_STOCKS_NACIONAL.CODIGO_EMPRESA= '001' and V_FROXA_STOCKS_NACIONAL.CODIGO_EMPRESA=ARTICULOS.CODIGO_EMPRESA and V_FROXA_STOCKS_NACIONAL.CODIGO_ARTICULO=ARTICULOS.CODIGO_ARTICULO) AND (articulos.codigo_empresa = '001') AND v_froxa_stocks_nacional.cliente LIKE '999999%'  ORDER BY  1,2,3,4,5,8;



004 CEPALOPODOS
028 POTON
      176 PS
  hay 183 PS BOCADITOS
  PS TIRA ANDALUZA


  10 UPC ponderado * 10-2 cantidad


070 TIRA ANDALUZA


059 RABAS
080 POTON

SELECT  SUBSTR(articulos.codigo_familia,1,15) c1,SUBSTR(articulos.d_codigo_familia,1,40) c2,SUBSTR(expedientes_articulos_embarque.articulo,1,15) c3,SUBSTR(expedientes_articulos_embarque.d_articulo,1,50) c4,expedientes_hojas_seguim.num_expediente n1,expedientes_hojas_seguim.num_hoja n2,SUBSTR(expedientes_articulos_embarque.contenedor,1,20) c5,SUBSTR(expedientes_imp.forma_envio,1,4) c6,expedientes_articulos_embarque.cantidad n3,(CASE
  -- Si la situación logística es '00', se realiza la operación de resta
  WHEN EXISTS (
    SELECT 1 
    FROM EXPEDIENTES_HOJAS_SEGUIM h3
    WHERE expedientes_articulos_embarque.num_expediente = h3.num_expediente
      AND expedientes_articulos_embarque.num_hoja = h3.num_hoja
      AND h3.situacion_logistica = '00'
  )
  THEN
  (
    -- Suma de las cantidades de las hojas de seguimiento donde la situación es '00'
    (
      SELECT SUM(h2.cantidad) 
      FROM expedientes_articulos_embarque h2
      WHERE expedientes_articulos_embarque.num_expediente = h2.num_expediente
        AND expedientes_articulos_embarque.articulo = h2.articulo
        AND EXISTS (
            SELECT 1 
            FROM EXPEDIENTES_HOJAS_SEGUIM h3
            WHERE h2.num_expediente = h3.num_expediente
              AND h2.num_hoja = h3.num_hoja
              AND h3.situacion_logistica = '00'
        )
    )
    -
    (
      -- Resta de las cantidades de las hojas de seguimiento donde la situación no es '00'
      SELECT SUM(h2.cantidad) 
      FROM expedientes_articulos_embarque h2
      WHERE expedientes_articulos_embarque.num_expediente = h2.num_expediente
        AND expedientes_articulos_embarque.articulo = h2.articulo
        AND EXISTS (
            SELECT 1 
            FROM EXPEDIENTES_HOJAS_SEGUIM h3
            WHERE h2.num_expediente = h3.num_expediente
              AND h2.num_hoja = h3.num_hoja
              AND h3.situacion_logistica != '00'
        )
    )
  )
  ELSE
    -- Si la situación no es '00', se devuelve la cantidad de expedientes_articulos_embarque
    expedientes_articulos_embarque.cantidad
END
)
 c7,SUBSTR(expedientes_articulos_embarque.presentacion,1,5) c8,SUBSTR(expedientes_articulos_embarque.destino_especial,1,1) c9,SUBSTR(expedientes_articulos_embarque.deposito_aduanero,1,1) c10,expedientes_articulos_embarque.precio n4,expedientes_articulos_embarque.importe n5,DECODE(NVL(EXPEDIENTES_IMP.VALOR_CAMBIO,0) , 0, expedientes_articulos_embarque.precio , expedientes_articulos_embarque.precio * EXPEDIENTES_IMP.VALOR_CAMBIO) n6,coalesce(EXPEDIENTES_HOJAS_SEGUIM.VALOR_CAMBIO, EXPEDIENTES_IMP.VALOR_CAMBIO,1) n7,SUBSTR(expedientes_hojas_seguim.tipo_cambio,1,1) c11,1 / coalesce(EXPEDIENTES_HOJAS_SEGUIM.VALOR_CAMBIO, EXPEDIENTES_IMP.VALOR_CAMBIO,1) n8,DECODE(coalesce(EXPEDIENTES_HOJAS_SEGUIM.VALOR_CAMBIO, EXPEDIENTES_IMP.VALOR_CAMBIO,1), 
       0, expedientes_articulos_embarque.precio, 
       expedientes_articulos_embarque.precio * coalesce(EXPEDIENTES_HOJAS_SEGUIM.VALOR_CAMBIO, EXPEDIENTES_IMP.VALOR_CAMBIO,1)) n9,(((SELECT SUM(hs.importe_portes) FROM reparto_portes_hs hs WHERE hs.codigo_empresa = expedientes_hojas_seguim.empresa AND hs.numero_expediente = expedientes_hojas_seguim.num_expediente AND hs.hoja_seguimiento = expedientes_hojas_seguim.num_hoja 
     and hs.codigo_articulo = expedientes_articulos_embarque.articulo) / DECODE(articulos.unidad_valoracion, 1, expedientes_articulos_embarque.cantidad_unidad1, 2, expedientes_articulos_embarque.cantidad_unidad2)) + (expedientes_articulos_embarque.precio *
        DECODE(expedientes_hojas_seguim.tipo_cambio, 'E', DECODE(expedientes_imp.cambio_asegurado, 'S', expedientes_imp.valor_cambio, 'N', 1), 'S', expedientes_hojas_seguim.valor_cambio, 'N',coalesce(EXPEDIENTES_HOJAS_SEGUIM.VALOR_CAMBIO, EXPEDIENTES_IMP.VALOR_CAMBIO,1)))) n10,SUBSTR(expedientes_imp.d_clave_arancel,1,30) c12,SUBSTR(expedientes_hojas_seguim.d_situacion_logistica,1,40) c13,SUBSTR(expedientes_hojas_seguim.documentacion_x_contenedor,1,5) c14,expedientes_hojas_seguim.fecha_prev_llegada c15,expedientes_hojas_seguim.fecha_prev_embarque c16,SUBSTR(expedientes_imp.d_plantilla,1,30) c17,NVL(EXPEDIENTES_HOJAS_SEGUIM.PROVEEDOR,EXPEDIENTES_IMP.PROVEEDOR) c18,SUBSTR(expedientes_hojas_seguim.d_proveedor_hoja,1,40) c19,SUBSTR(expedientes_imp.d_descripcion_expediente,1,50) c20,SUBSTR(expedientes_hojas_seguim.codigo_entrada,1,15) c21,expedientes_hojas_seguim.id_seguro_cambio n11,(select nombre from bancos b, Seguros_cambio c
        where b.codigo_rapido = c.banco
        and b.empresa = c.empresa
        and c.id = expedientes_hojas_seguim.id_seguro_cambio) c22,(SELECT MAX(DOCUMENTO) FROM SEGUROS_CAMBIO c WHERE c.ID = expedientes_hojas_seguim.id_seguro_cambio) c23,(select SUM(IMPORTE) from  Seguros_cambio c
        where  c.id = expedientes_hojas_seguim.id_seguro_cambio) c24,SUBSTR(expedientes_hojas_seguim.carta_credito,1,50) c25,(SELECT MAX(FECHA_VENCIMIENTO) FROM CARTAS_CREDITO C
WHERE C.NUMERO_CARTA_CREDITO = expedientes_hojas_seguim.CARTA_CREDITO
) c26,CASE WHEN EXPEDIENTES_HOJAS_SEGUIM.D_SITUACION_LOGISTICA ='CONTRATO' THEN '0:AMARILLO' ELSE '0:LIMA' END gi$color   FROM (SELECT ARTICULOS.*,DECODE(articulos.codigo_familia,NULL,NULL,(SELECT lvfm.descripcion FROM familias lvfm WHERE lvfm.codigo_familia = articulos.codigo_familia AND lvfm.numero_tabla = 1 AND lvfm.codigo_empresa = articulos.codigo_empresa)) D_CODIGO_FAMILIA FROM ARTICULOS) ARTICULOS,(SELECT EXPEDIENTES_IMP.*,DECODE(expedientes_imp.clave_arancel,NULL,NULL,(SELECT lvarimp.descripcion FROM aranceles_imp lvarimp WHERE lvarimp.clave_arancel = expedientes_imp.clave_arancel AND lvarimp.codigo_empresa = expedientes_imp.empresa)) D_CLAVE_ARANCEL,DECODE(expedientes_imp.plantilla,NULL,NULL,(SELECT lvpltimp.nombre FROM plantillas_impor lvpltimp WHERE lvpltimp.codigo = expedientes_imp.plantilla AND lvpltimp.empresa = expedientes_imp.empresa)) D_PLANTILLA,(SELECT lvexpc.descripcion FROM expedientes_cab lvexpc WHERE lvexpc.codigo = expedientes_imp.codigo AND lvexpc.empresa = expedientes_imp.empresa) D_DESCRIPCION_EXPEDIENTE FROM EXPEDIENTES_IMP) EXPEDIENTES_IMP,(SELECT EXPEDIENTES_HOJAS_SEGUIM.*,(SELECT DESCRIPCION FROM EXPEDIENTES_HOJAS_SITUACION WHERE CODIGO=EXPEDIENTES_HOJAS_SEGUIM.SITUACION_LOGISTICA) D_SITUACION_LOGISTICA,NVL((SELECT pr.nombre
 FROM proveedores pr
WHERE pr.codigo_rapido = expedientes_hojas_seguim.proveedor
AND pr.codigo_empresa = expedientes_hojas_seguim.empresa),(SELECT pr.nombre
FROM proveedores pr, expedientes_imp ei
WHERE ei.codigo = expedientes_hojas_seguim.num_expediente
AND ei.empresa = expedientes_hojas_seguim.empresa
AND pr.codigo_rapido = ei.proveedor
AND pr.codigo_empresa = ei.empresa)) D_PROVEEDOR_HOJA,(SELECT LISTAGG(EC.NUM_CARTA_CREDITO, ',') within group (order by EC.NUM_CARTA_CREDITO)
FROM EXPEDIENTES_HOJAS_SEGUIM_MOV EC
WHERE EC.NUM_EXPEDIENTE = EXPEDIENTES_HOJAS_SEGUIM.NUM_EXPEDIENTE
AND EC.NUM_HOJA = EXPEDIENTES_HOJAS_SEGUIM.NUM_HOJA
AND  EC.EMPRESA = EXPEDIENTES_HOJAS_SEGUIM.EMPRESA) CARTA_CREDITO FROM EXPEDIENTES_HOJAS_SEGUIM) EXPEDIENTES_HOJAS_SEGUIM,(SELECT EXPEDIENTES_ARTICULOS_EMBARQUE.*,(SELECT (SELECT DECODE(usuarios.tipo_desc_art,'V',articulos.descrip_comercial, 'C',articulos.descrip_compra, 'T',articulos.descrip_tecnica,articulos.descrip_comercial) FROM usuarios WHERE usuarios.usuario=pkpantallas.usuario_validado) FROM articulos WHERE articulos.codigo_articulo = expedientes_articulos_embarque.articulo AND articulos.codigo_empresa  =expedientes_articulos_embarque.empresa) D_ARTICULO,(SELECT DECODE(AR.UNIDAD_PRECIO_COSTE,1,CANTIDAD_UNIDAD1*PRECIO,CANTIDAD_UNIDAD2*PRECIO) FROM ARTICULOS AR WHERE AR.CODIGO_ARTICULO =  EXPEDIENTES_ARTICULOS_EMBARQUE.ARTICULO AND AR.CODIGO_EMPRESA = EXPEDIENTES_ARTICULOS_EMBARQUE.EMPRESA) IMPORTE FROM EXPEDIENTES_ARTICULOS_EMBARQUE) EXPEDIENTES_ARTICULOS_EMBARQUE,EXPEDIENTES_CONTENEDORES WHERE (expedientes_contenedores.num_expediente=expedientes_articulos_embarque.num_expediente
and expedientes_contenedores.num_hoja=expedientes_articulos_embarque.num_hoja
and expedientes_contenedores.empresa=expedientes_articulos_embarque.empresa
AND expedientes_contenedores.linea=expedientes_articulos_embarque.linea_contenedor
and expedientes_hojas_seguim.num_expediente=expedientes_articulos_embarque.num_expediente
and expedientes_hojas_seguim.num_hoja=expedientes_articulos_embarque.num_hoja
and expedientes_hojas_seguim.empresa=expedientes_articulos_embarque.empresa
and expedientes_imp.codigo=expedientes_hojas_seguim.num_expediente
and expedientes_imp.empresa=expedientes_hojas_seguim.empresa
and expedientes_articulos_embarque.empresa='001'
AND articulos.codigo_articulo=expedientes_articulos_embarque.articulo
AND articulos.codigo_empresa=expedientes_articulos_embarque.empresa
AND ('' IS NULL OR
EXISTS(SELECT 1
FROM expedientes_contenedores ec
WHERE ec.num_expediente=expedientes_hojas_seguim.num_expediente
AND ec.num_hoja=expedientes_hojas_seguim.num_hoja
AND ec.empresa=expedientes_hojas_seguim.empresa
AND contenedor LIKE '')) AND ('' IS NULL OR
EXISTS(SELECT 1
FROM expedientes_contenedores ec
WHERE ec.num_expediente=expedientes_hojas_seguim.num_expediente
AND ec.num_hoja=expedientes_hojas_seguim.num_hoja
AND ec.empresa=expedientes_hojas_seguim.empresa
AND tipo='')) AND ('' IS NULL OR
(EXISTS(SELECT 1
FROM con_impor co,expedientes_hojas_seguim_con ec
WHERE co.codigo=ec.concepto
AND co.tipo='PO'
AND co.codigo_empresa=ec.empresa
AND ec.num_expediente=expedientes_hojas_seguim.num_expediente
AND ec.num_hoja=expedientes_hojas_seguim.num_hoja
AND ec.empresa=expedientes_hojas_seguim.empresa
AND proveedor=''))) AND ('' IS NULL OR
(EXISTS(SELECT 1
FROM con_impor co,expedientes_hojas_seguim_con ec
WHERE co.codigo=ec.concepto
AND co.tipo='FL'
AND ec.num_expediente=expedientes_hojas_seguim.num_expediente
AND ec.num_hoja=expedientes_hojas_seguim.num_hoja
AND ec.empresa=expedientes_hojas_seguim.empresa
AND proveedor=''))) AND ('' IS NULL OR
(EXISTS(SELECT 1
FROM con_impor co,expedientes_hojas_seguim_con ec
WHERE co.codigo=ec.concepto
AND co.tipo='DE'
AND co.codigo_empresa=ec.empresa
AND ec.num_expediente=expedientes_hojas_seguim.num_expediente
AND ec.num_hoja=expedientes_hojas_seguim.num_hoja
AND ec.empresa=expedientes_hojas_seguim.empresa
AND proveedor=''))) AND ('' IS NULL OR
EXISTS(SELECT 1
FROM expedientes_hojas_seguim_mov ec
WHERE ec.num_expediente=expedientes_hojas_seguim.num_expediente
AND ec.num_hoja=expedientes_hojas_seguim.num_hoja
AND ec.empresa=expedientes_hojas_seguim.empresa
AND num_carta_credito LIKE '')) AND ('' IS NULL OR
EXISTS(SELECT 1
FROM expedientes_hojas_seguim_mov ec
WHERE ec.num_expediente=expedientes_hojas_seguim.num_expediente
AND ec.num_hoja=expedientes_hojas_seguim.num_hoja
AND ec.empresa=expedientes_hojas_seguim.empresa
AND num_bill_lading LIKE '')) AND ('' IS NULL OR
EXISTS(SELECT 1
FROM expedientes_articulos_embarque ec
WHERE ec.num_expediente=expedientes_hojas_seguim.num_expediente
AND ec.num_hoja=expedientes_hojas_seguim.num_hoja
AND ec.empresa=expedientes_hojas_seguim.empresa
AND ec.lote LIKE ''))
AND ('' IS NULL OR
EXISTS(SELECT 1 FROM expedientes_hojas_seguim_mov ec
WHERE ec.num_expediente=expedientes_hojas_seguim.num_expediente
AND ec.num_hoja=expedientes_hojas_seguim.num_hoja
AND ec.empresa=expedientes_hojas_seguim.empresa
AND numero_booking LIKE ''))
AND ('' IS NULL OR
EXISTS(SELECT 1
FROM expedientes_hojas_seguim_mov ec
WHERE ec.num_expediente=expedientes_hojas_seguim.num_expediente
AND ec.num_hoja=expedientes_hojas_seguim.num_hoja
AND ec.empresa=expedientes_hojas_seguim.empresa
AND banco LIKE ''))
AND ('' IS NULL OR expedientes_hojas_seguim.numero_dua LIKE '' OR
(EXISTS(SELECT 1
FROM expedientes_contenedores_docs ec
WHERE ec.num_expediente=expedientes_hojas_seguim.num_expediente
AND ec.num_hoja =expedientes_hojas_seguim.num_hoja
AND ec.empresa=expedientes_hojas_seguim.empresa
AND codigo_dua LIKE '') OR expedientes_imp.numero_dua LIKE ''))
AND ('' IS NULL OR
EXISTS(SELECT 1
FROM expedientes_hojas_seguim_mov ec
WHERE ec.num_expediente=expedientes_hojas_seguim.num_expediente
AND ec.num_hoja=expedientes_hojas_seguim.num_hoja
AND ec.empresa=expedientes_hojas_seguim.empresa
AND ec.cod_movimiento
IN (SELECT col_value FROM TABLE(pktmp_select_in.split_cadena_vch2('')))
)) AND ('' IS NULL OR
NOT EXISTS(SELECT 1
FROM expedientes_hojas_seguim_mov ec
WHERE ec.num_expediente=expedientes_hojas_seguim.num_expediente
AND ec.num_hoja=expedientes_hojas_seguim.num_hoja
AND ec.empresa=expedientes_hojas_seguim.empresa
AND ec.cod_movimiento IN (SELECT col_value FROM TABLE(pktmp_select_in.split_cadena_vch2(''))))) AND ('' IS NULL OR
EXISTS(SELECT 1
FROM albaran_compras_c ac
WHERE ac.numero_expediente=expedientes_hojas_seguim.num_expediente
AND ac.codigo_EMPRESA=expedientes_hojas_seguim.EMPRESA
AND (ac.hoja_seguimiento IS NULL OR ac.hoja_seguimiento=expedientes_hojas_seguim.num_hoja)
AND ac.numero_doc_interno=''))
AND ('' IS NULL OR
EXISTS(SELECT 1
FROM facturas_compras_lin fc,albaran_compras_l al,albaran_compras_c ac
WHERE ac.numero_expediente=expedientes_hojas_seguim.num_expediente
AND ac.codigo_empresa=expedientes_hojas_seguim.empresa
AND (ac.hoja_seguimiento IS NULL OR ac.hoja_seguimiento=expedientes_hojas_seguim.num_hoja)
AND al.numero_doc_interno=ac.numero_doc_interno
AND al.codigo_empresa=ac.codigo_empresa
AND fc.num_albaran_int=al.numero_doc_interno
AND fc.linea_albaran=al.numero_linea
AND fc.numero_factura=''
AND fc.codigo_empresa=al.codigo_empresa))
AND ('' IS NULL OR NVL(expedientes_hojas_seguim.proveedor,(SELECT ei.proveedor FROM expedientes_imp ei WHERE ei.codigo=expedientes_hojas_seguim.num_expediente AND ei.empresa=expedientes_hojas_seguim.empresa))='')
AND (('' IS NULL AND '' IS NULL AND '' IS NULL AND '' IS NULL) OR
EXISTS (SELECT 1
FROM pedidos_ventas pv
WHERE pv.empresa=expedientes_hojas_seguim.empresa
AND pv.numero_expediente=expedientes_hojas_seguim.num_expediente
AND (pv.hoja_seguimiento IS NULL OR pv.hoja_seguimiento=expedientes_hojas_seguim.num_hoja)
AND (pv.organizacion_comercial= '' OR '' IS NULL)
AND (pv.ejercicio= '' OR '' IS NULL)
AND (pv.numero_pedido= '' OR '' IS NULL)
AND (pv.numero_serie= '' OR '' IS NULL)
AND NVL(pv.anulado, 'N') = 'N'))
AND (('' IS NULL AND '' IS NULL AND '' IS NULL AND '' IS NULL) OR
EXISTS (SELECT 1
FROM albaran_ventas pv
WHERE pv.empresa=expedientes_hojas_seguim.empresa
AND pv.numero_expediente=expedientes_hojas_seguim.num_expediente
AND (pv.hoja_seguimiento IS NULL OR pv.hoja_seguimiento=expedientes_hojas_seguim.num_hoja)
AND (pv.organizacion_comercial= '' OR '' IS NULL)
AND (pv.ejercicio= '' OR '' IS NULL)
AND (pv.numero_albaran= '' OR '' IS NULL)
AND (pv.numero_serie= '' OR '' IS NULL)
AND NVL(pv.anulado, 'N') = 'N'))
AND (('' IS NULL AND '' IS NULL AND '' IS NULL) OR
EXISTS (SELECT 1
FROM albaran_ventas pv
WHERE pv.empresa=expedientes_hojas_seguim.empresa
AND pv.numero_expediente=expedientes_hojas_seguim.num_expediente
AND (pv.hoja_seguimiento IS NULL OR pv.hoja_seguimiento=expedientes_hojas_seguim.num_hoja)
AND (pv.ejercicio_factura='' OR '' IS NULL)
AND (pv.numero_factura='' OR '' IS NULL)
AND (pv.numero_serie_fra='' OR '' IS NULL)
AND NVL(pv.anulado, 'N') = 'N'))
AND ('' is null or exists (select 1 from expedientes_imp_agentes ea where ea.numero_expediente = expedientes_imp.codigo and ea.agente = '' and ea.empresa = expedientes_imp.empresa)) AND (EXPEDIENTES_HOJAS_SEGUIM.STATUS NOT IN ('C'))) AND (articulos.codigo_empresa = '001') AND (expedientes_imp.empresa = '001') AND (expedientes_hojas_seguim.empresa = '001') AND (expedientes_articulos_embarque.EMPRESA='001') AND (expedientes_contenedores.empresa = '001') 
AND expedientes_hojas_seguim.num_expediente = 65;




SELECT DISTINCT ac.artcomp_codigo_proveedor AS codigo_proveedor
FROM artcomp ac
WHERE ac.artcomp_codigo_articulo = 40926;


SELECT V_FECHA,V_CODIGO_PROVEEDOR,D_CODIGO_PROVEEDOR,V_NUMERO_LOTE_INT,V_NUMERO_DOC_EXT,V_NUMERO_DOC_INTERNO,V_CANTIDAD_ENTREGADA,V_UNIDADES_ALMACEN,SUM_UNID_ALM,V_PRESENTACION,V_PRECIO_PRESENTACION,V_DTO_1,V_DTO_2,V_DTO_3,V_IMPORTE_LIN_NETO,
V_DIVISA,V_DESCRIPCION_ARTICULO,V_ORGANIZACION_COMPRAS,D_ORGANIZACION_COMPRAS,V_CODIGO_ALMACEN,V_CENTRO_CONTABLE,D_CODIGO_ALMACEN,D_CENTRO_CONTABLE,V_UNIDAD_ALMACEN2,SUM_UNID_ALM2,V_SERIE_PEDIDO,V_NUMERO_PEDIDO,V_FACTURADO,V_PRECIO_NETO,
V_IMPORTE_PORTES,V_DEVOLUCION,V_USUARIO,V_DESCRIPCION_LOTE,V_DESCRIPCION_LOTE2,UNID_SUB,UNID_SOB,UNID_EXP,UNID_DIS,DEPOSITO_PROVEEDOR,HAY_REPLICACION_VTA,NUMERO_LINEA,CONTADOR_GESTION,V_CODIGO_ARTICULO,STATUS_ANULADO 

FROM (SELECT  v.* ,(SELECT lvcc.nombre FROM caracteres_asiento lvcc WHERE lvcc.codigo = v.centro_contable AND lvcc.empresa = v.codigo_empresa) D_CENTRO_CONTABLE,
(SELECT lval.nombre FROM almacenes lval WHERE lval.almacen = v.codigo_almacen AND lval.codigo_empresa = v.codigo_empresa) D_CODIGO_ALMACEN,(SELECT prlv.nombre FROM proveedores prlv WHERE prlv.codigo_rapido = v.codigo_proveedor AND codigo_empresa = v.codigo_empresa) D_CODIGO_PROVEEDOR,(SELECT lvcpr.nombre FROM organizacion_compras lvcpr WHERE lvcpr.codigo_org_compras = v.organizacion_compras AND lvcpr.codigo_empresa = v.codigo_empresa) D_ORGANIZACION_COMPRAS,pkconsgen.hay_replicacion_com_vta(v.numero_doc_interno, v.codigo_empresa, v.numero_linea) HAY_REPLICACION_VTA,decode(status_anulado, 'S', 0, 'N', unidades_almacen) SUM_UNID_ALM,decode(status_anulado, 'S', 0, 'N', unidad_almacen2) SUM_UNID_ALM2,CANTIDAD_ENTREGADA V_CANTIDAD_ENTREGADA,CENTRO_CONTABLE V_CENTRO_CONTABLE,CODIGO_ALMACEN V_CODIGO_ALMACEN,CODIGO_ARTICULO V_CODIGO_ARTICULO,CODIGO_PROVEEDOR V_CODIGO_PROVEEDOR,DECODE(v.numero_lote_int,NULL,NULL,(SELECT lvhl.descripcion_lote FROM historico_lotes lvhl WHERE lvhl.numero_lote_int = v.numero_lote_int AND lvhl.codigo_articulo = v.codigo_articulo AND lvhl.codigo_empresa = v.codigo_empresa)) V_DESCRIPCION_LOTE,pkconsgen.f_get_status_devolucion(v.codigo_empresa, v.numero_doc_interno, v.numero_linea, v.status) V_DEVOLUCION,PKCONSGEN.DIVISA(divisa) V_DIVISA,dto_1 V_DTO_1,dto_2 V_DTO_2,dto_3 V_DTO_3,FACTURADO V_FACTURADO,FECHA V_FECHA,PKCONSGEN.IMPORTE_TXT(importe_lin_neto, importe_lin_neto_div, divisa, importe_lin_neto_div2) V_IMPORTE_LIN_NETO,NUMERO_DOC_EXT V_NUMERO_DOC_EXT,NUMERO_DOC_INTERNO V_NUMERO_DOC_INTERNO,pkconsgen.get_numero_lote_int_albcom(v.codigo_empresa, v.codigo_articulo, v.numero_doc_interno, v.numero_linea, v.numero_lote_int) V_NUMERO_LOTE_INT,NUMERO_PEDIDO V_NUMERO_PEDIDO,ORGANIZACION_COMPRAS V_ORGANIZACION_COMPRAS,PKCONSGEN.PRECIO_TXT(precio_neto * cambio, precio_neto, divisa, precio_neto * cambio * cambio_div2) V_PRECIO_NETO,PKCONSGEN.PRECIO_TXT(DECODE(tipo_precio, 'P', precio_presentacion, precio_bruto) * cambio, DECODE(tipo_precio, 'P', precio_presentacion, precio_bruto), divisa, DECODE(tipo_precio, 'P', precio_presentacion, precio_bruto) * cambio * cambio_div2) V_PRECIO_PRESENTACION,PRESENTACION V_PRESENTACION,SERIE_PEDIDO V_SERIE_PEDIDO,UNIDADES_ALMACEN V_UNIDADES_ALMACEN,UNIDAD_ALMACEN2 V_UNIDAD_ALMACEN2,USUARIO V_USUARIO,DESCRIPCION_ARTICULO V_DESCRIPCION_ARTICULO,DECODE(v.numero_lote_int,NULL,NULL,(SELECT lvhl.descripcion_lote2 FROM historico_lotes lvhl WHERE lvhl.numero_lote_int = v.numero_lote_int AND lvhl.codigo_articulo = v.codigo_articulo AND lvhl.codigo_empresa = v.codigo_empresa)) V_DESCRIPCION_LOTE2,PKCONSGEN.IMPORTE_TXT(importe_portes, importe_portes_div, divisa) V_IMPORTE_PORTES FROM (SELECT l.rowid, l.codigo_empresa, c.usuario, c.organizacion_compras, l.numero_doc_interno, l.unidad_almacen2, l.cantidad_entregada, l.presentacion, c.codigo_almacen, l.codigo_articulo, l.status, l.numero_linea, c.centro_contable, c.fecha, c.numero_doc_ext, DECODE(PKCONSGEN.VER_PRO_BLOQUEADOS, 'S', c.codigo_proveedor, DECODE(PKCONSGEN.PROVEEDOR_BLOQUEADO(c.codigo_empresa, c.codigo_proveedor), 'S', NULL, c.codigo_proveedor)) codigo_proveedor, l.divisa, l.tipo_precio, l.precio_bruto, l.precio_neto, l.dto_1, l.dto_2, l.dto_3, l.importe_lin_neto, l.importe_lin_neto_div, l.importe_portes, l.unidades_almacen, l.facturado, l.descripcion descripcion_articulo, l.cambio, l.importe_portes_div, l.precio_presentacion, c.deposito_proveedor, l.numero_pedido, l.serie_pedido, l.numero_lote_int, l.unid_exp, l.unid_dis, l.unid_sob, l.unid_sub,l.numero_linea_pedido, l.org_compras_pedido, c.contador_gestion, c.status_anulado,c.numero_expediente,l.expediente_importacion, l.importe_lin_neto_div2, l.cambio_div2 FROM albaran_compras_c c, albaran_compras_l l WHERE c.numero_doc_interno = l.numero_doc_interno AND c.codigo_empresa = l.codigo_empresa ORDER BY /*PKLBOB*/c.fecha/*PKLEOB*/) v)  v WHERE codigo_articulo = '40926' AND codigo_empresa = '001';




SELECT DISTINCT l.codigo_articulo,
       c.codigo_proveedor
FROM albaran_compras_c c
JOIN albaran_compras_l l
  ON c.numero_doc_interno = l.numero_doc_interno
 AND c.codigo_empresa = l.codigo_empresa
WHERE 1=1 AND
   l.codigo_articulo = '40926'
  AND l.codigo_empresa = '001' AND ROWNUM = 1;


select *
from stocks_detallado
;



SELECT *
FROM
    STOCKS_DETALLADO s
JOIN
    CARACTERISTICAS_LOTES c ON s.CODIGO_ARTICULO = c.CODIGO_ARTICULO
     AND s.CODIGO_EMPRESA  = c.CODIGO_EMPRESA
     AND s.NUMERO_LOTE_INT = c.NUMERO_LOTE_INT
WHERE
    s.CANTIDAD_UNIDAD1 > 0 
    -- AND s.CODIGO_ARTICULO = 40006
;



SELECT s.NUMERO_PALET, s.CODIGO_ARTICULO, s.NUMERO_LOTE_INT
FROM
    STOCKS_DETALLADO s
JOIN
    CARACTERISTICAS_LOTES c ON s.CODIGO_ARTICULO = c.CODIGO_ARTICULO
     AND s.CODIGO_EMPRESA  = c.CODIGO_EMPRESA
     AND s.NUMERO_LOTE_INT = c.NUMERO_LOTE_INT
WHERE
    s.CANTIDAD_UNIDAD1 > 0 AND
    s.CODIGO_ARTICULO = 40006
;



select * 
from STOCKS_DETALLADO
where codigo_articulo = 40006
   and CANTIDAD_UNIDAD1 > 0
;

-- 40006

select * 
from CARACTERISTICAS_LOTES
;


 and STOCKS_DETALLADO.NUMERO_LOTE_INT=CARACTERISTICAS_LOTES.NUMERO_LOTE_INT AND STOCKS_DETALLADO.CANTIDAD_UNIDAD1 > 0

select * from articulos;



SELECT stocks_detallado.numero_palet,
      (SELECT DESCRIP_COMERCIAL FROM ARTICULOS WHERE CODIGO_ARTICULO = stocks_detallado.codigo_articulo AND ROWNUM = 1) AS DESCRIP_COMERCIAL,
      caracteristicas_lotes.codigo_articulo,
      caracteristicas_lotes.numero_lote_int,
      caracteristicas_lotes.valor_alfa_1,
      caracteristicas_lotes.d_valor_alfa_1,
      caracteristicas_lotes.valor_alfa_2,
      caracteristicas_lotes.d_valor_alfa_2,
      caracteristicas_lotes.valor_alfa_3,
      caracteristicas_lotes.d_valor_alfa_3,
      caracteristicas_lotes.valor_alfa_4,
      caracteristicas_lotes.d_valor_alfa_4,
      caracteristicas_lotes.valor_alfa_5,
      caracteristicas_lotes.d_valor_alfa_5,
      caracteristicas_lotes.valor_alfa_6,
      caracteristicas_lotes.d_valor_alfa_6,
      caracteristicas_lotes.valor_alfa_7,
      caracteristicas_lotes.d_valor_alfa_7,
      caracteristicas_lotes.valor_alfa_8,
      caracteristicas_lotes.d_valor_alfa_8,
      caracteristicas_lotes.valor_alfa_9,
      caracteristicas_lotes.d_valor_alfa_9,
      caracteristicas_lotes.valor_alfa_10,
      caracteristicas_lotes.d_valor_alfa_10
FROM STOCKS_DETALLADO,
   (SELECT CARACTERISTICAS_LOTES.*,
   (SELECT NVL(lvpti.descripcion, lvtpd.descripcion) 
      FROM titulos_personaliz_des lvtpd, titulos_personaliz_des_idioma lvpti WHERE lvpti.valor(+) = lvtpd.valor 
         AND lvpti.numero(+) = lvtpd.numero AND lvpti.codigo_personaliz(+) = lvtpd.codigo_personaliz 
         AND lvpti.empresa(+) = lvtpd.empresa AND lvtpd.valor = CARACTERISTICAS_LOTES.VALOR_ALFA_1 AND lvtpd.numero = 1 
         AND lvtpd.codigo_personaliz = (SELECT AR.CODIGO_PERSONALIZ_LOTES FROM ARTICULOS AR WHERE AR.CODIGO_ARTICULO = CARACTERISTICAS_LOTES.CODIGO_ARTICULO AND AR.CODIGO_EMPRESA = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) 
         AND lvtpd.empresa = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) D_VALOR_ALFA_1,
         (SELECT NVL(lvpti.descripcion, lvtpd.descripcion) FROM titulos_personaliz_des lvtpd, titulos_personaliz_des_idioma lvpti WHERE lvpti.valor(+) = lvtpd.valor AND lvpti.numero(+) = lvtpd.numero 
         AND lvpti.codigo_personaliz(+) = lvtpd.codigo_personaliz AND lvpti.empresa(+) = lvtpd.empresa AND lvtpd.valor = CARACTERISTICAS_LOTES.VALOR_ALFA_2 AND lvtpd.numero = 2 
         AND lvtpd.codigo_personaliz = (SELECT AR.CODIGO_PERSONALIZ_LOTES FROM ARTICULOS AR WHERE AR.CODIGO_ARTICULO = CARACTERISTICAS_LOTES.CODIGO_ARTICULO AND AR.CODIGO_EMPRESA = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) 
         AND lvtpd.empresa = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) D_VALOR_ALFA_2,
         (SELECT NVL(lvpti.descripcion, lvtpd.descripcion) FROM titulos_personaliz_des lvtpd, titulos_personaliz_des_idioma lvpti WHERE lvpti.valor(+) = lvtpd.valor AND lvpti.numero(+) = lvtpd.numero 
         AND lvpti.codigo_personaliz(+) = lvtpd.codigo_personaliz AND lvpti.empresa(+) = lvtpd.empresa AND lvtpd.valor = CARACTERISTICAS_LOTES.VALOR_ALFA_3 AND lvtpd.numero = 3 
         AND lvtpd.codigo_personaliz = (SELECT AR.CODIGO_PERSONALIZ_LOTES FROM ARTICULOS AR WHERE AR.CODIGO_ARTICULO = CARACTERISTICAS_LOTES.CODIGO_ARTICULO AND AR.CODIGO_EMPRESA = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) 
         AND lvtpd.empresa = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) D_VALOR_ALFA_3,
         (SELECT NVL(lvpti.descripcion, lvtpd.descripcion) FROM titulos_personaliz_des lvtpd, titulos_personaliz_des_idioma lvpti WHERE lvpti.valor(+) = lvtpd.valor AND lvpti.numero(+) = lvtpd.numero 
         AND lvpti.codigo_personaliz(+) = lvtpd.codigo_personaliz AND lvpti.empresa(+) = lvtpd.empresa AND lvtpd.valor = CARACTERISTICAS_LOTES.VALOR_ALFA_4 AND lvtpd.numero = 4 
         AND lvtpd.codigo_personaliz = (SELECT AR.CODIGO_PERSONALIZ_LOTES FROM ARTICULOS AR WHERE AR.CODIGO_ARTICULO = CARACTERISTICAS_LOTES.CODIGO_ARTICULO AND AR.CODIGO_EMPRESA = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) 
         AND lvtpd.empresa = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) D_VALOR_ALFA_4,(SELECT NVL(lvpti.descripcion, lvtpd.descripcion) FROM titulos_personaliz_des lvtpd, titulos_personaliz_des_idioma lvpti WHERE lvpti.valor(+) = lvtpd.valor 
         AND lvpti.numero(+) = lvtpd.numero AND lvpti.codigo_personaliz(+) = lvtpd.codigo_personaliz  AND lvpti.empresa(+) = lvtpd.empresa AND lvtpd.valor = CARACTERISTICAS_LOTES.VALOR_ALFA_5 
         AND lvtpd.numero = 5 AND lvtpd.codigo_personaliz = (SELECT AR.CODIGO_PERSONALIZ_LOTES FROM ARTICULOS AR WHERE AR.CODIGO_ARTICULO = CARACTERISTICAS_LOTES.CODIGO_ARTICULO AND AR.CODIGO_EMPRESA = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) 
         AND lvtpd.empresa = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) D_VALOR_ALFA_5,(SELECT NVL(lvpti.descripcion, lvtpd.descripcion) FROM titulos_personaliz_des lvtpd, titulos_personaliz_des_idioma lvpti WHERE lvpti.valor(+) = lvtpd.valor 
         AND lvpti.numero(+) = lvtpd.numero AND lvpti.codigo_personaliz(+) = lvtpd.codigo_personaliz  AND lvpti.empresa(+) = lvtpd.empresa 
         AND lvtpd.valor = CARACTERISTICAS_LOTES.VALOR_ALFA_6 AND lvtpd.numero = 6 AND lvtpd.codigo_personaliz = (SELECT AR.CODIGO_PERSONALIZ_LOTES FROM ARTICULOS AR WHERE AR.CODIGO_ARTICULO = CARACTERISTICAS_LOTES.CODIGO_ARTICULO 
         AND AR.CODIGO_EMPRESA = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) AND lvtpd.empresa = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) D_VALOR_ALFA_6,(SELECT NVL(lvpti.descripcion, lvtpd.descripcion) 
         FROM titulos_personaliz_des lvtpd, titulos_personaliz_des_idioma lvpti WHERE lvpti.valor(+) = lvtpd.valor AND lvpti.numero(+) = lvtpd.numero AND lvpti.codigo_personaliz(+) = lvtpd.codigo_personaliz 
          AND lvpti.empresa(+) = lvtpd.empresa AND lvtpd.valor = CARACTERISTICAS_LOTES.VALOR_ALFA_7 AND lvtpd.numero = 7 
         AND lvtpd.codigo_personaliz = (SELECT AR.CODIGO_PERSONALIZ_LOTES FROM ARTICULOS AR WHERE AR.CODIGO_ARTICULO = CARACTERISTICAS_LOTES.CODIGO_ARTICULO AND AR.CODIGO_EMPRESA = CARACTERISTICAS_LOTES.CODIGO_EMPRESA)
          AND lvtpd.empresa = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) D_VALOR_ALFA_7,(SELECT NVL(lvpti.descripcion, lvtpd.descripcion) FROM titulos_personaliz_des lvtpd, titulos_personaliz_des_idioma lvpti WHERE lvpti.valor(+) = lvtpd.valor 
          AND lvpti.numero(+) = lvtpd.numero AND lvpti.codigo_personaliz(+) = lvtpd.codigo_personaliz  AND lvpti.empresa(+) = lvtpd.empresa AND lvtpd.valor = CARACTERISTICAS_LOTES.VALOR_ALFA_8 
          AND lvtpd.numero = 8 AND lvtpd.codigo_personaliz = (SELECT AR.CODIGO_PERSONALIZ_LOTES FROM ARTICULOS AR WHERE AR.CODIGO_ARTICULO = CARACTERISTICAS_LOTES.CODIGO_ARTICULO AND AR.CODIGO_EMPRESA = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) 
          AND lvtpd.empresa = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) D_VALOR_ALFA_8,(SELECT NVL(lvpti.descripcion, lvtpd.descripcion) FROM titulos_personaliz_des lvtpd, titulos_personaliz_des_idioma lvpti WHERE lvpti.valor(+) = lvtpd.valor 
          AND lvpti.numero(+) = lvtpd.numero AND lvpti.codigo_personaliz(+) = lvtpd.codigo_personaliz  AND lvpti.empresa(+) = lvtpd.empresa AND lvtpd.valor = CARACTERISTICAS_LOTES.VALOR_ALFA_9 
          AND lvtpd.numero = 9 AND lvtpd.codigo_personaliz = (SELECT AR.CODIGO_PERSONALIZ_LOTES FROM ARTICULOS AR WHERE AR.CODIGO_ARTICULO = CARACTERISTICAS_LOTES.CODIGO_ARTICULO AND AR.CODIGO_EMPRESA = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) 
          AND lvtpd.empresa = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) D_VALOR_ALFA_9,(SELECT NVL(lvpti.descripcion, lvtpd.descripcion) FROM titulos_personaliz_des lvtpd, titulos_personaliz_des_idioma lvpti WHERE lvpti.valor(+) = lvtpd.valor 
          AND lvpti.numero(+) = lvtpd.numero AND lvpti.codigo_personaliz(+) = lvtpd.codigo_personaliz  AND lvpti.empresa(+) = lvtpd.empresa AND lvtpd.valor = CARACTERISTICAS_LOTES.VALOR_ALFA_10 
          AND lvtpd.numero = 10 AND lvtpd.codigo_personaliz = (SELECT AR.CODIGO_PERSONALIZ_LOTES FROM ARTICULOS AR WHERE AR.CODIGO_ARTICULO = CARACTERISTICAS_LOTES.CODIGO_ARTICULO AND AR.CODIGO_EMPRESA = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) 
          AND lvtpd.empresa = CARACTERISTICAS_LOTES.CODIGO_EMPRESA) D_VALOR_ALFA_10 FROM CARACTERISTICAS_LOTES) CARACTERISTICAS_LOTES WHERE (STOCKS_DETALLADO.CODIGO_ARTICULO=CARACTERISTICAS_LOTES.CODIGO_ARTICULO 
          and STOCKS_DETALLADO.CODIGO_EMPRESA=CARACTERISTICAS_LOTES.CODIGO_EMPRESA and STOCKS_DETALLADO.NUMERO_LOTE_INT=CARACTERISTICAS_LOTES.NUMERO_LOTE_INT AND STOCKS_DETALLADO.CANTIDAD_UNIDAD1 > 0) 
          AND (stocks_detallado.codigo_empresa = '001') 
          AND (stocks_detallado.numero_palet LIKE '000009785' AND caracteristicas_lotes.codigo_articulo = '40000' )
          
          ;



select * from titulos_personaliz_des;



familia pescados, subfamilia varios c.

012 PESCADOS > 042 VARIOS PESCADOS

365 BARRAMUNDI
368 LENGUADO LIMON
414 MERO
nombre común > Mero 


select * 
from V_FROXA_CARACTERISTICAS_LOTES_PALET
where numero_palet = '000025335'
;

SELECT text
FROM user_views
WHERE view_name = 'V_FROXA_CARACTERISTICAS_LOTES_PALET';


SELECT sd.numero_palet, 
      cl.codigo_articulo, 
      cl.numero_lote_int, 
      t.titulo_alfa_1, 
      cl.valor_alfa_1 AS valor, 
      NVL(tp.descripcion, cl.valor_alfa_1),
      null
FROM stocks_detallado sd, caracteristicas_lotes cl, TITULOS_PERSONALIZ t, articulos a, TITULOS_PERSONALIZ_DES tp
WHERE sd.codigo_articulo = cl.codigo_articulo
  AND sd.codigo_empresa = cl.codigo_empresa
  AND sd.numero_lote_int = cl.numero_lote_int
  AND sd.codigo_empresa = '001'
  --AND sd.numero_palet LIKE '000006293%'
  AND cl.codigo_empresa = a.codigo_empresa
  AND cl.codigo_articulo = a.codigo_articulo
  AND t.codigo_empresa = a.codigo_empresa
  AND t.codigo_personaliz = a.codigo_personaliz_lotes
  AND tp.empresa(+) = t.codigo_empresa
  AND tp.codigo_personaliz(+) = t.codigo_personaliz
  AND tp.valor (+) = cl.valor_alfa_1
  AND tp.numero(+) = 1
  AND sd.cantidad_unidad1 > 0

UNION ALL

SELECT sd.numero_palet, cl.codigo_articulo, cl.numero_lote_int, t.titulo_alfa_2, cl.valor_alfa_2 AS valor, NVL(tp.descripcion, cl.valor_alfa_2),null
FROM stocks_detallado sd, caracteristicas_lotes cl, TITULOS_PERSONALIZ t, articulos a, TITULOS_PERSONALIZ_DES tp
WHERE sd.codigo_articulo = cl.codigo_articulo
  AND sd.codigo_empresa = cl.codigo_empresa
  AND sd.numero_lote_int = cl.numero_lote_int
  AND sd.codigo_empresa = '001'
  --AND sd.numero_palet LIKE '000006293%'
  AND cl.codigo_empresa = a.codigo_empresa
  AND cl.codigo_articulo = a.codigo_articulo
  AND t.codigo_empresa = a.codigo_empresa
  AND t.codigo_personaliz = a.codigo_personaliz_lotes
  AND tp.empresa(+) = t.codigo_empresa
  AND tp.codigo_personaliz(+) = t.codigo_personaliz
  AND tp.valor (+) = cl.valor_alfa_2
  AND tp.numero(+) = 2
  AND sd.cantidad_unidad1 > 0

UNION ALL

SELECT sd.numero_palet, cl.codigo_articulo, cl.numero_lote_int, t.titulo_alfa_3, cl.valor_alfa_3 AS valor, NVL(tp.descripcion, cl.valor_alfa_3),null
FROM stocks_detallado sd, caracteristicas_lotes cl, TITULOS_PERSONALIZ t, articulos a, TITULOS_PERSONALIZ_DES tp
WHERE sd.codigo_articulo = cl.codigo_articulo
  AND sd.codigo_empresa = cl.codigo_empresa
  AND sd.numero_lote_int = cl.numero_lote_int
  AND sd.codigo_empresa = '001'
  --AND sd.numero_palet LIKE '000006293%'
  AND cl.codigo_empresa = a.codigo_empresa
  AND cl.codigo_articulo = a.codigo_articulo
  AND t.codigo_empresa = a.codigo_empresa
  AND t.codigo_personaliz = a.codigo_personaliz_lotes
  AND tp.empresa(+) = t.codigo_empresa
  AND tp.codigo_personaliz(+) = t.codigo_personaliz
  AND tp.valor (+) = cl.valor_alfa_3
  AND tp.numero(+) = 3
  AND sd.cantidad_unidad1 > 0

UNION ALL

SELECT sd.numero_palet, cl.codigo_articulo, cl.numero_lote_int, t.titulo_alfa_4, cl.valor_alfa_4 AS valor, NVL(tp.descripcion, cl.valor_alfa_4),null
FROM stocks_detallado sd, caracteristicas_lotes cl, TITULOS_PERSONALIZ t, articulos a, TITULOS_PERSONALIZ_DES tp
WHERE sd.codigo_articulo = cl.codigo_articulo
  AND sd.codigo_empresa = cl.codigo_empresa
  AND sd.numero_lote_int = cl.numero_lote_int
  AND sd.codigo_empresa = '001'
  --AND sd.numero_palet LIKE '000006293%'
  AND cl.codigo_empresa = a.codigo_empresa
  AND cl.codigo_articulo = a.codigo_articulo
  AND t.codigo_empresa = a.codigo_empresa
  AND t.codigo_personaliz = a.codigo_personaliz_lotes
  AND tp.empresa(+) = t.codigo_empresa
  AND tp.codigo_personaliz(+) = t.codigo_personaliz
  AND tp.valor (+) = cl.valor_alfa_4
  AND tp.numero(+) = 4
  AND sd.cantidad_unidad1 > 0

UNION ALL

SELECT sd.numero_palet, cl.codigo_articulo, cl.numero_lote_int, t.titulo_alfa_5, cl.valor_alfa_5 AS valor, NVL(tp.descripcion, cl.valor_alfa_5)
,null
FROM stocks_detallado sd, caracteristicas_lotes cl, TITULOS_PERSONALIZ t, articulos a, TITULOS_PERSONALIZ_DES tp
WHERE sd.codigo_articulo = cl.codigo_articulo
  AND sd.codigo_empresa = cl.codigo_empresa
  AND sd.numero_lote_int = cl.numero_lote_int
  AND sd.codigo_empresa = '001'
  --AND sd.numero_palet LIKE '000006293%'
  --and sd.Codigo_Articulo = '41176'
  AND cl.codigo_empresa = a.codigo_empresa
  AND cl.codigo_articulo = a.codigo_articulo
  AND t.codigo_empresa = a.codigo_empresa
  AND t.codigo_personaliz = a.codigo_personaliz_lotes
  AND tp.empresa(+) = t.codigo_empresa
  AND tp.codigo_personaliz(+) = t.codigo_personaliz
  AND tp.valor (+) = cl.valor_alfa_5
  AND tp.numero(+) = 5
  AND sd.cantidad_unidad1 > 0

UNION ALL

SELECT sd.numero_palet, cl.codigo_articulo, cl.numero_lote_int, t.titulo_alfa_6, cl.valor_alfa_6 AS valor, NVL(tp.descripcion, cl.valor_alfa_6)
,null
FROM stocks_detallado sd, caracteristicas_lotes cl, TITULOS_PERSONALIZ t, articulos a, TITULOS_PERSONALIZ_DES tp
WHERE sd.codigo_articulo = cl.codigo_articulo
  AND sd.codigo_empresa = cl.codigo_empresa
  AND sd.numero_lote_int = cl.numero_lote_int
  AND sd.codigo_empresa = '001'
  --AND sd.numero_palet LIKE '000006293%'
  AND cl.codigo_empresa = a.codigo_empresa
  AND cl.codigo_articulo = a.codigo_articulo
  AND t.codigo_empresa = a.codigo_empresa
  AND t.codigo_personaliz = a.codigo_personaliz_lotes
  AND tp.empresa(+) = t.codigo_empresa
  AND tp.codigo_personaliz(+) = t.codigo_personaliz
  AND tp.valor (+) = cl.valor_alfa_6
  AND tp.numero(+) = 6
  AND sd.cantidad_unidad1 > 0

UNION ALL

SELECT sd.numero_palet, cl.codigo_articulo, cl.numero_lote_int, t.titulo_alfa_7, cl.valor_alfa_7 AS valor, NVL(tp.descripcion, cl.valor_alfa_7),null
FROM stocks_detallado sd, caracteristicas_lotes cl, TITULOS_PERSONALIZ t, articulos a, TITULOS_PERSONALIZ_DES tp
WHERE sd.codigo_articulo = cl.codigo_articulo
  AND sd.codigo_empresa = cl.codigo_empresa
  AND sd.numero_lote_int = cl.numero_lote_int
  AND sd.codigo_empresa = '001'
  --AND sd.numero_palet LIKE '000006293%'
  AND cl.codigo_empresa = a.codigo_empresa
  AND cl.codigo_articulo = a.codigo_articulo
  AND t.codigo_empresa = a.codigo_empresa
  AND t.codigo_personaliz = a.codigo_personaliz_lotes
  AND tp.empresa(+) = t.codigo_empresa
  AND tp.codigo_personaliz(+) = t.codigo_personaliz
  AND tp.valor (+) = cl.valor_alfa_7
  AND tp.numero(+) = 7
  AND sd.cantidad_unidad1 > 0

UNION ALL

SELECT sd.numero_palet, cl.codigo_articulo, cl.numero_lote_int, t.titulo_alfa_8, cl.valor_alfa_8 AS valor, NVL(tp.descripcion, cl.valor_alfa_8),null
FROM stocks_detallado sd, caracteristicas_lotes cl, TITULOS_PERSONALIZ t, articulos a, TITULOS_PERSONALIZ_DES tp
WHERE sd.codigo_articulo = cl.codigo_articulo
  AND sd.codigo_empresa = cl.codigo_empresa
  AND sd.numero_lote_int = cl.numero_lote_int
  AND sd.codigo_empresa = '001'
  --AND sd.numero_palet LIKE '000006293%'
  --and sd.Codigo_Articulo = '41176'
  AND cl.codigo_empresa = a.codigo_empresa
  AND cl.codigo_articulo = a.codigo_articulo
  AND t.codigo_empresa = a.codigo_empresa
  AND t.codigo_personaliz = a.codigo_personaliz_lotes
  AND tp.empresa(+) = t.codigo_empresa
  AND tp.codigo_personaliz(+) = t.codigo_personaliz
  AND tp.valor (+) = cl.valor_alfa_8
  AND tp.numero(+) = 8
  AND sd.cantidad_unidad1 > 0

UNION ALL

SELECT sd.numero_palet, cl.codigo_articulo, cl.numero_lote_int, t.titulo_alfa_9, cl.valor_alfa_9 AS valor, NVL(tp.descripcion, cl.valor_alfa_9),null
FROM stocks_detallado sd, caracteristicas_lotes cl, TITULOS_PERSONALIZ t, articulos a, TITULOS_PERSONALIZ_DES tp
WHERE sd.codigo_articulo = cl.codigo_articulo
  AND sd.codigo_empresa = cl.codigo_empresa
  AND sd.numero_lote_int = cl.numero_lote_int
  AND sd.codigo_empresa = '001'
  --AND sd.numero_palet LIKE '000006293%'
  AND cl.codigo_empresa = a.codigo_empresa
  AND cl.codigo_articulo = a.codigo_articulo
  AND t.codigo_empresa = a.codigo_empresa
  AND t.codigo_personaliz = a.codigo_personaliz_lotes
  AND tp.empresa(+) = t.codigo_empresa
  AND tp.codigo_personaliz(+) = t.codigo_personaliz
  AND tp.valor (+) = cl.valor_alfa_9
  AND tp.numero(+) = 9
  AND sd.cantidad_unidad1 > 0

UNION ALL

SELECT sd.numero_palet, cl.codigo_articulo, cl.numero_lote_int, t.titulo_alfa_10, cl.valor_alfa_10 AS valor, NVL(tp.descripcion, cl.valor_alfa_10),null
FROM stocks_detallado sd, caracteristicas_lotes cl, TITULOS_PERSONALIZ t, articulos a, TITULOS_PERSONALIZ_DES tp
WHERE sd.codigo_articulo = cl.codigo_articulo
  AND sd.codigo_empresa = cl.codigo_empresa
  AND sd.numero_lote_int = cl.numero_lote_int
  AND sd.codigo_empresa = '001'
  --AND sd.numero_palet LIKE '000006293%'
  AND cl.codigo_empresa = a.codigo_empresa
  AND cl.codigo_articulo = a.codigo_articulo
  AND t.codigo_empresa = a.codigo_empresa
  AND t.codigo_personaliz = a.codigo_personaliz_lotes
  AND tp.empresa(+) = t.codigo_empresa
  AND tp.codigo_personaliz(+) = t.codigo_personaliz
  AND tp.valor (+) = cl.valor_alfa_10
  AND tp.numero(+) = 10
  AND sd.cantidad_unidad1 > 0

  union all

  SELECT sd.numero_palet, cl.codigo_articulo, cl.numero_lote_int,  'fecha congelación' AS tipo_fecha ,null,null, cl.valor_fecha_1 as fecha_valor
FROM stocks_detallado sd, caracteristicas_lotes cl, TITULOS_PERSONALIZ t, articulos a
WHERE sd.codigo_articulo = cl.codigo_articulo
  AND sd.codigo_empresa = cl.codigo_empresa
  AND sd.numero_lote_int = cl.numero_lote_int
  AND sd.codigo_empresa = '001'
  --AND sd.numero_palet LIKE '000006293%'
  AND cl.codigo_empresa = a.codigo_empresa
  AND cl.codigo_articulo = a.codigo_articulo
  AND t.codigo_empresa = a.codigo_empresa
  AND t.codigo_personaliz = a.codigo_personaliz_lotes
  AND sd.cantidad_unidad1 > 0

    union all

  SELECT sd.numero_palet, cl.codigo_articulo, cl.numero_lote_int,  'Fecha Producción' AS tipo_fecha,null, null, cl.valor_fecha_2 AS fecha_valor
FROM stocks_detallado sd, caracteristicas_lotes cl, TITULOS_PERSONALIZ t, articulos a
WHERE sd.codigo_articulo = cl.codigo_articulo
  AND sd.codigo_empresa = cl.codigo_empresa
  AND sd.numero_lote_int = cl.numero_lote_int
  AND sd.codigo_empresa = '001'
  --AND sd.numero_palet LIKE '000006293%'
  AND cl.codigo_empresa = a.codigo_empresa
  AND cl.codigo_articulo = a.codigo_articulo
  AND t.codigo_empresa = a.codigo_empresa
  AND t.codigo_personaliz = a.codigo_personaliz_lotes
  AND sd.cantidad_unidad1 > 0;


------------------------------------------------------------------------------


  SELECT clccl.valor_fecha_1 as fecha_congelacion
   FROM stocks_detallado sdccl, caracteristicas_lotes clccl, TITULOS_PERSONALIZ tccl, articulos accl
   WHERE sdccl.codigo_articulo = clccl.codigo_articulo
     AND sdccl.codigo_empresa = clccl.codigo_empresa
     AND sdccl.numero_lote_int = clccl.numero_lote_int
     AND sdccl.codigo_empresa = '001'
     AND sdccl.numero_palet = '000025367'
     AND clccl.codigo_empresa = accl.codigo_empresa
     AND clccl.codigo_articulo = accl.codigo_articulo
     AND tccl.codigo_empresa = accl.codigo_empresa
     AND tccl.codigo_personaliz = accl.codigo_personaliz_lotes
     AND sdccl.cantidad_unidad1 > 0
  ;

select * 
from caracteristicas_lotes;

select * 
from TITULOS_PERSONALIZ
;

select ORDEN_DE_FABRICACION
from COSTES_ORDENES_FAB_MAT_CTD
;

select *
from articulos
;

 dsn=LIBRA","
     SELECT
     ORDEN_DE_FABRICACION,
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