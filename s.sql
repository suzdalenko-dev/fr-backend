     SELECT A.CODIGO_EMPRESA    
    , A.CODIGO_ARTICULO||'_'||A.CODIGO_EMPRESA AS PRIMARY_KEY_ARTICULO    
    , A.CODIGO_ALMACEN||'_'||A.CODIGO_EMPRESA AS PRIMARY_KEY_ALMACEN    
    , A.CODIGO_ZONA||'_'||A.CODIGO_ALMACEN||'_'||A.CODIGO_EMPRESA AS PRIMARY_KEY_ALM_ZONA    
    , A.TIPO_SITUACION||'_'||A.CODIGO_EMPRESA AS PRIMARY_KEY_TIP_SITUACION    
    , C.CODIGO_FAMILIA||'_'||C.CODIGO_EMPRESA AS PRIMARY_KEY_FAMILIA    
    , C.CODIGO_ESTAD2||'_'||C.CODIGO_EMPRESA AS PRIMARY_KEY_SUBFAMILIA  
    , C.CODIGO_ESTAD3||'_'||C.CODIGO_EMPRESA AS PRIMARY_KEY_CLASIFICACION 
    , C.CODIGO_ESTAD4||'_'||C.CODIGO_EMPRESA AS PRIMARY_KEY_PRESENTACION  
    , C.CODIGO_ESTAD5||'_'||C.CODIGO_EMPRESA AS PRIMARY_KEY_NOMBRE_COMUN
    , C.CODIGO_ESTAD6||'_'||C.CODIGO_EMPRESA AS PRIMARY_KEY_PROPIEDAD_DESTINO
    , C.CODIGO_ESTAD7||'_'||C.CODIGO_EMPRESA AS PRIMARY_KEY_TIPO_MATERIAL 
    , A.CODIGO_ALMACEN    
    , A.CODIGO_ARTICULO    
    , A.TIPO_SITUACION    
    , A.EJERCICIO    
    , A.NUMERO_PERIODO --, A.NUMERO_PERIODO||'-'||A.EJERCICIO AS PK_PERIODO_FECHA    
    , TO_CHAR(TO_DATE('01/' || A.NUMERO_PERIODO || '/' || A.EJERCICIO, 'DD/MM/YYYY'),'DD/MM/YYYY') AS FECHA    
    , A.CODIGO_ZONA    
    , A.PRESENTACION   
    , SUM(A.STOCK_PRESENTACION) AS STOCK_PRESENTACION    
    , SUM(A.STOCK_UNIDAD1) AS STOCK_UNIDAD1    
    , SUM(A.STOCK_UNIDAD2) AS STOCK_UNIDAD2    
    , SUM(B.PRECIO_MEDIO_PONDERADO) AS PRECIO_MEDIO_PONDERADO    
    , SUM(A.STOCK_PRESENTACION) * SUM(B.PRECIO_MEDIO_PONDERADO) AS IMPORTE  
    ,C.CODIGO_FAMILIA
    ,C.CODIGO_ESTAD2
    , C.CODIGO_ESTAD3
    ,C.CODIGO_ESTAD4
    ,C.CODIGO_ESTAD5
    ,C.CODIGO_ESTAD6
    ,C.CODIGO_ESTAD7
    FROM HISTORICO_STOCKS A     
    LEFT JOIN HISTORICO_VALORACION B        
    ON A.CODIGO_aRTICULO = B.CODIGO_aRTICULO                
    AND A.CODIGO_ALMACEN = B.CODIGO_ALMACEN                
    AND A.CODIGO_EMPRESA = B.CODIGO_EMPRESA                
    AND A.NUMERO_PERIODO = B.NUMERO_PERIODO                
    AND A.EJERCICIO = B.EJERCICIO    
    JOIN ARTICULOS  C        
    ON C.CODIGO_ARTICULO = A.CODIGO_ARTICULO        
    AND C.CODIGO_EMPRESA = A.CODIGO_EMPRESA   
    WHERE A.EJERCICIO >= TO_NUMBER(to_char(sysdate,'YYYY')) -2       
    GROUP BY A.CODIGO_EMPRESA    
    , A.CODIGO_ALMACEN    
    , A.CODIGO_ARTICULO    
    , A.TIPO_SITUACION    
    , A.EJERCICIO    
    , A.NUMERO_PERIODO    
    , A.PRESENTACION    
    , A.CODIGO_ZONA    
    , C.CODIGO_FAMILIA||'_'||C.CODIGO_EMPRESA
    , C.CODIGO_ESTAD2||'_'||C.CODIGO_EMPRESA 
    , C.CODIGO_ESTAD3||'_'||C.CODIGO_EMPRESA 
    , C.CODIGO_ESTAD4||'_'||C.CODIGO_EMPRESA 
    , C.CODIGO_ESTAD5||'_'||C.CODIGO_EMPRESA 
    , C.CODIGO_ESTAD6||'_'||C.CODIGO_EMPRESA 
    , C.CODIGO_ESTAD7||'_'||C.CODIGO_EMPRESA 
    ,C.CODIGO_FAMILIA
    ,C.CODIGO_ESTAD2
    , C.CODIGO_ESTAD3
    ,C.CODIGO_ESTAD4
    ,C.CODIGO_ESTAD5
    ,C.CODIGO_ESTAD6
    ,C.CODIGO_ESTAD7;

