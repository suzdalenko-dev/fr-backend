select *
from ARTICULOS
;

-- lineas albaran compras alm. 90
SELECT SUM(nvl(importe_lin_neto_div,importe_lin_neto) IMPORTE), MIN(DIVISA)
FROM albaran_compras_l
WHERE NUMERO_DOC_INTERNO = '5468' AND CODIGO_EMPRESA = '001'
;

-- LINEAS ALBARAN alm. 00
SELECT CODIGO_ARTICULO, nvl(importe_lin_neto_div,importe_lin_neto) IMPORTE, DIVISA
FROM albaran_compras_l
WHERE NUMERO_DOC_INTERNO = '5582' AND CODIGO_EMPRESA = '001'
;

-- LINEAS ALBARAN alm. 25 DE GASTO EUR
SELECT CODIGO_ARTICULO, nvl(importe_lin_neto_div,importe_lin_neto) IMPORTE, DIVISA
FROM albaran_compras_l
WHERE NUMERO_DOC_INTERNO = '5451' AND CODIGO_EMPRESA = '001'
;

SELECT DIVISA_ORIGEN, 
        DIVISA_DESTINO, 
        FECHA_VALOR,
        VALOR_COMPRA,
        VALOR_VENTA
        FROM (SELECT cambio_divisas.* ,(SELECT lvdiv.nombre FROM divisas lvdiv WHERE lvdiv.codigo = cambio_divisas.divisa_destino) D_DIVISA_DESTINO,(SELECT lvdiv.nombre FROM divisas lvdiv WHERE lvdiv.codigo = cambio_divisas.divisa_origen) D_DIVISA_ORIGEN FROM cambio_divisas) cambio_divisas 
        where fecha_valor >= '01/02/2025' 
        order by fecha_valor asc;


SELECT GC1,D_GC1,GC2, GN1 FROM (SELECT EMPRESA GC1,DECODE(froxa_seguros_cambio.empresa,NULL,NULL,(SELECT lvemp.nombre FROM empresas_conta lvemp WHERE lvemp.codigo = froxa_seguros_cambio.empresa)) D_GC1,PERIODO GC2,CAMBIO GN1,NULL GN2,NULL GN3,NULL GN4,NULL GN5,NULL GN6,NULL GN7,NULL GN8,NULL GN9,NULL GN10,NULL GN11,NULL GN12,NULL GN13,NULL GN14,NULL GN15,NULL GN16,NULL GN17,NULL GN18,NULL GN19,NULL GN20,NULL GN21,NULL GN22,NULL GN23,NULL GN24,NULL GN25,NULL GC3,NULL GC4,NULL GC5,NULL GC6,NULL GC7,NULL GC8,NULL GC9,NULL GC10,NULL GC11,NULL GC12,NULL GC13,NULL GC14,NULL GC15,NULL GC16,NULL GC17,NULL GC18,NULL GC19,NULL GC20,NULL GC21,NULL GC22,NULL GC23,NULL GC24,NULL GC25,NULL GD1,NULL GD2,NULL GD3,NULL GD4,NULL GD5,NULL GD6,NULL GD7,NULL GD8,NULL GD9,NULL GD10,NULL GD11,NULL GD12,NULL GD13,NULL GD14,NULL GD15,NULL GD16,NULL GD17,NULL GD18,NULL GD19,NULL GD20,NULL GD21,NULL GD22,NULL GD23,NULL GD24,NULL GD25,NULL GCHECK1,NULL GCHECK2,NULL GCHECK3,NULL GCHECK4,NULL GCHECK5,NULL GCHECK6,NULL GCHECK7,NULL GCHECK8,NULL GCHECK9,NULL GCHECK10,NULL GCHECK11,NULL GCHECK12,NULL GCHECK13,NULL GCHECK14,NULL GCHECK15,NULL GCHECK16,NULL GCHECK17,NULL GCHECK18,NULL GCHECK19,NULL GCHECK20,NULL GCHECK21,NULL GCHECK22,NULL GCHECK23,NULL GCHECK24,NULL GCHECK25,NULL N1,NULL N2,NULL N3,NULL N4,NULL N5,NULL N6,NULL N7,NULL N8,NULL N9,NULL N10,NULL N11,NULL N12,NULL N13,NULL N14,NULL N15,NULL N16,NULL N17,NULL N18,NULL N19,NULL N20,NULL N21,NULL N22,NULL N23,NULL N24,NULL N25,NULL N26,NULL N27,NULL N28,NULL N29,NULL N30,NULL C1,NULL C2,NULL C3,NULL C4,NULL C5,NULL C6,NULL C7,NULL C8,NULL C9,NULL C10,NULL C11,NULL C12,NULL C13,NULL C14,NULL C15,NULL C16,NULL C17,NULL C18,NULL C19,NULL C20,NULL C21,NULL C22,NULL C23,NULL C24,NULL C25,NULL C26,NULL C27,NULL C28,NULL C29,NULL C30,NULL D1,NULL D2,NULL D3,NULL D4,NULL D5,NULL D6,NULL D7,NULL D8,NULL D9,NULL D10,NULL D11,NULL D12,NULL D13,NULL D14,NULL D15,NULL D16,NULL D17,NULL D18,NULL D19,NULL D20,NULL D21,NULL D22,NULL D23,NULL D24,NULL D25,NULL D26,NULL D27,NULL D28,NULL D29,NULL D30,NULL CHECK1,NULL CHECK2,NULL CHECK3,NULL CHECK4,NULL CHECK5,NULL CHECK6,NULL CHECK7,NULL CHECK8,NULL CHECK9,NULL CHECK10,NULL CHECK11,NULL CHECK12,NULL CHECK13,NULL CHECK14,NULL CHECK15,NULL CHECK16,NULL CHECK17,NULL CHECK18,NULL CHECK19,NULL CHECK20,NULL CHECK21,NULL CHECK22,NULL CHECK23,NULL CHECK24,NULL CHECK25,NULL CHECK26,NULL CHECK27,NULL CHECK28,NULL CHECK29,NULL CHECK30,NULL LIST1,NULL LIST2,NULL LIST3,NULL LIST4,NULL LIST5,NULL LIST6,NULL LIST7,NULL LIST8,NULL LIST9,NULL LIST10,NULL TEXTAREA1,NULL TEXTAREA2,NULL D_GC2,NULL D_GC3,NULL D_GC4,NULL D_GC5,NULL D_GC6,NULL D_GC7,NULL D_GC8,NULL D_GC9,NULL D_GC10,NULL D_GC11,NULL D_GC12,NULL D_GC13,NULL D_GC14,NULL D_GC15,NULL D_GC16,NULL D_GC17,NULL D_GC18,NULL D_GC19,NULL D_GC20,NULL D_GC21,NULL D_GC22,NULL D_GC23,NULL D_GC24,NULL D_GC25,NULL D_GN0,NULL D_GN1,NULL D_GN2,NULL D_GN3,NULL D_GN4,NULL D_GN5,NULL D_GN6,NULL D_GN7,NULL D_GN8,NULL D_GN9,NULL D_GN10,NULL D_GN11,NULL D_GN12,NULL D_GN13,NULL D_GN14,NULL D_GN15,NULL D_GN16,NULL D_GN17,NULL D_GN18,NULL D_GN19,NULL D_GN20,NULL D_GN21,NULL D_GN22,NULL D_GN23,NULL D_GN24,NULL D_GN25,NULL D_C1,NULL D_C2,NULL D_C3,NULL D_C4,NULL D_C5,NULL D_C6,NULL D_C7,NULL D_C8,NULL D_C9,NULL D_C10,NULL D_C11,NULL D_C12,NULL D_C13,NULL D_C14,NULL D_C15,NULL D_C16,NULL D_C17,NULL D_C18,NULL D_C19,NULL D_C20,NULL D_C21,NULL D_C22,NULL D_C23,NULL D_C24,NULL D_C25,NULL D_C26,NULL D_C27,NULL D_C28,NULL D_C29,NULL D_C30,NULL D_N1,NULL D_N2,NULL D_N3,NULL D_N4,NULL D_N5,NULL D_N6,NULL D_N7,NULL D_N8,NULL D_N9,NULL D_N10,NULL D_N11,NULL D_N12,NULL D_N13,NULL D_N14,NULL D_N15,NULL D_N16,NULL D_N17,NULL D_N18,NULL D_N19,NULL D_N20,NULL D_N21,NULL D_N22,NULL D_N23,NULL D_N24,NULL D_N25,NULL D_N26,NULL D_N27,NULL D_N28,NULL D_N29,NULL D_N30,NULL GN0,NULL GD0,rowid int_rowid FROM FROXA_SEGUROS_CAMBIO) FROXA_SEGUROS_CAMBIO WHERE 8=8 order by GC2 DESC;


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



