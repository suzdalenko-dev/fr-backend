select *
from (
    select a.codigo_articulo,
           a.descrip_comercial,
           a.codigo_familia as familia,
           (select f.descripcion  from familias f where f.numero_tabla = '1' and f.codigo_familia = a.codigo_familia and f.codigo_empresa = '001') as d_codigo_familia,
           a.codigo_estad2 as subfamilia,
           (select f.descripcion  from familias f where f.numero_tabla = '2' and f.codigo_familia = a.codigo_estad2 and f.codigo_empresa = '001') as d_codigo_subfamilia,
           (select pl.precio_consumo from precios_listas pl where pl.codigo_articulo = a.codigo_articulo and pl.organizacion_comercial = '01' and pl.divisa = 'EUR' and pl.numero_lista = '1' order by pl.fecha_validez desc fetch first 1 row only) AS PVP,
           (select avv.PRECIO_MEDIO_PONDERADO from ARTICULOS_VALORACION avv where avv.CODIGO_ARTICULO = a.codigo_articulo AND avv.CODIGO_DIVISA = 'EUR' AND avv.CODIGO_ALMACEN = '00' AND avv.CODIGO_EMPRESA = '001') AS PMP,
           (select avv.ULTIMO_PRECIO_COMPRA from ARTICULOS_VALORACION avv where avv.CODIGO_ARTICULO = a.codigo_articulo AND avv.CODIGO_DIVISA = 'EUR' AND avv.CODIGO_ALMACEN = '00' AND avv.CODIGO_EMPRESA = '001') AS UPC,
           (select avv.PRECIO_STANDARD from ARTICULOS_VALORACION avv where avv.CODIGO_ARTICULO = a.codigo_articulo AND avv.CODIGO_DIVISA = 'EUR' AND avv.CODIGO_ALMACEN = '00' AND avv.CODIGO_EMPRESA = '001') AS PRECIO_STANDARD,
           nvl((
             select sum(s.cantidad_unidad1)
               from stocks_detallado s
              where s.codigo_articulo = a.codigo_articulo
                and s.codigo_empresa  = a.codigo_empresa
                and not exists (
                      select 1
                        from almacenes_zonas az
                       where az.codigo_empresa = s.codigo_empresa
                         and az.codigo_almacen = s.codigo_almacen
                         and az.codigo_zona    = s.codigo_zona
                         and az.es_zona_reserva_virtual = 'S'
                    )
           ),0) as stock_unidad1,

           nvl((
             select sum(nvl(s.cantidad_unidad2,0))
               from stocks_detallado s
              where s.codigo_articulo = a.codigo_articulo
                and s.codigo_empresa  = a.codigo_empresa
                and not exists (
                      select 1
                        from almacenes_zonas az
                       where az.codigo_empresa = s.codigo_empresa
                         and az.codigo_almacen = s.codigo_almacen
                         and az.codigo_zona    = s.codigo_zona
                         and az.es_zona_reserva_virtual = 'S'
                    )
           ),0) as stock_unidad2,

           nvl((
             select sum(nvl(s.cantidad_presentacion,0))
               from stocks_detallado s
              where s.codigo_articulo = a.codigo_articulo
                and s.codigo_empresa  = a.codigo_empresa
                and not exists (
                      select 1
                        from almacenes_zonas az
                       where az.codigo_empresa = s.codigo_empresa
                         and az.codigo_almacen = s.codigo_almacen
                         and az.codigo_zona    = s.codigo_zona
                         and az.es_zona_reserva_virtual = 'S'
                    )
           ),0) as cantidad_presentacion
    from articulos a
    where  a.codigo_empresa  = '001' 
      -- and a.codigo_articulo = '40000'
) t
where t.stock_unidad1 <> 0
   or t.stock_unidad2 <> 0;



select *
from precios_listas pl 
where pl.codigo_articulo = '40054' 
  and pl.organizacion_comercial = '01' 
  and pl.divisa = 'EUR' and pl.numero_lista = '1' order by pl.fecha_validez desc fetch first 1 row only;