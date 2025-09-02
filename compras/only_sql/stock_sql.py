def get_stok_data_sql(request, oracle):
    # Leer y normalizar el parámetro ?warehouse=00,01,E03,34
    raw = (request.GET.get('warehouse') or '').strip()
    wh_list = [w.strip() for w in raw.split(',') if w.strip()]

    # Filtros dinámicos para usar en los subqueries (alias sd y s)
    wh_filter_sd = ''
    wh_filter_s  = ''
    binds = {}

    if wh_list:
        placeholders = ','.join(f":wh{i}" for i in range(len(wh_list)))
        wh_filter_sd = f" and sd.codigo_almacen in ({placeholders}) "
        wh_filter_s  = f" and s.codigo_almacen  in ({placeholders}) "
        for i, w in enumerate(wh_list):
            binds[f'wh{i}'] = w

    sql = f"""
    select
        t.*,

        /* Lista de almacenes (CODIGO + nombre) con stock != 0 (respetando filtro de almacenes) */
        (
          select listagg(g.codigo_almacen || ' ' || g.nombre_alm, '; ')
                   within group (order by g.codigo_almacen)
          from (
            select
              sd.codigo_almacen,
              a.nombre as nombre_alm
            from stocks_detallado sd
            join almacenes a
              on a.almacen        = sd.codigo_almacen
             and a.codigo_empresa = sd.codigo_empresa
            where sd.codigo_articulo = t.codigo_articulo
              and sd.codigo_empresa  = '001'
              {wh_filter_sd}
              and not exists (
                    select 1
                      from almacenes_zonas az
                     where az.codigo_empresa = sd.codigo_empresa
                       and az.codigo_almacen = sd.codigo_almacen
                       and az.codigo_zona    = sd.codigo_zona
                       and az.es_zona_reserva_virtual = 'S'
                  )
            group by sd.codigo_almacen, a.nombre
            having
                   nvl(sum(sd.cantidad_unidad1), 0) <> 0
                or nvl(sum(nvl(sd.cantidad_unidad2, 0)), 0) <> 0
          ) g
        ) as ALMACENES_TXT,

        /* Misma lista pero solo CÓDIGOS (respetando filtro de almacenes) */
        (
          select listagg(g.codigo_almacen, ';')
                   within group (order by g.codigo_almacen)
          from (
            select sd.codigo_almacen
            from stocks_detallado sd
            where sd.codigo_articulo = t.codigo_articulo
              and sd.codigo_empresa  = '001'
              {wh_filter_sd}
              and not exists (
                    select 1
                      from almacenes_zonas az
                     where az.codigo_empresa = sd.codigo_empresa
                       and az.codigo_almacen = sd.codigo_almacen
                       and az.codigo_zona    = sd.codigo_zona
                       and az.es_zona_reserva_virtual = 'S'
                  )
            group by sd.codigo_almacen
            having
                   nvl(sum(sd.cantidad_unidad1), 0) <> 0
                or nvl(sum(nvl(sd.cantidad_unidad2, 0)), 0) <> 0
          ) g
        ) as ALMACENES_CODE,

        /*  Unidades derivadas de las CAJAS (UND = cajas * unidades_por_caja) */
        round(
            nvl(t.stock_unidad2, 0) *
            nvl( (select max(convers_u_dis)
                    from cadena_logistica
                   where codigo_articulo = t.codigo_articulo), 1 )
        , 2) as UND_DESDE_CAJAS,

        /*  Unidades derivadas de los KG (UND = kg / kg_por_unidad) */
        round(
            nvl(t.stock_unidad1, 0) /
            nvl( nullif( (select max(convers_u_sob)
                            from cadena_logistica
                           where codigo_articulo = t.codigo_articulo), 0 ), 1 )
        , 2) as UND_DESDE_KG

    from (
        select a.codigo_articulo,
               a.descrip_comercial,
               a.codigo_familia as familia,
               (select f.descripcion
                  from familias f
                 where f.numero_tabla = '1'
                   and f.codigo_familia = a.codigo_familia
                   and f.codigo_empresa = '001') as d_codigo_familia,
               a.codigo_estad2 as subfamilia,
               (select f.descripcion
                  from familias f
                 where f.numero_tabla = '2'
                   and f.codigo_familia = a.codigo_estad2
                   and f.codigo_empresa = '001') as d_codigo_subfamilia,

               nvl( (select pl.precio_consumo
                       from precios_listas pl
                      where pl.codigo_articulo = a.codigo_articulo
                        and pl.organizacion_comercial = '01'
                        and pl.divisa = 'EUR'
                        and pl.numero_lista = '1'
                      order by pl.fecha_validez desc
                      fetch first 1 row only), 0) as PVP_NACIONAL,

               nvl( (select pl.precio_consumo
                       from precios_listas pl
                      where pl.codigo_articulo = a.codigo_articulo
                        and pl.organizacion_comercial = '02'
                        and pl.divisa = 'EUR'
                        and pl.numero_lista = '1'
                      order by pl.fecha_validez desc
                      fetch first 1 row only), 0) as PVP_REGIONAL,

               nvl( (select avv.PRECIO_MEDIO_PONDERADO
                       from ARTICULOS_VALORACION avv
                      where avv.CODIGO_ARTICULO = a.codigo_articulo
                        and avv.CODIGO_DIVISA   = 'EUR'
                        and avv.CODIGO_ALMACEN  = '00'
                        and avv.CODIGO_EMPRESA  = '001'), 0) as PMP,

               nvl( (select avv.ULTIMO_PRECIO_COMPRA
                       from ARTICULOS_VALORACION avv
                      where avv.CODIGO_ARTICULO = a.codigo_articulo
                        and avv.CODIGO_DIVISA   = 'EUR'
                        and avv.CODIGO_ALMACEN  = '00'
                        and avv.CODIGO_EMPRESA  = '001'), 0) as UPC,

               nvl( (select avv.PRECIO_STANDARD
                       from ARTICULOS_VALORACION avv
                      where avv.CODIGO_ARTICULO = a.codigo_articulo
                        and avv.CODIGO_DIVISA   = 'EUR'
                        and avv.CODIGO_ALMACEN  = '00'
                        and avv.CODIGO_EMPRESA  = '001'), 0) as PRECIO_STANDARD,

               /* KG (unidad1) */
               nvl((
                   select sum(s.cantidad_unidad1)
                     from stocks_detallado s
                    where s.codigo_articulo = a.codigo_articulo
                      and s.codigo_empresa  = a.codigo_empresa
                      {wh_filter_s}
                      and not exists (
                          select 1
                            from almacenes_zonas az
                           where az.codigo_empresa = s.codigo_empresa
                             and az.codigo_almacen = s.codigo_almacen
                             and az.codigo_zona    = s.codigo_zona
                             and az.es_zona_reserva_virtual = 'S'
                      )
               ), 0) as stock_unidad1,

               /* CAJAS (unidad2) */
               nvl((
                   select sum(nvl(s.cantidad_unidad2,0))
                     from stocks_detallado s
                    where s.codigo_articulo = a.codigo_articulo
                      and s.codigo_empresa  = a.codigo_empresa
                      {wh_filter_s}
                      and not exists (
                          select 1
                            from almacenes_zonas az
                           where az.codigo_empresa = s.codigo_empresa
                             and az.codigo_almacen = s.codigo_almacen
                             and az.codigo_zona    = s.codigo_zona
                             and az.es_zona_reserva_virtual = 'S'
                      )
               ), 0) as stock_unidad2,

               nvl((
                   select sum(nvl(s.cantidad_presentacion,0))
                     from stocks_detallado s
                    where s.codigo_articulo = a.codigo_articulo
                      and s.codigo_empresa  = a.codigo_empresa
                      {wh_filter_s}
                      and not exists (
                          select 1
                            from almacenes_zonas az
                           where az.codigo_empresa = s.codigo_empresa
                             and az.codigo_almacen = s.codigo_almacen
                             and az.codigo_zona    = s.codigo_zona
                             and az.es_zona_reserva_virtual = 'S'
                      )
               ), 0) as cantidad_presentacion

        from articulos a
        where a.codigo_empresa = '001'
          and a.codigo_familia not in ('001','006','007','011','013','015','016','017')
          -- opcional: filtrar un artículo concreto
          -- and a.codigo_articulo = '40000'
    ) t
    where (t.stock_unidad1 <> 0 or t.stock_unidad2 <> 0)
    order by t.d_codigo_familia, t.d_codigo_subfamilia, t.descrip_comercial
    """

    # Si tu wrapper acepta binds dict (como usaste antes), pásalos aquí:
    return oracle.consult(sql, binds) if binds else oracle.consult(sql)

