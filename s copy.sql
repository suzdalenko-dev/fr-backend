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

-- drrWq9SNsFJH                     NUM_ORDEN_FAB
-- A producto acabado  40000
-- V material auxiliar 80000, 89000
-- M producto comercial 40018
-- P materia prima 40020
-- S producto semielaborado 40570
-- T texto 90004
-- F  82000

select CODIGO_ARTICULO, TIPO_MATERIAL
from articulos
where CODIGO_ARTICULO IN ('40570', '40018')
;

select DISTINCT TIPO_MATERIAL, MIN(CODIGO_ARTICULO)
from articulos
GROUP BY TIPO_MATERIAL
ORDER BY TIPO_MATERIAL
;

select TIPO_MATERIAL, CODIGO_ARTICULO
from articulos
where TIPO_MATERIAL = 'F'
;

select * 
from historico_lotes
where numero_lote_int = '170725'
;

select * -- SUM(CANTIDAD_UNIDAD1) AS TOTAL
from HISTORICO_MOVIM_ALMACEN
where  '1'='1'
-- and codigo_movimiento = '2001L'
-- and ORDEN_DE_FABRICACION = '1039'
-- and NUMERO_DOC_INTERNO  = '2771'
 and codigo_articulo = '86002'
;

select  SUM(CANT_REAL_CONSUMO_UNIDAD1) AS CONSUMIDO
from OF_MATERIALES_UTILIZADOS
where ORDEN_DE_FABRICACION = '1039'
    and CODIGO_COMPONENTE = '41025'
;
-- donde se ve que se ha gastodo esto 86002
-- desde el aqui obtengo el numero de documento interno NUMERO_DOC_INTERNO 2771, NUM_PARTE_TRABAJO 2
select *
from OF_PARTES_DE_TRABAJO
where ORDEN_DE_FABRICACION = '1039'
;

select *
from ORDENES_FABRICA_COMPO
WHERE ORDEN_DE_FABRICACION = '1039'
;

select *
from OF_MATERIALES_UTILIZADOS
WHERE ORDEN_DE_FABRICACION = '927'
;

select ORDEN_DE_FABRICACION,
    CODIGO_ARTICULO_PRODUCIDO,
    NUMERO_LOTE_INT_PRODUCIDO,
    CODIGO_ARTICULO_CONSUMIDO,
    (select DESCRIP_COMERCIAL from articulos where codigo_articulo = CODIGO_ARTICULO_CONSUMIDO) AS DESCRIP_CONSUMIDO,
    (select unidad_codigo1 from  articulos where codigo_articulo = CODIGO_ARTICULO_CONSUMIDO) AS CODIGO_PRESENTACION,
    NUMERO_LOTE_INT_CONSUMIDO,
    CANTIDAD_UNIDAD1,
    (select MAX(FECHA_CREACION) from historico_lotes where NUMERO_LOTE_INT  = NUMERO_LOTE_INT_CONSUMIDO and CODIGO_ARTICULO =  CODIGO_ARTICULO_CONSUMIDO) AS FECHA_CREACION,
    (select MAX(FECHA_CADUCIDAD) from historico_lotes where NUMERO_LOTE_INT = NUMERO_LOTE_INT_CONSUMIDO and CODIGO_ARTICULO =  CODIGO_ARTICULO_CONSUMIDO) AS FECHA_CADUCIDAD
from COSTES_ORDENES_FAB_MAT_CTD
where ORDEN_DE_FABRICACION = '1039';

select om.ORDEN_DE_FABRICACION,
    om.CODIGO_COMPONENTE AS CODIGO_ARTICULO_CONSUMIDO,
    om.DESC_ARTICULO AS DESCRIP_CONSUMIDO,
    om.CODIGO_PRESENTACION_COMPO AS CODIGO_PRESENTACION,
    om.NUMERO_LOTE_INT AS NUMERO_LOTE_INT_CONSUMIDO,
    om.CANT_REAL_CONSUMO_UNIDAD1 AS CANTIDAD_UNIDAD1,
    (select MAX(hl.FECHA_CREACION) from historico_lotes hl where hl.NUMERO_LOTE_INT  = om.NUMERO_LOTE_INT and hl.CODIGO_ARTICULO =  om.CODIGO_COMPONENTE) AS FECHA_CREACION,
    (select MAX(hl.FECHA_CADUCIDAD) from historico_lotes hl where hl.NUMERO_LOTE_INT = om.NUMERO_LOTE_INT and hl.CODIGO_ARTICULO =  om.CODIGO_COMPONENTE) AS FECHA_CADUCIDAD
from OF_MATERIALES_UTILIZADOS om
where om.ORDEN_DE_FABRICACION = '1039'
;

select *  
from OF_MATERIALES_UTILIZADOS
where ORDEN_DE_FABRICACION = '1039'
;