select hist.STOCK_PRESENTACION
from HISTORICO_STOCKS hist
where codigo_articulo = '40000'
  and hist.STOCK_PRESENTACION <> 0
;


select *
from HISTORICO_STOCKS
where codigo_articulo = '40000'
 and ejercicio = 2025
;


select *
from ALBARAN_COMPRAS_C acc
where numero_doc_ext = '132/4'
  and acc.NUMERO_DOC_INTERNO = '5346'
;

select *
from albaran_compras_l
where NUMERO_DOC_INTERNO = '5610'
;

-- SP001/FRO/2025-1
-- SP001/FRO/2025-2

-- factura FA02-0003077 => (2 albaranes 5642 y 5827 Facturados)

select *
from facturas_compras_lin
where num_albaran_int = '5536'
;

select *
from facturas_compras_lin
where numero_factura = '010725/XK'
;

SELECT *
FROM FACTURAS_COMPRAS_CAB 
where numero_factura = 'FA02-0003077'
;

SELECT * 
FROM facturas_compras_lin 
WHERE num_albaran_int = '5536';

select * from FACTURAS_COMPRAS_CAB;

SELECT c.NUMERO_DOC_EXT,
      c.NUMERO_DOC_INTERNO,
      TO_CHAR(c.FECHA, 'DD/MM/YYYY') AS FECHA,
      c.CODIGO_ALMACEN,
      (select a.NOMBRE from ALMACENES a WHERE a.ALMACEN = c.CODIGO_ALMACEN) AS D_ALMACEN,
      c.TIPO_PEDIDO_COM,
      (SELECT t.DESCRIPCION
         FROM TIPOS_PEDIDO_COM t
        WHERE t.TIPO_PEDIDO = c.TIPO_PEDIDO_COM AND t.ORGANIZACION_COMPRAS = c.ORGANIZACION_COMPRAS) AS D_TIPO_PEDIDO_COM,
      CODIGO_PROVEEDOR,
      (SELECT prlv.nombre
          FROM proveedores prlv
          WHERE prlv.codigo_rapido = c.codigo_proveedor AND prlv.codigo_empresa = c.codigo_empresa) AS D_CODIGO_PROVEEDOR,
      (SELECT SUM(acl.IMPORTE_LIN_NETO_DIV) from albaran_compras_l acl where acl.numero_doc_interno = c.NUMERO_DOC_INTERNO) AS IMPORTE_LIN_NETO_DIV,
      (SELECT MAX(acl.DIVISA) from albaran_compras_l acl where acl.numero_doc_interno = c.NUMERO_DOC_INTERNO) AS DIVISA,
      (SELECT SUM(acl.IMPORTE_LIN_NETO) from albaran_compras_l acl where acl.numero_doc_interno = c.NUMERO_DOC_INTERNO) AS IMPORTE_LIN_NETO
FROM ALBARAN_COMPRAS_C c
WHERE c.CODIGO_EMPRESA = '001'
    AND c.ORGANIZACION_COMPRAS = '01'
    AND c.CENTRO_CONTABLE IN (
        SELECT DISTINCT gru.CODIGO_CENTRO
        FROM CENTROS_GRUPO_CCONT gru
        WHERE gru.EMPRESA = c.CODIGO_EMPRESA AND gru.CODIGO_GRUPO = '01')
    AND EXISTS (
        SELECT 1
        FROM ALBARAN_COMPRAS_L li
        WHERE li.NUMERO_DOC_INTERNO = c.NUMERO_DOC_INTERNO AND li.CODIGO_EMPRESA = c.CODIGO_EMPRESA)
    AND c.STATUS_ANULADO = 'N'
    AND c.CODIGO_ALMACEN = '98'
    -- AND TO_CHAR(c.FECHA, 'YYYY-MM-DD') >= '2025-09-01'
    -- AND TO_CHAR(c.FECHA, 'YYYY-MM-DD') <= '2025-09-30'    

    and NUMERO_DOC_INTERNO = '5537'
ORDER BY c.FECHA DESC;


-- 1. albaranes 98 facturados !!!

select fecha, numero_doc_interno, numero_doc_ext
from ALBARAN_COMPRAS_C alc
where centro_contable = '01'
  and organizacion_compras = '01'
  and codigo_empresa = '001'
  and codigo_almacen = '98'

  and TO_CHAR(alc.FECHA, 'YYYY-MM-DD') >= '2025-08-27'
  and TO_CHAR(alc.FECHA, 'YYYY-MM-DD') <= '2025-08-29'
;

-- 2. busco la facturas



-- 3. vuelvo a ver los albaranes que se añ


SELECT GC1 EMPRESA, D_GC1 NOMBRE, GC2 FECHA, GN1 VALOR_CAMBIO
FROM (
    SELECT EMPRESA GC1,
           DECODE(froxa_seguros_cambio.empresa,NULL,NULL,
                  (SELECT lvemp.nombre 
                     FROM empresas_conta lvemp 
                    WHERE lvemp.codigo = froxa_seguros_cambio.empresa)) D_GC1,
           PERIODO GC2,
           CAMBIO GN1
    FROM FROXA_SEGUROS_CAMBIO
    ORDER BY PERIODO DESC
)
WHERE ROWNUM = 1;


select CAMBIO CAMBIOMES
from froxa_seguros_cambio
where PERIODO = '202508'
;

select fsc.CAMBIO from froxa_seguros_cambio fsc where fsc.PERIODO = '202508';