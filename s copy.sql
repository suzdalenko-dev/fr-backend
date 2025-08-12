select * 
from PEDIDOS_VENTAS
where numero_serie = 'ENT'
    and NUMERO_PEDIDO = 26
    and EJERCICIO = 2025
;

select * 
from PEDIDOS_VENTAS_LIN
where numero_serie = 'PN'
    and NUMERO_PEDIDO = 4454
    and EJERCICIO = 2025    
;

select ARTICULO, DESCRIPCION_ARTICULO, CANTIDAD_PEDIDA, PRESENTACION_PEDIDO, UNI_PEDALM
from PEDIDOS_VENTAS_LIN
where numero_serie = 'PN'
    and NUMERO_PEDIDO = 4454
    and EJERCICIO = 2025    
;

-- select ARTICULO, DESCRIPCION_ARTICULO, UNIDADES_SERVIDAS, UNI_SERALM, UNI_SERALM2, PRESENTACION_PEDIDO
select *
from ALBARAN_VENTAS_LIN
where NUMERO_PEDIDO = 3578
    AND NUMERO_SERIE_PEDIDO = 'PN'
    AND EJERCICIO_PEDIDO = 2025
;


select CONVERS_U_DIS
from CADENA_LOGISTICA
where codigo_articulo = '40197'
;

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
    v_froxa_stocks_nacional.cantidad_con n3,
    (SELECT MAX(av.precio_standard) 
        FROM articulos_valoracion av 
        WHERE av.codigo_empresa(+) = V_FROXA_STOCKS_NACIONAL.codigo_empresa
            AND av.codigo_articulo(+) = V_FROXA_STOCKS_NACIONAL.codigo_articulo    
            AND av.codigo_almacen(+) = '00'
            AND av.ejercicio = (SELECT MAX(av2.ejercicio)
                                FROM articulos_valoracion av2
                                WHERE av2.codigo_empresa(+) = V_FROXA_STOCKS_NACIONAL.codigo_empresa
                                    AND av2.codigo_articulo(+) = V_FROXA_STOCKS_NACIONAL.codigo_articulo
                                    AND av2.codigo_almacen(+) = '00')
    ) n4,
    v_froxa_stocks_nacional.precio_medio_ponderado n5,
    v_froxa_stocks_nacional.valor_pmp n6,
    v_froxa_stocks_nacional.ultimo_precio_compra n7,
    v_froxa_stocks_nacional.valor_upc n8,
    v_froxa_stocks_nacional.precio_consumo n9,
    v_froxa_stocks_nacional.margen_pvp n10,
    v_froxa_stocks_nacional.valor_pvp n11,
    v_froxa_stocks_nacional.margen_unitario n12
FROM V_FROXA_STOCKS_NACIONAL,
    (SELECT ARTICULOS.*,
        DECODE(articulos.codigo_familia, NULL, NULL, 
            (SELECT lvfm.descripcion 
                FROM familias lvfm 
                WHERE lvfm.codigo_familia = articulos.codigo_familia 
                AND lvfm.numero_tabla = 1 
                AND lvfm.codigo_empresa = articulos.codigo_empresa)) D_CODIGO_FAMILIA,
        DECODE(articulos.codigo_estad2,NULL,NULL,
            (SELECT lvfm.descripcion 
            FROM familias lvfm 
            WHERE lvfm.codigo_familia = articulos.codigo_estad2 
                AND lvfm.numero_tabla = 2 
                AND lvfm.codigo_empresa = articulos.codigo_empresa)) D_CODIGO_ESTAD2 
            FROM ARTICULOS) ARTICULOS 
                WHERE (V_FROXA_STOCKS_NACIONAL.CODIGO_EMPRESA= '001' 
                    and V_FROXA_STOCKS_NACIONAL.CODIGO_EMPRESA=ARTICULOS.CODIGO_EMPRESA 
                    and V_FROXA_STOCKS_NACIONAL.CODIGO_ARTICULO=ARTICULOS.CODIGO_ARTICULO) 
                    AND (articulos.codigo_empresa = '001') 
                    AND v_froxa_stocks_nacional.codigo_almacen IN ('00') 
                    AND articulos.codigo_familia IN ('004') 
                    AND articulos.codigo_estad2 IN ('028');



SELECT  SUBSTR(articulos.d_codigo_familia,1,20) AS FAMILIA,
        SUBSTR(articulos.d_codigo_estad2,1,20) AS SUBFAMILIA,
        SUBSTR(v_froxa_stocks_nacional.codigo_almacen,1,5) AS ALMACEN,
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
                -- AND v_froxa_stocks_nacional.codigo_articulo = '40058'
                AND v_froxa_stocks_nacional.cliente LIKE '999999%';


select * 
from V_FROXA_STOCKS_NACIONAL
where PRECIO_CONSUMO > 0
;


select CONVERS_U_SOB, CONVERS_U_DIS 
from CADENA_LOGISTICA
    where CODIGO_ARTICULO = '40007'
;