SELECT
  (SELECT fam.descripcion 
    FROM familias fam where fam.numero_tabla = '7' AND fam.codigo_familia = (
      SELECT artic.codigo_estad7  FROM ARTICULOS artic WHERE artic.CODIGO_ARTICULO =  om.CODIGO_COMPONENTE  AND ROWNUM = 1 )) AS tipo_descr,
  (SELECT TO_CHAR(OFB.FECHA_INI_FABRI, 'YYYY-MM-DD') FROM ORDENES_FABRICA_CAB OFB WHERE OFB.ORDEN_DE_FABRICACION = om.ORDEN_DE_FABRICACION) AS FECHA_INI_FABRI,
  ((SELECT descrip_comercial FROM articulos artx WHERE artx.CODIGO_ARTICULO = om.CODIGO_COMPONENTE)  || ' ' || om.CODIGO_COMPONENTE) AS NOMBRE_ARTICULO,      
  om.CODIGO_PRESENTACION_COMPO,
  TO_NUMBER(om.CANT_REAL_CONSUMO_UNIDAD1) CANTIDAD_UNIDAD1,
  om.ORDEN_DE_FABRICACION,
  (SELECT f.descripcion FROM familias f WHERE f.numero_tabla = '1' AND f.codigo_empresa = '001' AND f.codigo_familia = (
       SELECT a.codigo_familia FROM articulos a WHERE a.codigo_articulo = om.CODIGO_COMPONENTE AND a.codigo_empresa = '001')
  ) AS D_CODIGO_FAMILIA,
  (SELECT f2.descripcion FROM familias f2 WHERE f2.numero_tabla = '2' AND f2.codigo_empresa = '001' AND f2.codigo_familia = (
       SELECT a2.codigo_estad2 FROM articulos a2 WHERE a2.codigo_articulo = om.CODIGO_COMPONENTE AND a2.codigo_empresa = '001')
  ) AS SUBFAMILIA
FROM OF_MATERIALES_UTILIZADOS om;



-- viejo

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
FROM COSTES_ORDENES_FAB_MAT_CTD c;


select *
from ORDENES_FABRICA_CAB;

select COSTES_ORDENES_FAB_MAT_CTD.ORDEN_DE_FABRICACION, CANTIDAD_UNIDAD1 -- 27000
from COSTES_ORDENES_FAB_MAT_CTD
join ORDENES_FABRICA_CAB ofc on ofc.ORDEN_DE_FABRICACION = COSTES_ORDENES_FAB_MAT_CTD.ORDEN_DE_FABRICACION
where ofc.FECHA_INI_FABRI >= to_date('2025-07-01','YYYY-MM-DD')
and ofc.FECHA_INI_FABRI <= to_date('2025-07-31','YYYY-MM-DD')
and COSTES_ORDENES_FAB_MAT_CTD.CODIGO_ARTICULO_CONSUMIDO = '40095'
;


select  SUM(CANT_REAL_CONSUMO_UNIDAD1) 
from OF_MATERIALES_UTILIZADOS
where CODIGO_COMPONENTE = '40095'
and fecha_fabricacion >= to_date('2025-07-01','YYYY-MM-DD')
and fecha_fabricacion <= to_date('2025-07-31','YYYY-MM-DD')
-- GROUP BY ORDEN_DE_FABRICACION
; 























SELECT CENTRO_CONTABLE,ALMACEN,D_CENTRO_CONTABLE,D_ALMACEN,ZONA_ALMACEN,D_ZONA_ALMACEN,LOTE_EXT,NUMERO_LOTE_INT_ANTERIOR,TIPO_SITUACION,CLIENTE,D_CLIENTE,D_CLIENTE_MIRROR,CODIGO_PROVEEDOR,D_CODIGO_PROVEEDOR,LOTE,LOTE_AUX,NUMERO_LOTE_INT,NUMERO_LOTE_INT_AUX,DESCRIPCION_ARTICULO_MIRROR,CODIGO_ARTICULO,DESCRIPCION_PARTIDA_MIRROR,UBICACION,SSCC,PALET,MAREA,D_MAREA,BARCO_LOTE,D_BARCO_LOTE,BUQUE,D_BUQUE,CANTIDAD_CON,PRECIO_COSTE,CANTIDAD_SUB,CANTIDAD_SOB,CANTIDAD_DIS,CANTIDAD_EXP,CANTIDAD_ALMACEN1,UNIDAD_CODIGO1,CANTIDAD_ALMACEN2,UNIDAD_CODIGO2,CANTIDAD_ALMACEN12,CANTIDAD_ALMACEN22,DESCARGA_FINALIZADA,CANTIDAD_CON2,CANTIDAD_SUB2,CANTIDAD_SOB2,CANTIDAD_DIS2,CANTIDAD_EXP2,COSTE,D_TIPO_SITUACION,D_NUMERO_LOTE_INT,DESCRIPCION_ARTICULO,CODIGO_ARTICULO_MIRROR,TIPO_PALET,D_TIPO_PALET,FECHA_FIN_FACT_FRIO_CLI_ORIGEN,FECHA_SIGUIENTE_FACT_FRIO,NUMERO_AUTORIZACION_CLIENTE,NUMERO_TRANSPORTE,TARA_CON,TARA_SUB,TARA_SOB,TARA_DIS,TARA_EXP,EMPRESA,CANTIDAD_PEND_RECI,CODIGO_VALOR_INVENT,UNIDAD_VALORACION,CANTIDAD_PRECIO,INCLUIR_GTOS_GENER_INVENT,CLIENTE_FACTURACION_FRIO,D_CLIENTE_FACTURACION_FRIO,CENTRO_CONTABLE_FRIO,D_CENTRO_CONTABLE_FRIO,CODIGO_FAMILIA,D_CODIGO_FAMILIA,CODIGO_ESTAD2,D_CODIGO_ESTAD2,CODIGO_ESTAD3,D_CODIGO_ESTAD3,CODIGO_ESTAD4,D_CODIGO_ESTAD4,CODIGO_ESTAD5,D_CODIGO_ESTAD5,CODIGO_ESTAD6,D_CODIGO_ESTAD6,CODIGO_ESTAD7,D_CODIGO_ESTAD7,CODIGO_ESTAD8,D_CODIGO_ESTAD8,CODIGO_ESTAD9,D_CODIGO_ESTAD9,CODIGO_ESTAD10,D_CODIGO_ESTAD10,CODIGO_ESTAD11,D_CODIGO_ESTAD11,CODIGO_ESTAD12,D_CODIGO_ESTAD12,CODIGO_ESTAD13,D_CODIGO_ESTAD13,CODIGO_ESTAD14,D_CODIGO_ESTAD14,CODIGO_ESTAD15,D_CODIGO_ESTAD15,CODIGO_ESTAD16,D_CODIGO_ESTAD16,CODIGO_ESTAD17,D_CODIGO_ESTAD17,CODIGO_ESTAD18,D_CODIGO_ESTAD18,CODIGO_ESTAD19,D_CODIGO_ESTAD19,CODIGO_ESTAD20,D_CODIGO_ESTAD20,VALOR_ALFA_1,VALOR_ALFA_2,VALOR_ALFA_3,VALOR_ALFA_4,VALOR_ALFA_5,VALOR_ALFA_6,VALOR_ALFA_7,VALOR_ALFA_8,VALOR_ALFA_9,VALOR_ALFA_10,VALOR_NUM_1,VALOR_NUM_2,VALOR_NUM_3,VALOR_NUM_4,VALOR_NUM_5,VALOR_NUM_6,VALOR_NUM_7,VALOR_NUM_8,VALOR_NUM_9,VALOR_NUM_10,VALOR_FECHA_1,VALOR_FECHA_2,VALOR_FECHA_3,D_VALOR_ALFA_1,D_VALOR_ALFA_2,D_VALOR_ALFA_3,D_VALOR_ALFA_4,D_VALOR_ALFA_5,D_VALOR_ALFA_6,D_VALOR_ALFA_7,D_VALOR_ALFA_8,D_VALOR_ALFA_9,D_VALOR_ALFA_10,CODIGO_SUBREFERENCIA,ALFA3_FAO,NOMBRE_CIENTIFICO,PARTIDA_ARANCELARIA,D_PARTIDA_ARANCELARIA,REGISTRO_SANITARIO,D_REGISTRO_SANITARIO,D_LOTE_AUX,FECHA_CADUCIDAD,FECHA_CREACION,TITULO_ALFA_1,TITULO_ALFA_2,TITULO_ALFA_3,TITULO_ALFA_4,TITULO_ALFA_5,TITULO_ALFA_6,TITULO_ALFA_7,TITULO_ALFA_8,TITULO_ALFA_9,TITULO_ALFA_10,TITULO_NUM_1,TITULO_NUM_2,TITULO_NUM_3,TITULO_NUM_4,TITULO_NUM_5,TITULO_NUM_6,TITULO_NUM_7,TITULO_NUM_8,TITULO_NUM_9,TITULO_NUM_10,TITULO_FECHA_1,TITULO_FECHA_2,TITULO_FECHA_3,STOCK_DISPONIBLE,D_ALMACEN_MIRROR,CODIGO_DVD,NUMERO_DIP,FECHA_LIBERACION_DIP,ESTADO_DVD,NUMERO_DVCE,ALMACEN_MIRROR,CLIENTE_MIRROR,NUMERO_LOTE_PRO,RESERVADOA01,RESERVADOA02,RESERVADOA03,RESERVADOA04,RECIPIENTE,TIPO_RECIPIENTE,D_TIPO_RECIPIENTE,OBS_HIST_PALETS,FAO_MAREA,DOCUMENTO_ENTRADA,TIPO_DOC_ENTRADA,D_TIPO_DOC_ENTRADA,ARTICULO_MIRROR,D_ARTICULO_MIRROR,ID_DIGITAL,D_NUMERO_TRANSPORTE,CANTIDAD_NOTAS_PESCA FROM (SELECT DATOS.* ,almacen ALMACEN_MIRROR,codigo_articulo ARTICULO_MIRROR,(SELECT SUM(pl.cantidad_unidad1)
   FROM articulos ar, barcos ba, lotes lo,mareas ma, nota_pesca pc, nota_pesca_lin pl
  WHERE pc.empresa = pl.empresa
    AND pc.codigo = pl.codigo
    AND pc.marea = pl.marea
    AND ba.codigo = ma.barco
    AND ba.empresa = ma.empresa
and lo.lote = ma.codigo_entrada
and lo.empresa = ma.empresa
and lo.descarga_finalizada='N'
    AND ar.codigo_articulo = pl.articulo
    AND ar.codigo_empresa = pl.empresa
    AND ma.empresa = pl.empresa
    AND ma.codigo = pl.marea
and pl.articulo = datos.codigo_articulo
    AND pl.empresa = datos.empresa
and ma.situacion='1000') CANTIDAD_NOTAS_PESCA,(select sum(PL.UNIDADES_PEDIDAS - PL.UNIDADES_ENTREGADAS)
FROM PARAM_COMPRAS p, articulos a, pedidos_compras pc, pedidos_compras_lin pl
         WHERE     PL.CODIGO_EMPRESA = PC.CODIGO_EMPRESA
               AND PL.ORGANIZACION_COMPRAS = PC.ORGANIZACION_COMPRAS
               AND PL.SERIE_NUMERACION = PC.SERIE_NUMERACION
               AND PL.NUMERO_PEDIDO = PC.NUMERO_PEDIDO
               AND A.CODIGO_EMPRESA = PL.CODIGO_EMPRESA
               AND A.CODIGO_ARTICULO = PL.CODIGO_ARTICULO
               and p.CODIGO_EMPRESA = pc.codigo_empresa
               and p.ORGANIZACION_COMPRAS = PC.ORGANIZACION_COMPRAS
               AND PL.STATUS_CIERRE = 'E'
               AND pl.codigo_articulo = DATOS.CODIGO_ARTICULO
      and (P.ALMACEN_DISTINTO = 'S' or (P.ALMACEN_DISTINTO = 'N' AND PC.CODIGO_ALMACEN = DATOS.ALMACEN))
     AND PL.UNIDADES_PEDIDAS - nvl(PL.UNIDADES_ENTREGADAS, 0) > 0
 AND pc.codigo_empresa = datos.empresa) CANTIDAD_PEND_RECI,cliente CLIENTE_MIRROR,CODIGO_ARTICULO_AUX CODIGO_ARTICULO_MIRROR,DESCRIPCION_ARTICULO DESCRIPCION_ARTICULO_MIRROR,(SELECT h.descripcion_lote FROM historico_lotes h WHERE h.numero_lote_int = NVL(datos.numero_lote_int_aux, datos.numero_lote_int)AND h.codigo_articulo = datos.codigo_articulo AND h.codigo_empresa = datos.empresa) DESCRIPCION_PARTIDA_MIRROR,(SELECT lval.nombre FROM almacenes lval WHERE lval.almacen = datos.almacen AND lval.codigo_empresa = datos.empresa) D_ALMACEN,datos.almacen D_ALMACEN_MIRROR,DESCRIPCION_ARTICULO D_ARTICULO_MIRROR,(SELECT lvb.nombre FROM barcos lvb WHERE lvb.codigo = datos.barco_lote AND lvb.empresa = datos.empresa ) D_BARCO_LOTE,(Select lvb.nombre from buques lvb where lvb.codigo = datos.buque and lvb.empresa =datos.empresa) D_BUQUE,(SELECT lvcc.nombre FROM caracteres_asiento lvcc WHERE lvcc.codigo = datos.centro_contable AND lvcc.empresa = datos.empresa) D_CENTRO_CONTABLE,(select ca.nombre from caracteres_asiento ca where ca.empresa=datos.empresa and ca.codigo=datos.centro_contable_frio) D_CENTRO_CONTABLE_FRIO,(SELECT c.nombre FROM clientes c WHERE c.codigo_rapido = datos.cliente AND c.codigo_empresa = datos.empresa) D_CLIENTE,(SELECT c.nombre FROM clientes c WHERE c.codigo_rapido = datos.cliente_facturacion_frio AND c.codigo_empresa = datos.empresa) D_CLIENTE_FACTURACION_FRIO,datos.cliente D_CLIENTE_MIRROR,(SELECT prlv.nombre FROM proveedores prlv WHERE prlv.codigo_rapido = datos.codigo_proveedor AND codigo_empresa = datos.empresa) D_CODIGO_PROVEEDOR,(SELECT lvlot.descripcion FROM lotes lvlot WHERE lvlot.lote = datos.lote_aux AND lvlot.empresa = datos.empresa) D_LOTE_AUX,(SELECT lvm.descripcion FROM mareas lvm WHERE lvm.codigo = datos.marea AND lvm.empresa = datos.empresa) D_MAREA,(SELECT lvrs.descripcion FROM registros_sanitarios lvrs where lvrs.numero_registro = datos.registro_sanitario and lvrs.empresa = datos.empresa) D_REGISTRO_SANITARIO,(SELECT lvtpm.descripcion FROM tipos_movimiento lvtpm WHERE lvtpm.codigo = datos.tipo_doc_entrada) D_TIPO_DOC_ENTRADA,(SELECT lvtp.descripcion FROM tipos_palet lvtp WHERE lvtp.codigo = datos.tipo_palet AND lvtp.empresa = datos.empresa) D_TIPO_PALET,(SELECT lvtp.descripcion FROM tipos_palet lvtp WHERE lvtp.codigo = datos.tipo_recipiente AND lvtp.empresa = datos.empresa) D_TIPO_RECIPIENTE,(SELECT lvts.descripcion FROM tipos_situacion lvts WHERE lvts.tipo_situacion = datos.tipo_situacion AND lvts.codigo_empresa = datos.empresa) D_TIPO_SITUACION,(SELECT lvaz.descripcion FROM almacenes_zonas lvaz WHERE lvaz.codigo_zona = datos.zona_almacen AND lvaz.codigo_almacen = datos.almacen AND lvaz.codigo_empresa = datos.empresa) D_ZONA_ALMACEN,(select NVL(id_digital, 0) from lotes l where l.empresa = DATOS.EMPRESA and l.lote = DATOS.LOTE) ID_DIGITAL,DECODE(UNID_VALORACION,  0, 0,  COSTE / UNID_VALORACION) PRECIO_COSTE,recipiente RECIPIENTE_MIRROR,NULL RESERVADOA01,NULL RESERVADOA02,NULL RESERVADOA03,NULL RESERVADOA04 FROM (SELECT m.codigo_almacen almacen,  NULL zona_almacen, m.tipo_situacion ,s.stock_disponible  ,m.numero_lote_int,   h.numero_lote_pro ,m.numero_lote_int numero_lote_int_aux, m.codigo_articulo, m.codigo_articulo codigo_articulo_aux, h.documento_entrada, h.codigo_creacion tipo_doc_entrada,  l.descarga_finalizada descarga_finalizada, ma.codigo marea, l.barco barco_lote, l.buque, ma.zona_fao fao_marea, COALESCE(alm.centro_contable, l.centro_contable_fact_frio, l.centro_contable) centro_contable_frio,  NULL coste,  NULL unid_valoracion,  NULL recipiente, NULL tipo_recipiente, NULL Obs_Hist_Palets, NULL sscc,  m.cantidad_con, m.cantidad_sub, m.cantidad_sob, m.cantidad_dis, m.cantidad_exp, DECODE(s.stock_disponible, 'N', 0, m.cantidad_con -  pk_parametros_pesca.calcula_stock_en_pedidos(m.codigo_empresa, m.codigo_cliente, NULL, NULL, NULL, NULL, NULL, m.codigo_articulo, m.numero_lote_int,h.descripcion_lote2, m.codigo_almacen, 'CON', l.centro_contable,m.tipo_situacion) ) cantidad_con2,  DECODE(s.stock_disponible, 'N', 0, m.cantidad_sub -  pk_parametros_pesca.calcula_stock_en_pedidos(m.codigo_empresa, m.codigo_cliente, NULL, NULL, NULL, NULL, NULL, m.codigo_articulo, m.numero_lote_int,h.descripcion_lote2, m.codigo_almacen, 'SUB', l.centro_contable,m.tipo_situacion) ) cantidad_sub2,  DECODE(s.stock_disponible, 'N', 0, m.cantidad_sob -  pk_parametros_pesca.calcula_stock_en_pedidos(m.codigo_empresa, m.codigo_cliente, NULL, NULL, NULL, NULL, NULL, m.codigo_articulo, m.numero_lote_int,h.descripcion_lote2, m.codigo_almacen, 'SOB', l.centro_contable,m.tipo_situacion) ) cantidad_sob2,  DECODE(s.stock_disponible, 'N', 0, m.cantidad_dis -  pk_parametros_pesca.calcula_stock_en_pedidos(m.codigo_empresa, m.codigo_cliente, NULL, NULL, NULL, NULL, NULL, m.codigo_articulo, m.numero_lote_int,h.descripcion_lote2, m.codigo_almacen, 'DIS', l.centro_contable,m.tipo_situacion) ) cantidad_dis2,  DECODE(s.stock_disponible, 'N', 0, m.cantidad_exp -  pk_parametros_pesca.calcula_stock_en_pedidos(m.codigo_empresa, m.codigo_cliente, NULL, NULL, NULL, NULL, NULL, m.codigo_articulo, m.numero_lote_int,h.descripcion_lote2, m.codigo_almacen, 'EXP', l.centro_contable,m.tipo_situacion) ) cantidad_exp2,  DECODE(s.stock_disponible, 'N', 0, m.cantidad_unidad1 -  pk_parametros_pesca.calcula_stock_en_pedidos(m.codigo_empresa, m.codigo_cliente, NULL, NULL, NULL, NULL, NULL, m.codigo_articulo, m.numero_lote_int,h.descripcion_lote2, m.codigo_almacen, 'CT1', l.centro_contable,m.tipo_situacion) ) cantidad_almacen12,  DECODE(s.stock_disponible, 'N', 0, m.cantidad_unidad2 -  pk_parametros_pesca.calcula_stock_en_pedidos(m.codigo_empresa, m.codigo_cliente, NULL, NULL, NULL, NULL, NULL, m.codigo_articulo, m.numero_lote_int,h.descripcion_lote2, m.codigo_almacen, 'CT2', l.centro_contable,m.tipo_situacion) ) cantidad_almacen22, l.lote_ext, m.cantidad_unidad1 cantidad_almacen1,m.cantidad_unidad2 cantidad_almacen2, m.codigo_empresa empresa,  h.descripcion_lote2 lote,  h.descripcion_lote2 lote_aux, DECODE('V','V',a.descrip_comercial,'T',a.descrip_tecnica,'C',a.descrip_compra,a.descrip_comercial) descripcion_articulo,DECODE('V','V',a.descrip_comercial,'T',a.descrip_tecnica,'C',a.descrip_compra,a.descrip_comercial) descripcion_articulo_aux,  a.unidad_Codigo1,a.unidad_codigo2,a.codigo_valor_invent,a.unidad_valoracion,a.cantidad_precio,a.incluir_gtos_gener_invent,
       a.codigo_familia,(select descripcion from familias where numero_tabla = '1' AND codigo_familia = a.codigo_familia AND codigo_empresa = '001') d_codigo_familia,
       a.codigo_estad2,(select descripcion from familias where numero_tabla = '2' AND codigo_familia = a.codigo_estad2 AND codigo_empresa = '001') d_codigo_estad2,
       a.codigo_estad3,(select descripcion from familias where numero_tabla = '3' AND codigo_familia = a.codigo_estad3 AND codigo_empresa = '001') d_codigo_estad3,
       a.codigo_estad4,(select descripcion from familias where numero_tabla = '4' AND codigo_familia = a.codigo_estad4 AND codigo_empresa = '001') d_codigo_estad4,
       a.codigo_estad5,(select descripcion from familias where numero_tabla = '5' AND codigo_familia = a.codigo_estad5 AND codigo_empresa = '001') d_codigo_estad5,
       a.codigo_estad6,(select descripcion from familias where numero_tabla = '6' AND codigo_familia = a.codigo_estad6 AND codigo_empresa = '001') d_codigo_estad6,
       a.codigo_estad7,(select descripcion from familias where numero_tabla = '7' AND codigo_familia = a.codigo_estad7 AND codigo_empresa = '001') d_codigo_estad7,
       a.codigo_estad8,(select descripcion from familias where numero_tabla = '8' AND codigo_familia = a.codigo_estad8 AND codigo_empresa = '001') d_codigo_estad8,
       a.codigo_estad9,(select descripcion from familias where numero_tabla = '9' AND codigo_familia = a.codigo_estad9 AND codigo_empresa = '001') d_codigo_estad9,
       a.codigo_estad10,(select descripcion from familias where numero_tabla = '10' AND codigo_familia = a.codigo_estad10 AND codigo_empresa = '001') d_codigo_estad10, 
       a.codigo_estad11,(select descripcion from familias where numero_tabla = '11' AND codigo_familia = a.codigo_estad11 AND codigo_empresa = '001') d_codigo_estad11, 
       a.codigo_estad12,(select descripcion from familias where numero_tabla = '12' AND codigo_familia = a.codigo_estad12 AND codigo_empresa = '001') d_codigo_estad12, 
       a.codigo_estad13,(select descripcion from familias where numero_tabla = '13' AND codigo_familia = a.codigo_estad13 AND codigo_empresa = '001') d_codigo_estad13, 
       a.codigo_estad14,(select descripcion from familias where numero_tabla = '14' AND codigo_familia = a.codigo_estad14 AND codigo_empresa = '001') d_codigo_estad14, 
       a.codigo_estad15,(select descripcion from familias where numero_tabla = '15' AND codigo_familia = a.codigo_estad15 AND codigo_empresa = '001') d_codigo_estad15, 
       a.codigo_estad16,(select descripcion from familias where numero_tabla = '16' AND codigo_familia = a.codigo_estad16 AND codigo_empresa = '001') d_codigo_estad16, 
       a.codigo_estad17,(select descripcion from familias where numero_tabla = '17' AND codigo_familia = a.codigo_estad17 AND codigo_empresa = '001') d_codigo_estad17, 
       a.codigo_estad18,(select descripcion from familias where numero_tabla = '18' AND codigo_familia = a.codigo_estad18 AND codigo_empresa = '001') d_codigo_estad18, 
       a.codigo_estad19,(select descripcion from familias where numero_tabla = '19' AND codigo_familia = a.codigo_estad19 AND codigo_empresa = '001') d_codigo_estad19, 
       a.codigo_estad20,(select descripcion from familias where numero_tabla = '20' AND codigo_familia = a.codigo_estad20 AND codigo_empresa = '001') d_codigo_estad20, 
       t.titulo_alfa_1, t.titulo_alfa_2, t.titulo_alfa_3, t.titulo_alfa_4, t.titulo_alfa_5, t.titulo_alfa_6, t.titulo_alfa_7, t.titulo_alfa_8, t.titulo_alfa_9, t.titulo_alfa_10,
     t.titulo_num_1, t.titulo_num_2, t.titulo_num_3, t.titulo_num_4, t.titulo_num_5, t.titulo_num_6, t.titulo_num_7, t.titulo_num_8, t.titulo_num_9, t.titulo_num_10,
     t.titulo_fecha_1, t.titulo_fecha_2, t.titulo_fecha_3,
     c.valor_alfa_1, c.valor_alfa_2, c.valor_alfa_3, c.valor_alfa_4, c.valor_alfa_5, c.valor_alfa_6, c.valor_alfa_7, c.valor_alfa_8, c.valor_alfa_9, c.valor_alfa_10,  (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_1 AND numero=1 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_1, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_2 AND numero=2 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_2, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_3 AND numero=3 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_3, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_4 AND numero=4 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_4, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_5 AND numero=5 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_5, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_6 AND numero=6 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_6, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_7 AND numero=7 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_7, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_8 AND numero=8 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_8, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_9 AND numero=9 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_9, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_10 AND numero=10 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_10, (SELECT registro_sanitario FROM titulos_personaliz_des WHERE valor=decode(t.valor_alfa_registro,'1',c.valor_alfa_1,'2',c.valor_alfa_2,'3',c.valor_alfa_3,'4',c.valor_alfa_4,
      '5',c.valor_alfa_5,'6',c.valor_alfa_6,'7',c.valor_alfa_7,'8',c.valor_alfa_8,'9',c.valor_alfa_9,'10',
      c.valor_alfa_10) AND numero=t.valor_alfa_registro AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') registro_Sanitario,
     c.valor_num_1, c.valor_num_2, c.valor_num_3, c.valor_num_4, c.valor_num_5, c.valor_num_6, c.valor_num_7, c.valor_num_8, c.valor_num_9, c.valor_num_10,
     c.valor_fecha_1, c.valor_fecha_2, c.valor_fecha_3,
       (SELECT numero_autorizacion_cliente FROM DOCUMENTO_VINCULACION_DEPOSITO D 
       WHERE D.CODIGO = h.codigo_dvd AND d.empresa = h.codigo_empresa) numero_autorizacion_cliente,
       (SELECT numero_dip FROM DOCUMENTO_VINCULACION_DEPOSITO D WHERE D.CODIGO = h.codigo_dvd AND d.empresa = h.codigo_empresa) numero_dip,
       (SELECT fecha_liberacion_dip FROM DOCUMENTO_VINCULACION_DEPOSITO D WHERE D.CODIGO = h.codigo_dvd AND d.empresa = h.codigo_empresa) fecha_liberacion_dip,
    (SELECT numero_dvce FROM DOCUMENTO_VINCULACION_DEPOSITO D WHERE D.CODIGO = h.codigo_dvd AND d.empresa = h.codigo_empresa) numero_dvce,
     (SELECT e.nombre FROM documento_vinculacion_deposito d, aduanas a, estados e WHERE a.codigo = d.aduana_registro 
     AND e.codigo = a.estado AND d.codigo = h.codigo_dvd AND d.empresa = h.codigo_empresa) estado_dvd,   
       h.tara_con, h.tara_sub, h.tara_sob, h.tara_dis, 
       h.tara_exp,  h.codigo_dvd codigo_dvd, h.codigo_proveedor,h.FECHA_FIN_FACT_FRIO_CLI_ORIGEN,h.cliente_facturacion_frio,h.fecha_siguiente_fact_frio, h.descripcion_lote d_numero_lote_int,h.descripcion_lote d_numero_lote_int_aux, null codigo_subreferencia,  h.fecha_caducidad, h.fecha_creacion, h.numero_lote_int_anterior,  a.alfa3_fao, a.partida_arancelaria partida_arancelaria, (SELECT nc.nombre_cientifico FROM nombres_cientificos nc WHERE nc.codigo = a.alfa3_fao) nombre_cientifico, (SELECT nc.descripcion FROM partidas_arancelarias nc WHERE nc.empresa = m.codigo_empresa AND nc.codigo = a.partida_arancelaria) d_partida_arancelaria,  m.codigo_cliente cliente, NULL palet, null numero_transporte, NULL d_numero_transporte, NULL ubicacion,  l.centro_contable,  NULL tipo_palet  FROM tipos_situacion s, almacenes alm,  caracteristicas_lotes c, titulos_personaliz t,lotes l, articulos a, historico_lotes h,  mareas ma,  stocks_deposito_cli m  WHERE h.numero_lote_int = m.numero_lote_int
   AND h.codigo_articulo = m.codigo_articulo
   AND h.codigo_empresa = m.codigo_empresa 
   AND l.lote(+) = h.descripcion_lote2
   AND l.empresa(+) = h.codigo_empresa  
   and ma.codigo(+) = l.marea
   and ma.empresa(+) = l.empresa 
   AND a.codigo_articulo = m.codigo_articulo
   AND a.codigo_empresa = m.codigo_empresa
   AND s.tipo_situacion = m.tipo_situacion
   AND s.codigo_empresa = m.codigo_empresa 
   AND alm.almacen = m.codigo_almacen
   AND alm.codigo_empresa = m.codigo_empresa  AND t.codigo_personaliz(+) = a.codigo_personaliz_lotes
     AND t.codigo_empresa(+) = a.codigo_empresa
     AND c.codigo_articulo(+) = m.codigo_articulo
     AND c.numero_lote_int(+) = m.numero_lote_int
     AND c.codigo_empresa(+) = m.codigo_empresa AND m.codigo_empresa = '001' AND m.codigo_almacen = '90' AND h.descripcion_lote2 >= 'PRODUCCION' AND h.descripcion_lote2 <= 'PRODUCCION' AND m.cantidad_CON != 0  ORDER BY cliente, lote, numero_lote_int) datos) d WHERE 1=1;



     SELECT CENTRO_CONTABLE,ALMACEN,D_CENTRO_CONTABLE,D_ALMACEN,ZONA_ALMACEN,D_ZONA_ALMACEN,LOTE_EXT,NUMERO_LOTE_INT_ANTERIOR,TIPO_SITUACION,CLIENTE,D_CLIENTE,D_CLIENTE_MIRROR,CODIGO_PROVEEDOR,D_CODIGO_PROVEEDOR,LOTE,LOTE_AUX,NUMERO_LOTE_INT,NUMERO_LOTE_INT_AUX,DESCRIPCION_ARTICULO_MIRROR,CODIGO_ARTICULO,DESCRIPCION_PARTIDA_MIRROR,UBICACION,SSCC,PALET,MAREA,D_MAREA,BARCO_LOTE,D_BARCO_LOTE,BUQUE,D_BUQUE,CANTIDAD_CON,PRECIO_COSTE,CANTIDAD_SUB,CANTIDAD_SOB,CANTIDAD_DIS,CANTIDAD_EXP,CANTIDAD_ALMACEN1,UNIDAD_CODIGO1,CANTIDAD_ALMACEN2,UNIDAD_CODIGO2,CANTIDAD_ALMACEN12,CANTIDAD_ALMACEN22,DESCARGA_FINALIZADA,CANTIDAD_CON2,CANTIDAD_SUB2,CANTIDAD_SOB2,CANTIDAD_DIS2,CANTIDAD_EXP2,COSTE,D_TIPO_SITUACION,D_NUMERO_LOTE_INT,DESCRIPCION_ARTICULO,CODIGO_ARTICULO_MIRROR,TIPO_PALET,D_TIPO_PALET,FECHA_FIN_FACT_FRIO_CLI_ORIGEN,FECHA_SIGUIENTE_FACT_FRIO,NUMERO_AUTORIZACION_CLIENTE,NUMERO_TRANSPORTE,TARA_CON,TARA_SUB,TARA_SOB,TARA_DIS,TARA_EXP,EMPRESA,CANTIDAD_PEND_RECI,CODIGO_VALOR_INVENT,UNIDAD_VALORACION,CANTIDAD_PRECIO,INCLUIR_GTOS_GENER_INVENT,CLIENTE_FACTURACION_FRIO,D_CLIENTE_FACTURACION_FRIO,CENTRO_CONTABLE_FRIO,D_CENTRO_CONTABLE_FRIO,CODIGO_FAMILIA,D_CODIGO_FAMILIA,CODIGO_ESTAD2,D_CODIGO_ESTAD2,CODIGO_ESTAD3,D_CODIGO_ESTAD3,CODIGO_ESTAD4,D_CODIGO_ESTAD4,CODIGO_ESTAD5,D_CODIGO_ESTAD5,CODIGO_ESTAD6,D_CODIGO_ESTAD6,CODIGO_ESTAD7,D_CODIGO_ESTAD7,CODIGO_ESTAD8,D_CODIGO_ESTAD8,CODIGO_ESTAD9,D_CODIGO_ESTAD9,CODIGO_ESTAD10,D_CODIGO_ESTAD10,CODIGO_ESTAD11,D_CODIGO_ESTAD11,CODIGO_ESTAD12,D_CODIGO_ESTAD12,CODIGO_ESTAD13,D_CODIGO_ESTAD13,CODIGO_ESTAD14,D_CODIGO_ESTAD14,CODIGO_ESTAD15,D_CODIGO_ESTAD15,CODIGO_ESTAD16,D_CODIGO_ESTAD16,CODIGO_ESTAD17,D_CODIGO_ESTAD17,CODIGO_ESTAD18,D_CODIGO_ESTAD18,CODIGO_ESTAD19,D_CODIGO_ESTAD19,CODIGO_ESTAD20,D_CODIGO_ESTAD20,VALOR_ALFA_1,VALOR_ALFA_2,VALOR_ALFA_3,VALOR_ALFA_4,VALOR_ALFA_5,VALOR_ALFA_6,VALOR_ALFA_7,VALOR_ALFA_8,VALOR_ALFA_9,VALOR_ALFA_10,VALOR_NUM_1,VALOR_NUM_2,VALOR_NUM_3,VALOR_NUM_4,VALOR_NUM_5,VALOR_NUM_6,VALOR_NUM_7,VALOR_NUM_8,VALOR_NUM_9,VALOR_NUM_10,VALOR_FECHA_1,VALOR_FECHA_2,VALOR_FECHA_3,D_VALOR_ALFA_1,D_VALOR_ALFA_2,D_VALOR_ALFA_3,D_VALOR_ALFA_4,D_VALOR_ALFA_5,D_VALOR_ALFA_6,D_VALOR_ALFA_7,D_VALOR_ALFA_8,D_VALOR_ALFA_9,D_VALOR_ALFA_10,CODIGO_SUBREFERENCIA,ALFA3_FAO,NOMBRE_CIENTIFICO,PARTIDA_ARANCELARIA,D_PARTIDA_ARANCELARIA,REGISTRO_SANITARIO,D_REGISTRO_SANITARIO,D_LOTE_AUX,FECHA_CADUCIDAD,FECHA_CREACION,TITULO_ALFA_1,TITULO_ALFA_2,TITULO_ALFA_3,TITULO_ALFA_4,TITULO_ALFA_5,TITULO_ALFA_6,TITULO_ALFA_7,TITULO_ALFA_8,TITULO_ALFA_9,TITULO_ALFA_10,TITULO_NUM_1,TITULO_NUM_2,TITULO_NUM_3,TITULO_NUM_4,TITULO_NUM_5,TITULO_NUM_6,TITULO_NUM_7,TITULO_NUM_8,TITULO_NUM_9,TITULO_NUM_10,TITULO_FECHA_1,TITULO_FECHA_2,TITULO_FECHA_3,STOCK_DISPONIBLE,D_ALMACEN_MIRROR,CODIGO_DVD,NUMERO_DIP,FECHA_LIBERACION_DIP,ESTADO_DVD,NUMERO_DVCE,ALMACEN_MIRROR,CLIENTE_MIRROR,NUMERO_LOTE_PRO,RESERVADOA01,RESERVADOA02,RESERVADOA03,RESERVADOA04,RECIPIENTE,TIPO_RECIPIENTE,D_TIPO_RECIPIENTE,OBS_HIST_PALETS,FAO_MAREA,DOCUMENTO_ENTRADA,TIPO_DOC_ENTRADA,D_TIPO_DOC_ENTRADA,ARTICULO_MIRROR,D_ARTICULO_MIRROR,ID_DIGITAL,D_NUMERO_TRANSPORTE,CANTIDAD_NOTAS_PESCA FROM (SELECT DATOS.* ,almacen ALMACEN_MIRROR,codigo_articulo ARTICULO_MIRROR,(SELECT SUM(pl.cantidad_unidad1)
   FROM articulos ar, barcos ba, lotes lo,mareas ma, nota_pesca pc, nota_pesca_lin pl
  WHERE pc.empresa = pl.empresa
    AND pc.codigo = pl.codigo
    AND pc.marea = pl.marea
    AND ba.codigo = ma.barco
    AND ba.empresa = ma.empresa
and lo.lote = ma.codigo_entrada
and lo.empresa = ma.empresa
and lo.descarga_finalizada='N'
    AND ar.codigo_articulo = pl.articulo
    AND ar.codigo_empresa = pl.empresa
    AND ma.empresa = pl.empresa
    AND ma.codigo = pl.marea
and pl.articulo = datos.codigo_articulo
    AND pl.empresa = datos.empresa
and ma.situacion='1000') CANTIDAD_NOTAS_PESCA,(select sum(PL.UNIDADES_PEDIDAS - PL.UNIDADES_ENTREGADAS)
FROM PARAM_COMPRAS p, articulos a, pedidos_compras pc, pedidos_compras_lin pl
         WHERE     PL.CODIGO_EMPRESA = PC.CODIGO_EMPRESA
               AND PL.ORGANIZACION_COMPRAS = PC.ORGANIZACION_COMPRAS
               AND PL.SERIE_NUMERACION = PC.SERIE_NUMERACION
               AND PL.NUMERO_PEDIDO = PC.NUMERO_PEDIDO
               AND A.CODIGO_EMPRESA = PL.CODIGO_EMPRESA
               AND A.CODIGO_ARTICULO = PL.CODIGO_ARTICULO
               and p.CODIGO_EMPRESA = pc.codigo_empresa
               and p.ORGANIZACION_COMPRAS = PC.ORGANIZACION_COMPRAS
               AND PL.STATUS_CIERRE = 'E'
               AND pl.codigo_articulo = DATOS.CODIGO_ARTICULO
      and (P.ALMACEN_DISTINTO = 'S' or (P.ALMACEN_DISTINTO = 'N' AND PC.CODIGO_ALMACEN = DATOS.ALMACEN))
     AND PL.UNIDADES_PEDIDAS - nvl(PL.UNIDADES_ENTREGADAS, 0) > 0
 AND pc.codigo_empresa = datos.empresa) CANTIDAD_PEND_RECI,cliente CLIENTE_MIRROR,CODIGO_ARTICULO_AUX CODIGO_ARTICULO_MIRROR,DESCRIPCION_ARTICULO DESCRIPCION_ARTICULO_MIRROR,(SELECT h.descripcion_lote FROM historico_lotes h WHERE h.numero_lote_int = NVL(datos.numero_lote_int_aux, datos.numero_lote_int)AND h.codigo_articulo = datos.codigo_articulo AND h.codigo_empresa = datos.empresa) DESCRIPCION_PARTIDA_MIRROR,(SELECT lval.nombre FROM almacenes lval WHERE lval.almacen = datos.almacen AND lval.codigo_empresa = datos.empresa) D_ALMACEN,datos.almacen D_ALMACEN_MIRROR,DESCRIPCION_ARTICULO D_ARTICULO_MIRROR,(SELECT lvb.nombre FROM barcos lvb WHERE lvb.codigo = datos.barco_lote AND lvb.empresa = datos.empresa ) D_BARCO_LOTE,(Select lvb.nombre from buques lvb where lvb.codigo = datos.buque and lvb.empresa =datos.empresa) D_BUQUE,(SELECT lvcc.nombre FROM caracteres_asiento lvcc WHERE lvcc.codigo = datos.centro_contable AND lvcc.empresa = datos.empresa) D_CENTRO_CONTABLE,(select ca.nombre from caracteres_asiento ca where ca.empresa=datos.empresa and ca.codigo=datos.centro_contable_frio) D_CENTRO_CONTABLE_FRIO,(SELECT c.nombre FROM clientes c WHERE c.codigo_rapido = datos.cliente AND c.codigo_empresa = datos.empresa) D_CLIENTE,(SELECT c.nombre FROM clientes c WHERE c.codigo_rapido = datos.cliente_facturacion_frio AND c.codigo_empresa = datos.empresa) D_CLIENTE_FACTURACION_FRIO,datos.cliente D_CLIENTE_MIRROR,(SELECT prlv.nombre FROM proveedores prlv WHERE prlv.codigo_rapido = datos.codigo_proveedor AND codigo_empresa = datos.empresa) D_CODIGO_PROVEEDOR,(SELECT lvlot.descripcion FROM lotes lvlot WHERE lvlot.lote = datos.lote_aux AND lvlot.empresa = datos.empresa) D_LOTE_AUX,(SELECT lvm.descripcion FROM mareas lvm WHERE lvm.codigo = datos.marea AND lvm.empresa = datos.empresa) D_MAREA,(SELECT lvrs.descripcion FROM registros_sanitarios lvrs where lvrs.numero_registro = datos.registro_sanitario and lvrs.empresa = datos.empresa) D_REGISTRO_SANITARIO,(SELECT lvtpm.descripcion FROM tipos_movimiento lvtpm WHERE lvtpm.codigo = datos.tipo_doc_entrada) D_TIPO_DOC_ENTRADA,(SELECT lvtp.descripcion FROM tipos_palet lvtp WHERE lvtp.codigo = datos.tipo_palet AND lvtp.empresa = datos.empresa) D_TIPO_PALET,(SELECT lvtp.descripcion FROM tipos_palet lvtp WHERE lvtp.codigo = datos.tipo_recipiente AND lvtp.empresa = datos.empresa) D_TIPO_RECIPIENTE,(SELECT lvts.descripcion FROM tipos_situacion lvts WHERE lvts.tipo_situacion = datos.tipo_situacion AND lvts.codigo_empresa = datos.empresa) D_TIPO_SITUACION,(SELECT lvaz.descripcion FROM almacenes_zonas lvaz WHERE lvaz.codigo_zona = datos.zona_almacen AND lvaz.codigo_almacen = datos.almacen AND lvaz.codigo_empresa = datos.empresa) D_ZONA_ALMACEN,(select NVL(id_digital, 0) from lotes l where l.empresa = DATOS.EMPRESA and l.lote = DATOS.LOTE) ID_DIGITAL,DECODE(UNID_VALORACION,  0, 0,  COSTE / UNID_VALORACION) PRECIO_COSTE,recipiente RECIPIENTE_MIRROR,NULL RESERVADOA01,NULL RESERVADOA02,NULL RESERVADOA03,NULL RESERVADOA04 FROM (SELECT m.codigo_almacen almacen,  NULL zona_almacen, m.tipo_situacion ,s.stock_disponible  ,m.numero_lote_int,   h.numero_lote_pro ,m.numero_lote_int numero_lote_int_aux, m.codigo_articulo, m.codigo_articulo codigo_articulo_aux, h.documento_entrada, h.codigo_creacion tipo_doc_entrada,  l.descarga_finalizada descarga_finalizada, ma.codigo marea, l.barco barco_lote, l.buque, ma.zona_fao fao_marea, COALESCE(alm.centro_contable, l.centro_contable_fact_frio, l.centro_contable) centro_contable_frio,  NULL coste,  NULL unid_valoracion,  NULL recipiente, NULL tipo_recipiente, NULL Obs_Hist_Palets, NULL sscc,  m.cantidad_con, m.cantidad_sub, m.cantidad_sob, m.cantidad_dis, m.cantidad_exp, DECODE(s.stock_disponible, 'N', 0, m.cantidad_con -  pk_parametros_pesca.calcula_stock_en_pedidos(m.codigo_empresa, m.codigo_cliente, NULL, NULL, NULL, NULL, NULL, m.codigo_articulo, m.numero_lote_int,h.descripcion_lote2, m.codigo_almacen, 'CON', l.centro_contable,m.tipo_situacion) ) cantidad_con2,  DECODE(s.stock_disponible, 'N', 0, m.cantidad_sub -  pk_parametros_pesca.calcula_stock_en_pedidos(m.codigo_empresa, m.codigo_cliente, NULL, NULL, NULL, NULL, NULL, m.codigo_articulo, m.numero_lote_int,h.descripcion_lote2, m.codigo_almacen, 'SUB', l.centro_contable,m.tipo_situacion) ) cantidad_sub2,  DECODE(s.stock_disponible, 'N', 0, m.cantidad_sob -  pk_parametros_pesca.calcula_stock_en_pedidos(m.codigo_empresa, m.codigo_cliente, NULL, NULL, NULL, NULL, NULL, m.codigo_articulo, m.numero_lote_int,h.descripcion_lote2, m.codigo_almacen, 'SOB', l.centro_contable,m.tipo_situacion) ) cantidad_sob2,  DECODE(s.stock_disponible, 'N', 0, m.cantidad_dis -  pk_parametros_pesca.calcula_stock_en_pedidos(m.codigo_empresa, m.codigo_cliente, NULL, NULL, NULL, NULL, NULL, m.codigo_articulo, m.numero_lote_int,h.descripcion_lote2, m.codigo_almacen, 'DIS', l.centro_contable,m.tipo_situacion) ) cantidad_dis2,  DECODE(s.stock_disponible, 'N', 0, m.cantidad_exp -  pk_parametros_pesca.calcula_stock_en_pedidos(m.codigo_empresa, m.codigo_cliente, NULL, NULL, NULL, NULL, NULL, m.codigo_articulo, m.numero_lote_int,h.descripcion_lote2, m.codigo_almacen, 'EXP', l.centro_contable,m.tipo_situacion) ) cantidad_exp2,  DECODE(s.stock_disponible, 'N', 0, m.cantidad_unidad1 -  pk_parametros_pesca.calcula_stock_en_pedidos(m.codigo_empresa, m.codigo_cliente, NULL, NULL, NULL, NULL, NULL, m.codigo_articulo, m.numero_lote_int,h.descripcion_lote2, m.codigo_almacen, 'CT1', l.centro_contable,m.tipo_situacion) ) cantidad_almacen12,  DECODE(s.stock_disponible, 'N', 0, m.cantidad_unidad2 -  pk_parametros_pesca.calcula_stock_en_pedidos(m.codigo_empresa, m.codigo_cliente, NULL, NULL, NULL, NULL, NULL, m.codigo_articulo, m.numero_lote_int,h.descripcion_lote2, m.codigo_almacen, 'CT2', l.centro_contable,m.tipo_situacion) ) cantidad_almacen22, l.lote_ext, m.cantidad_unidad1 cantidad_almacen1,m.cantidad_unidad2 cantidad_almacen2, m.codigo_empresa empresa,  h.descripcion_lote2 lote,  h.descripcion_lote2 lote_aux, DECODE('V','V',a.descrip_comercial,'T',a.descrip_tecnica,'C',a.descrip_compra,a.descrip_comercial) descripcion_articulo,DECODE('V','V',a.descrip_comercial,'T',a.descrip_tecnica,'C',a.descrip_compra,a.descrip_comercial) descripcion_articulo_aux,  a.unidad_Codigo1,a.unidad_codigo2,a.codigo_valor_invent,a.unidad_valoracion,a.cantidad_precio,a.incluir_gtos_gener_invent,
       a.codigo_familia,(select descripcion from familias where numero_tabla = '1' AND codigo_familia = a.codigo_familia AND codigo_empresa = '001') d_codigo_familia,
       a.codigo_estad2,(select descripcion from familias where numero_tabla = '2' AND codigo_familia = a.codigo_estad2 AND codigo_empresa = '001') d_codigo_estad2,
       a.codigo_estad3,(select descripcion from familias where numero_tabla = '3' AND codigo_familia = a.codigo_estad3 AND codigo_empresa = '001') d_codigo_estad3,
       a.codigo_estad4,(select descripcion from familias where numero_tabla = '4' AND codigo_familia = a.codigo_estad4 AND codigo_empresa = '001') d_codigo_estad4,
       a.codigo_estad5,(select descripcion from familias where numero_tabla = '5' AND codigo_familia = a.codigo_estad5 AND codigo_empresa = '001') d_codigo_estad5,
       a.codigo_estad6,(select descripcion from familias where numero_tabla = '6' AND codigo_familia = a.codigo_estad6 AND codigo_empresa = '001') d_codigo_estad6,
       a.codigo_estad7,(select descripcion from familias where numero_tabla = '7' AND codigo_familia = a.codigo_estad7 AND codigo_empresa = '001') d_codigo_estad7,
       a.codigo_estad8,(select descripcion from familias where numero_tabla = '8' AND codigo_familia = a.codigo_estad8 AND codigo_empresa = '001') d_codigo_estad8,
       a.codigo_estad9,(select descripcion from familias where numero_tabla = '9' AND codigo_familia = a.codigo_estad9 AND codigo_empresa = '001') d_codigo_estad9,
       a.codigo_estad10,(select descripcion from familias where numero_tabla = '10' AND codigo_familia = a.codigo_estad10 AND codigo_empresa = '001') d_codigo_estad10, 
       a.codigo_estad11,(select descripcion from familias where numero_tabla = '11' AND codigo_familia = a.codigo_estad11 AND codigo_empresa = '001') d_codigo_estad11, 
       a.codigo_estad12,(select descripcion from familias where numero_tabla = '12' AND codigo_familia = a.codigo_estad12 AND codigo_empresa = '001') d_codigo_estad12, 
       a.codigo_estad13,(select descripcion from familias where numero_tabla = '13' AND codigo_familia = a.codigo_estad13 AND codigo_empresa = '001') d_codigo_estad13, 
       a.codigo_estad14,(select descripcion from familias where numero_tabla = '14' AND codigo_familia = a.codigo_estad14 AND codigo_empresa = '001') d_codigo_estad14, 
       a.codigo_estad15,(select descripcion from familias where numero_tabla = '15' AND codigo_familia = a.codigo_estad15 AND codigo_empresa = '001') d_codigo_estad15, 
       a.codigo_estad16,(select descripcion from familias where numero_tabla = '16' AND codigo_familia = a.codigo_estad16 AND codigo_empresa = '001') d_codigo_estad16, 
       a.codigo_estad17,(select descripcion from familias where numero_tabla = '17' AND codigo_familia = a.codigo_estad17 AND codigo_empresa = '001') d_codigo_estad17, 
       a.codigo_estad18,(select descripcion from familias where numero_tabla = '18' AND codigo_familia = a.codigo_estad18 AND codigo_empresa = '001') d_codigo_estad18, 
       a.codigo_estad19,(select descripcion from familias where numero_tabla = '19' AND codigo_familia = a.codigo_estad19 AND codigo_empresa = '001') d_codigo_estad19, 
       a.codigo_estad20,(select descripcion from familias where numero_tabla = '20' AND codigo_familia = a.codigo_estad20 AND codigo_empresa = '001') d_codigo_estad20, 
       t.titulo_alfa_1, t.titulo_alfa_2, t.titulo_alfa_3, t.titulo_alfa_4, t.titulo_alfa_5, t.titulo_alfa_6, t.titulo_alfa_7, t.titulo_alfa_8, t.titulo_alfa_9, t.titulo_alfa_10,
     t.titulo_num_1, t.titulo_num_2, t.titulo_num_3, t.titulo_num_4, t.titulo_num_5, t.titulo_num_6, t.titulo_num_7, t.titulo_num_8, t.titulo_num_9, t.titulo_num_10,
     t.titulo_fecha_1, t.titulo_fecha_2, t.titulo_fecha_3,
     c.valor_alfa_1, c.valor_alfa_2, c.valor_alfa_3, c.valor_alfa_4, c.valor_alfa_5, c.valor_alfa_6, c.valor_alfa_7, c.valor_alfa_8, c.valor_alfa_9, c.valor_alfa_10,  (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_1 AND numero=1 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_1, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_2 AND numero=2 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_2, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_3 AND numero=3 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_3, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_4 AND numero=4 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_4, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_5 AND numero=5 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_5, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_6 AND numero=6 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_6, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_7 AND numero=7 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_7, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_8 AND numero=8 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_8, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_9 AND numero=9 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_9, (SELECT descripcion FROM titulos_personaliz_des WHERE valor=c.valor_alfa_10 AND numero=10 AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') d_valor_alfa_10, (SELECT registro_sanitario FROM titulos_personaliz_des WHERE valor=decode(t.valor_alfa_registro,'1',c.valor_alfa_1,'2',c.valor_alfa_2,'3',c.valor_alfa_3,'4',c.valor_alfa_4,
      '5',c.valor_alfa_5,'6',c.valor_alfa_6,'7',c.valor_alfa_7,'8',c.valor_alfa_8,'9',c.valor_alfa_9,'10',
      c.valor_alfa_10) AND numero=t.valor_alfa_registro AND codigo_personaliz=a.codigo_personaliz_lotes AND empresa='001') registro_Sanitario,
     c.valor_num_1, c.valor_num_2, c.valor_num_3, c.valor_num_4, c.valor_num_5, c.valor_num_6, c.valor_num_7, c.valor_num_8, c.valor_num_9, c.valor_num_10,
     c.valor_fecha_1, c.valor_fecha_2, c.valor_fecha_3,
       (SELECT numero_autorizacion_cliente FROM DOCUMENTO_VINCULACION_DEPOSITO D 
       WHERE D.CODIGO = h.codigo_dvd AND d.empresa = h.codigo_empresa) numero_autorizacion_cliente,
       (SELECT numero_dip FROM DOCUMENTO_VINCULACION_DEPOSITO D WHERE D.CODIGO = h.codigo_dvd AND d.empresa = h.codigo_empresa) numero_dip,
       (SELECT fecha_liberacion_dip FROM DOCUMENTO_VINCULACION_DEPOSITO D WHERE D.CODIGO = h.codigo_dvd AND d.empresa = h.codigo_empresa) fecha_liberacion_dip,
    (SELECT numero_dvce FROM DOCUMENTO_VINCULACION_DEPOSITO D WHERE D.CODIGO = h.codigo_dvd AND d.empresa = h.codigo_empresa) numero_dvce,
     (SELECT e.nombre FROM documento_vinculacion_deposito d, aduanas a, estados e WHERE a.codigo = d.aduana_registro 
     AND e.codigo = a.estado AND d.codigo = h.codigo_dvd AND d.empresa = h.codigo_empresa) estado_dvd,   
       h.tara_con, h.tara_sub, h.tara_sob, h.tara_dis, 
       h.tara_exp,  h.codigo_dvd codigo_dvd, h.codigo_proveedor,h.FECHA_FIN_FACT_FRIO_CLI_ORIGEN,h.cliente_facturacion_frio,h.fecha_siguiente_fact_frio, h.descripcion_lote d_numero_lote_int,h.descripcion_lote d_numero_lote_int_aux, null codigo_subreferencia,  h.fecha_caducidad, h.fecha_creacion, h.numero_lote_int_anterior,  a.alfa3_fao, a.partida_arancelaria partida_arancelaria, (SELECT nc.nombre_cientifico FROM nombres_cientificos nc WHERE nc.codigo = a.alfa3_fao) nombre_cientifico, (SELECT nc.descripcion FROM partidas_arancelarias nc WHERE nc.empresa = m.codigo_empresa AND nc.codigo = a.partida_arancelaria) d_partida_arancelaria,  m.codigo_cliente cliente, NULL palet, null numero_transporte, NULL d_numero_transporte, NULL ubicacion,  l.centro_contable,  NULL tipo_palet  FROM tipos_situacion s, almacenes alm,  caracteristicas_lotes c, titulos_personaliz t,lotes l, articulos a, historico_lotes h,  mareas ma,  stocks_deposito_cli m  WHERE h.numero_lote_int = m.numero_lote_int
   AND h.codigo_articulo = m.codigo_articulo
   AND h.codigo_empresa = m.codigo_empresa 
   AND l.lote(+) = h.descripcion_lote2
   AND l.empresa(+) = h.codigo_empresa  
   and ma.codigo(+) = l.marea
   and ma.empresa(+) = l.empresa 
   AND a.codigo_articulo = m.codigo_articulo
   AND a.codigo_empresa = m.codigo_empresa
   AND s.tipo_situacion = m.tipo_situacion
   AND s.codigo_empresa = m.codigo_empresa 
   AND alm.almacen = m.codigo_almacen
   AND alm.codigo_empresa = m.codigo_empresa  AND t.codigo_personaliz(+) = a.codigo_personaliz_lotes
     AND t.codigo_empresa(+) = a.codigo_empresa
     AND c.codigo_articulo(+) = m.codigo_articulo
     AND c.numero_lote_int(+) = m.numero_lote_int
     AND c.codigo_empresa(+) = m.codigo_empresa AND m.codigo_empresa = '001' AND m.codigo_almacen = '90' AND h.descripcion_lote2 >= 'PRODUCCION' AND h.descripcion_lote2 <= 'PRODUCCION' AND m.cantidad_CON != 0  ORDER BY cliente, lote, numero_lote_int) datos) d WHERE 1=1;




select * 
from stocks_detallado
where numero_lote_int = '023627'
  and tipo_situacion = 'CALID'
; 


select 
  DISTINCT sd.CODIGO_ALMACEN,
  (SELECT alm.nombre FROM ALMACENES alm WHERE alm.ALMACEN = sd.CODIGO_ALMACEN) AS NOMBRE_ALM
from stocks_detallado sd
where sd.codigo_articulo = '40000'