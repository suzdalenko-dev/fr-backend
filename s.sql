


SELECT
    hc.CODIGO_CLIENTE,
    (SELECT cli.NOMBRE || '  ' || hc.CODIGO_CLIENTE
     FROM VA_CLIENTES cli
     WHERE cli.CODIGO_RAPIDO = hc.CODIGO_CLIENTE AND cli.CODIGO_EMPRESA = hc.EMPRESA AND ROWNUM = 1
    ) AS NOMBRE_CLIENTE,
    (SELECT org.NOMBRE
     FROM VA_CLIENTES cli, ORGANIZACION_COMERCIAL org
     WHERE cli.CODIGO_RAPIDO = hc.CODIGO_CLIENTE
       AND cli.CODIGO_EMPRESA = hc.EMPRESA
       AND cli.ORG_COMER = org.CODIGO_ORG_COMER
       AND org.CODIGO_EMPRESA = hc.EMPRESA
       AND ROWNUM = 1
    ) AS DESCRIPCION_ORG_COMER,
    (SELECT ag.NOMBRE
     FROM agentes_clientes ac, agentes ag
     WHERE ac.CODIGO_CLIENTE = hc.CODIGO_CLIENTE
       AND ac.AGENTE = ag.CODIGO
       AND ROWNUM = 1
    ) AS NOMBRE_AGENTE,
    hc.DOCUMENTO, 
    hc.TIPO_TRANSACCION, 
    TO_NUMBER(hc.IMPORTE) AS IMPORTE, 

    -- ✅ IMPORTE_COBRADO real
    TO_NUMBER(hc.IMPORTE_COBRADO) AS IMPORTE_COBRADO_REAL,

    -- ✅ IMPORTE_COBRADO final con lógica de cierre si no está vivo
    CASE
        WHEN hc.DOCUMENTO_VIVO = 'N' THEN TO_NUMBER(hc.IMPORTE)
        ELSE TO_NUMBER(hc.IMPORTE_COBRADO)
    END AS IMPORTE_COBRADO,

    TO_CHAR(hc.FECHA_FACTURA, 'YYYY-MM-DD') AS FECHA_FACTURA,
    TO_CHAR(hc.FECHA_VENCIMIENTO, 'YYYY-MM-DD') AS FECHA_VENCIMIENTO,
    TO_CHAR(hc.FECHA_ACEPTACION, 'YYYY-MM-DD') AS FECHA_ACEPTACION,
    TO_CHAR(hc.FECHA_REMESA, 'YYYY-MM-DD') AS FECHA_REMESA,


      -- ✅ FECHA_ASIENTO_COBRO ajustada: real si existe, si no y no está vivo, vencimiento
    (SELECT TO_CHAR(MAX(ha.FECHA_ASIENTO), 'YYYY-MM-DD')
                        FROM HISTORICO_DETALLADO_APUNTES ha
                        WHERE ha.DOCUMENTO = hc.DOCUMENTO
                          AND ha.EMPRESA = hc.EMPRESA
                          AND ha.CODIGO_ENTIDAD = hc.CODIGO_CLIENTE
                          AND ha.CODIGO_CONCEPTO = 'COB'
                    ) AS FECHA_ASIENTO_COBRO,


    hc.DOCUMENTO_VIVO,

    -- ✅ STATUS_COBRO final con lógica de cierre si no está vivo
    CASE
        WHEN hc.DOCUMENTO_VIVO = 'N' THEN 'COBRADO'
        WHEN ABS(NVL(hc.IMPORTE_COBRADO,0) - hc.IMPORTE) < 1 THEN 'COBRADO'
        WHEN NVL(hc.IMPORTE_COBRADO,0) > 0 THEN 'PARCIAL'
        WHEN NVL(hc.IMPORTE_COBRADO,0) = 0 THEN 'PENDIENTE'
        ELSE 'INDEFINIDO'
    END AS STATUS_COBRO,

    -- ✅ DIAS_REAL_PAGO final con lógica de cierre
    CASE
        WHEN (
            SELECT MAX(ha.FECHA_ASIENTO)
            FROM HISTORICO_DETALLADO_APUNTES ha
            WHERE ha.DOCUMENTO = hc.DOCUMENTO
              AND ha.EMPRESA = hc.EMPRESA
              AND ha.CODIGO_ENTIDAD = hc.CODIGO_CLIENTE
              AND ha.CODIGO_CONCEPTO = 'COB'
        ) IS NOT NULL THEN (
            SELECT MAX(ha.FECHA_ASIENTO) - hc.FECHA_FACTURA
            FROM HISTORICO_DETALLADO_APUNTES ha
            WHERE ha.DOCUMENTO = hc.DOCUMENTO
              AND ha.EMPRESA = hc.EMPRESA
              AND ha.CODIGO_ENTIDAD = hc.CODIGO_CLIENTE
              AND ha.CODIGO_CONCEPTO = 'COB'
        )
        ELSE NULL
    END AS DIAS_REAL_PAGO,

    -- ✅ DIAS_EXCESO_PAGO final con lógica de cierre
    CASE
        WHEN (
            SELECT MAX(ha.FECHA_ASIENTO)
            FROM HISTORICO_DETALLADO_APUNTES ha
            WHERE ha.DOCUMENTO = hc.DOCUMENTO
              AND ha.EMPRESA = hc.EMPRESA
              AND ha.CODIGO_ENTIDAD = hc.CODIGO_CLIENTE
              AND ha.CODIGO_CONCEPTO = 'COB'
        ) IS NOT NULL THEN (
            SELECT GREATEST(0, MAX(ha.FECHA_ASIENTO) - hc.FECHA_VENCIMIENTO)
            FROM HISTORICO_DETALLADO_APUNTES ha
            WHERE ha.DOCUMENTO = hc.DOCUMENTO
              AND ha.EMPRESA = hc.EMPRESA
              AND ha.CODIGO_ENTIDAD = hc.CODIGO_CLIENTE
              AND ha.CODIGO_CONCEPTO = 'COB'
        )
        ELSE NULL
    END AS DIAS_EXCESO_PAGO

FROM 
    HISTORICO_COBROS hc
WHERE 
    'suzdalenko'='suzdalenko'
    AND hc.IMPORTE > 0
    AND hc.FECHA_FACTURA > TO_DATE('2025-01-31', 'YYYY-MM-DD')
    AND hc.DOCUMENTO = 'FX1/000025'
    AND hc.CODIGO_CLIENTE = '003666'
ORDER BY 
    hc.FECHA_FACTURA, FECHA_ASIENTO_COBRO;


----------------------- SIN FECHA DE COBRO y sin dias pago o dias exceso -----


SELECT
    hc.CODIGO_CLIENTE,
    (SELECT cli.NOMBRE || '  ' || hc.CODIGO_CLIENTE
     FROM VA_CLIENTES cli
     WHERE cli.CODIGO_RAPIDO = hc.CODIGO_CLIENTE AND cli.CODIGO_EMPRESA = hc.EMPRESA AND ROWNUM = 1
    ) AS NOMBRE_CLIENTE,
    (SELECT org.NOMBRE
     FROM VA_CLIENTES cli, ORGANIZACION_COMERCIAL org
     WHERE cli.CODIGO_RAPIDO = hc.CODIGO_CLIENTE
       AND cli.CODIGO_EMPRESA = hc.EMPRESA
       AND cli.ORG_COMER = org.CODIGO_ORG_COMER
       AND org.CODIGO_EMPRESA = hc.EMPRESA
       AND ROWNUM = 1
    ) AS DESCRIPCION_ORG_COMER,
    (SELECT ag.NOMBRE
     FROM agentes_clientes ac, agentes ag
     WHERE ac.CODIGO_CLIENTE = hc.CODIGO_CLIENTE
       AND ac.AGENTE = ag.CODIGO
       AND ROWNUM = 1
    ) AS NOMBRE_AGENTE,
    hc.DOCUMENTO, 
    hc.TIPO_TRANSACCION, 
    TO_NUMBER(hc.IMPORTE) AS IMPORTE, 

    -- ✅ IMPORTE_COBRADO real
    TO_NUMBER(hc.IMPORTE_COBRADO) AS IMPORTE_COBRADO_REAL,

    -- ✅ IMPORTE_COBRADO final con lógica de cierre si no está vivo
    CASE
        WHEN hc.DOCUMENTO_VIVO = 'N' THEN TO_NUMBER(hc.IMPORTE)
        ELSE TO_NUMBER(hc.IMPORTE_COBRADO)
    END AS IMPORTE_COBRADO,

    TO_CHAR(hc.FECHA_FACTURA, 'YYYY-MM-DD') AS FECHA_FACTURA,
    TO_CHAR(hc.FECHA_VENCIMIENTO, 'YYYY-MM-DD') AS FECHA_VENCIMIENTO,
    TO_CHAR(hc.FECHA_ACEPTACION, 'YYYY-MM-DD') AS FECHA_ACEPTACION,
    TO_CHAR(hc.FECHA_REMESA, 'YYYY-MM-DD') AS FECHA_REMESA,
    hc.DOCUMENTO_VIVO,

    -- ✅ STATUS_COBRO final con lógica de cierre si no está vivo
    CASE
        WHEN hc.DOCUMENTO_VIVO = 'N' THEN 'COBRADO'
        WHEN ABS(NVL(hc.IMPORTE_COBRADO,0) - hc.IMPORTE) < 1 THEN 'COBRADO'
        WHEN NVL(hc.IMPORTE_COBRADO,0) > 0 THEN 'PARCIAL'
        WHEN NVL(hc.IMPORTE_COBRADO,0) = 0 THEN 'PENDIENTE'
        ELSE 'INDEFINIDO'
    END AS STATUS_COBRO,

    -- ✅ FECHA_ASIENTO_COBRO final con lógica de cierre si no está vivo
     (SELECT TO_CHAR(MAX(ha.FECHA_ASIENTO), 'YYYY-MM-DD')
            FROM HISTORICO_DETALLADO_APUNTES ha
            WHERE ha.DOCUMENTO = hc.DOCUMENTO
              AND ha.EMPRESA = hc.EMPRESA
              AND ha.CODIGO_ENTIDAD = hc.CODIGO_CLIENTE
              AND ha.CODIGO_CONCEPTO = 'COB'
    ) AS FECHA_ASIENTO_COBRO,

    -- ✅ DIAS_REAL_PAGO final con lógica de cierre si no está vivo
    (SELECT MAX(ha.FECHA_ASIENTO) - hc.FECHA_FACTURA
            FROM HISTORICO_DETALLADO_APUNTES ha
            WHERE ha.DOCUMENTO = hc.DOCUMENTO
              AND ha.EMPRESA = hc.EMPRESA
              AND ha.CODIGO_ENTIDAD = hc.CODIGO_CLIENTE
              AND ha.CODIGO_CONCEPTO = 'COB'
        ) AS DIAS_REAL_PAGO,

    (SELECT GREATEST(0, MAX(ha.FECHA_ASIENTO) - hc.FECHA_VENCIMIENTO) AS DIAS_EXCESO_PAGO
            FROM HISTORICO_DETALLADO_APUNTES ha
            WHERE ha.DOCUMENTO = hc.DOCUMENTO
              AND ha.EMPRESA = hc.EMPRESA
              AND ha.CODIGO_ENTIDAD = hc.CODIGO_CLIENTE
              AND ha.CODIGO_CONCEPTO = 'COB'
        ) AS DIAS_EXCESO_PAGO

FROM 
    HISTORICO_COBROS hc
WHERE 
    'suzdalenko'='suzdalenko'
    AND hc.IMPORTE > 0
    AND hc.FECHA_FACTURA > TO_DATE('2025-01-31', 'YYYY-MM-DD')
    AND hc.DOCUMENTO = 'FX1/000025'
    AND hc.CODIGO_CLIENTE = '003666'
ORDER BY 
    hc.FECHA_FACTURA, FECHA_ASIENTO_COBRO;



select * 
from HISTORICO_DETALLADO_APUNTES
where
CODIGO_ENTIDAD = '003666'
 AND CODIGO_CONCEPTO = 'COB';


select * 
from RIESGO_CLIENTES_AUX
where CODIGO_CLIENTE = '003666'
order by FECHA_FACTURA
;

select distinct numero_serie, cliente, fecha_factura
from facturas_ventas
where fecha_factura >= TO_DATE('2025-02-01', 'YYYY-MM-DD')
 and numero_serie not in('FR1', 'FX1', 'FN1')
;


select *
from facturas_ventas
where -- cliente = '003702'
   numero_serie = 'RX1'
;

select numero_fra_conta, ejercicio, numero_serie, tipo_factura, cliente, fecha_factura, liquido_factura, numero_asiento_borrador, diario, id_crm, id_digital, id_agrupacion
from facturas_ventas
where cliente = '003702'
    -- and numero_factura in ('1829', '1554', '971')
    or numero_fra_conta like '%cambio'
;

-- extracto cliente --

SELECT V_NUMERO_SERIE,V_NUMERO_FACTURA,V_FECHA_FACTURA,V_ORGANIZACION_COMERCIAL,D_ORGANIZACION_COMERCIAL,D_STATUS_FIRMA_DIGITAL,D_STATUS_FACTURA,V_CENTRO_CONTABLE,D_CENTRO_CONTABLE,V_FORMA_COBRO,V_CLIENTE,D_FORMA_COBRO,D_CLIENTE,V_DTOS_GLOBAL,V_LIQUIDO_FACTURA,V_PENDIENTE_COBRO,V_CODIGO_DIVISA,V_MARGEN_COMERCIAL,V_RECARGO_FINANCIERO,V_IMP_RECARGO_FINANCIERO,V_ENVIADO_EDI,V_FECHA_CERTIFICADO,V_UUID,EMPRESA,EJERCICIO,FECHA_CONTABILIZACION,NUMERO_ASIENTO_BORRADOR,ID_CRM,ID_DIGITAL,HAY_ASOCIACION_CRM,HAY_ARCHIVOS,V_USUARIO,NUMERO_FRA_CONTA FROM (SELECT  facturas_ventas.* ,(SELECT lvcc.nombre FROM caracteres_asiento lvcc WHERE lvcc.codigo = facturas_ventas.centro_contable AND lvcc.empresa = facturas_ventas.empresa) D_CENTRO_CONTABLE,DECODE(facturas_ventas.codigo_cliente,NULL,NULL,(SELECT clv.nombre FROM clientes clv WHERE clv.codigo_rapido = facturas_ventas.codigo_cliente AND clv.codigo_empresa = facturas_ventas.empresa)) D_CLIENTE,(SELECT lvfcp.nombre FROM formas_cobro_pago lvfcp WHERE lvfcp.codigo = facturas_ventas.forma_cobro) D_FORMA_COBRO,(SELECT lvoc.nombre FROM organizacion_comercial lvoc WHERE lvoc.codigo_org_comer = facturas_ventas.organizacion_comercial AND lvoc.codigo_empresa = facturas_ventas.empresa) D_ORGANIZACION_COMERCIAL,pkconsgen.f_desc_status_factura(status_factura) D_STATUS_FACTURA,pkconsgen.f_desc_status_firma_digital(status_firma_digital) D_STATUS_FIRMA_DIGITAL,pkconsgen.hay_archivos_x_id_digital(id_digital,'EFACTURA') HAY_ARCHIVOS,pkconsgen.hay_asociacion_crm(empresa, id_crm) HAY_ASOCIACION_CRM,CENTRO_CONTABLE V_CENTRO_CONTABLE,codigo_cliente V_CLIENTE,PKCONSGEN.DIVISA(codigo_divisa) V_CODIGO_DIVISA,NVL(DTOS_GLOBAL, 0) V_DTOS_GLOBAL,enviado_edi V_ENVIADO_EDI,(SELECT fd.fecha_certificado FROM facturas_ventas_doc fd WHERE fd.empresa = facturas_ventas.empresa AND fd.ejercicio = facturas_ventas.ejercicio AND fd.numero_serie = facturas_ventas.numero_serie AND fd.numero_factura = facturas_ventas.numero_factura) V_FECHA_CERTIFICADO,FECHA_FACTURA V_FECHA_FACTURA,FORMA_COBRO V_FORMA_COBRO,PKCONSGEN.IMPORTE_TXT(imp_recargo_financiero, imp_recargo_financiero_div, codigo_divisa) V_IMP_RECARGO_FINANCIERO,PKCONSGEN.IMPORTE_TXT(liquido_factura, liquido_factura_div, codigo_divisa) V_LIQUIDO_FACTURA,DECODE(importe_fac_neto, 0, 0, ROUND((importe_fac_neto - coste_bruto) * 100 / importe_fac_neto, 2)) V_MARGEN_COMERCIAL,NUMERO_FACTURA V_NUMERO_FACTURA,NUMERO_SERIE V_NUMERO_SERIE,ORGANIZACION_COMERCIAL V_ORGANIZACION_COMERCIAL,DECODE(numero_asiento_borrador, NULL, PKCONSGEN.IMPORTE_TXT(liquido_factura, liquido_factura_div, codigo_divisa), PKCONSGEN.IMPORTE_PDTE_COBRO_DOC_TXT(empresa, numero_fra_conta, fecha_factura, codigo_divisa, liquido_factura, liquido_factura_div)) V_PENDIENTE_COBRO,RECARGO_FINANCIERO V_RECARGO_FINANCIERO,USUARIO V_USUARIO,(SELECT fd.uuid FROM facturas_ventas_doc fd WHERE fd.empresa = facturas_ventas.empresa AND fd.ejercicio = facturas_ventas.ejercicio AND fd.numero_serie = facturas_ventas.numero_serie AND fd.numero_factura = facturas_ventas.numero_factura) V_UUID FROM (SELECT facturas_ventas.*, DECODE(pkconsgen.ver_cli_bloqueados, 'S', facturas_ventas.cliente, DECODE(pkconsgen.cliente_bloqueado(facturas_ventas.empresa, facturas_ventas.cliente), 'S', NULL, facturas_ventas.cliente)) codigo_cliente FROM facturas_ventas) facturas_ventas)  facturas_ventas WHERE cliente = '003702' AND empresa = '001' AND EXISTS (SELECT 1 FROM usuarios_gb_cc ugbcc WHERE ugbcc.centro_contable = facturas_ventas.centro_contable AND ugbcc.codigo_empresa = '001' AND ugbcc.usuario = 'MFERNANDEZ') AND EXISTS (SELECT 1 FROM org_comerc_usuarios ocu WHERE ocu.usuario = 'MFERNANDEZ' AND ocu.organizacion_comercial = facturas_ventas.organizacion_comercial AND ocu.codigo_empresa = '001') AND NOT EXISTS (SELECT 1 FROM albaran_ventas av WHERE av.empresa = facturas_ventas.empresa AND av.ejercicio_factura = facturas_ventas.ejercicio AND av.numero_serie_fra = facturas_ventas.numero_serie AND av.numero_factura = facturas_ventas.numero_factura AND NOT EXISTS (SELECT 1 FROM usuario_tipo_pedido ocu WHERE ocu.codigo_usuario = 'MFERNANDEZ' AND ocu.organizacion_comercial = av.organizacion_comercial AND ocu.tipo_pedido = av.tipo_pedido AND ocu.empresa = '001'))/*INIQRY*/  order by fecha_factura DESC, numero_serie, numero_factura DESC;
SELECT V_NUMERO_SERIE,V_NUMERO_FACTURA,V_FECHA_FACTURA,V_ORGANIZACION_COMERCIAL,D_ORGANIZACION_COMERCIAL,D_STATUS_FIRMA_DIGITAL,D_STATUS_FACTURA,V_CENTRO_CONTABLE,D_CENTRO_CONTABLE,V_FORMA_COBRO,V_CLIENTE,D_FORMA_COBRO,D_CLIENTE,V_DTOS_GLOBAL,V_LIQUIDO_FACTURA,V_PENDIENTE_COBRO,V_CODIGO_DIVISA,V_MARGEN_COMERCIAL,V_RECARGO_FINANCIERO,V_IMP_RECARGO_FINANCIERO,V_ENVIADO_EDI,V_FECHA_CERTIFICADO,V_UUID,EMPRESA,EJERCICIO,FECHA_CONTABILIZACION,NUMERO_ASIENTO_BORRADOR,ID_CRM,ID_DIGITAL,HAY_ASOCIACION_CRM,HAY_ARCHIVOS,V_USUARIO,NUMERO_FRA_CONTA FROM (SELECT  facturas_ventas.* ,(SELECT lvcc.nombre FROM caracteres_asiento lvcc WHERE lvcc.codigo = facturas_ventas.centro_contable AND lvcc.empresa = facturas_ventas.empresa) D_CENTRO_CONTABLE,DECODE(facturas_ventas.codigo_cliente,NULL,NULL,(SELECT clv.nombre FROM clientes clv WHERE clv.codigo_rapido = facturas_ventas.codigo_cliente AND clv.codigo_empresa = facturas_ventas.empresa)) D_CLIENTE,(SELECT lvfcp.nombre FROM formas_cobro_pago lvfcp WHERE lvfcp.codigo = facturas_ventas.forma_cobro) D_FORMA_COBRO,(SELECT lvoc.nombre FROM organizacion_comercial lvoc WHERE lvoc.codigo_org_comer = facturas_ventas.organizacion_comercial AND lvoc.codigo_empresa = facturas_ventas.empresa) D_ORGANIZACION_COMERCIAL,pkconsgen.f_desc_status_factura(status_factura) D_STATUS_FACTURA,pkconsgen.f_desc_status_firma_digital(status_firma_digital) D_STATUS_FIRMA_DIGITAL,pkconsgen.hay_archivos_x_id_digital(id_digital,'EFACTURA') HAY_ARCHIVOS,pkconsgen.hay_asociacion_crm(empresa, id_crm) HAY_ASOCIACION_CRM,CENTRO_CONTABLE V_CENTRO_CONTABLE,codigo_cliente V_CLIENTE,PKCONSGEN.DIVISA(codigo_divisa) V_CODIGO_DIVISA,NVL(DTOS_GLOBAL, 0) V_DTOS_GLOBAL,enviado_edi V_ENVIADO_EDI,(SELECT fd.fecha_certificado FROM facturas_ventas_doc fd WHERE fd.empresa = facturas_ventas.empresa AND fd.ejercicio = facturas_ventas.ejercicio AND fd.numero_serie = facturas_ventas.numero_serie AND fd.numero_factura = facturas_ventas.numero_factura) V_FECHA_CERTIFICADO,FECHA_FACTURA V_FECHA_FACTURA,FORMA_COBRO V_FORMA_COBRO,PKCONSGEN.IMPORTE_TXT(imp_recargo_financiero, imp_recargo_financiero_div, codigo_divisa) V_IMP_RECARGO_FINANCIERO,PKCONSGEN.IMPORTE_TXT(liquido_factura, liquido_factura_div, codigo_divisa) V_LIQUIDO_FACTURA,DECODE(importe_fac_neto, 0, 0, ROUND((importe_fac_neto - coste_bruto) * 100 / importe_fac_neto, 2)) V_MARGEN_COMERCIAL,NUMERO_FACTURA V_NUMERO_FACTURA,NUMERO_SERIE V_NUMERO_SERIE,ORGANIZACION_COMERCIAL V_ORGANIZACION_COMERCIAL,DECODE(numero_asiento_borrador, NULL, PKCONSGEN.IMPORTE_TXT(liquido_factura, liquido_factura_div, codigo_divisa), PKCONSGEN.IMPORTE_PDTE_COBRO_DOC_TXT(empresa, numero_fra_conta, fecha_factura, codigo_divisa, liquido_factura, liquido_factura_div)) V_PENDIENTE_COBRO,RECARGO_FINANCIERO V_RECARGO_FINANCIERO,USUARIO V_USUARIO,(SELECT fd.uuid FROM facturas_ventas_doc fd WHERE fd.empresa = facturas_ventas.empresa AND fd.ejercicio = facturas_ventas.ejercicio AND fd.numero_serie = facturas_ventas.numero_serie AND fd.numero_factura = facturas_ventas.numero_factura) V_UUID FROM (SELECT facturas_ventas.*, DECODE(pkconsgen.ver_cli_bloqueados, 'S', facturas_ventas.cliente, DECODE(pkconsgen.cliente_bloqueado(facturas_ventas.empresa, facturas_ventas.cliente), 'S', NULL, facturas_ventas.cliente)) codigo_cliente FROM facturas_ventas) facturas_ventas)  facturas_ventas WHERE cliente = '000005' AND empresa = '001'  order by fecha_factura DESC, numero_serie, numero_factura DESC;

EFECTO NUEVO DAG1224 GRUPO ITH (JACA)

SELECT
    CASE
        WHEN hc.FECHA_VENCIMIENTO < TRUNC(SYSDATE) THEN 'VENCIDO'
        ELSE 'NO VENCIDO'
    END AS ESTADO_VENCIMIENTO,
    hc.CODIGO_CLIENTE,
    (SELECT cli.NOMBRE || '  ' || hc.CODIGO_CLIENTE
     FROM VA_CLIENTES cli
     WHERE cli.CODIGO_RAPIDO = hc.CODIGO_CLIENTE AND cli.CODIGO_EMPRESA = hc.EMPRESA AND ROWNUM = 1
    ) AS NOMBRE_CLIENTE,
    (SELECT org.NOMBRE
    FROM VA_CLIENTES cli, ORGANIZACION_COMERCIAL org
    WHERE cli.CODIGO_RAPIDO = hc.CODIGO_CLIENTE
      AND cli.CODIGO_EMPRESA = hc.EMPRESA
      AND cli.ORG_COMER = org.CODIGO_ORG_COMER
      AND org.CODIGO_EMPRESA = hc.EMPRESA
      AND org.NOMBRE NOT IN ('VENTA LOGISTICA FROXA', 'VENTA TIENDA CARTES FROXA')
      AND org.NOMBRE IS NOT NULL
    ) AS DESCRIPCION_ORG_COMER,
    (SELECT ag.NOMBRE
     FROM agentes_clientes ac, agentes ag
     WHERE ac.CODIGO_CLIENTE = hc.CODIGO_CLIENTE
       AND ac.AGENTE = ag.CODIGO
       AND ROWNUM = 1
    ) AS NOMBRE_AGENTE,
    hc.DOCUMENTO, 
    hc.TIPO_TRANSACCION, 
    TO_NUMBER(hc.IMPORTE) AS IMPORTE, 

    -- ✅ IMPORTE_COBRADO real
    TO_NUMBER(hc.IMPORTE_COBRADO) AS IMPORTE_COBRADO_REAL,

    -- ✅ IMPORTE_COBRADO final con lógica de cierre si no está vivo
    CASE
        WHEN hc.DOCUMENTO_VIVO = 'N' THEN TO_NUMBER(hc.IMPORTE)
        ELSE TO_NUMBER(hc.IMPORTE_COBRADO)
    END AS IMPORTE_COBRADO,

    TO_CHAR(hc.FECHA_FACTURA, 'YYYY-MM-DD') AS FECHA_FACTURA,
    TO_CHAR(hc.FECHA_VENCIMIENTO, 'YYYY-MM-DD') AS FECHA_VENCIMIENTO,
    TO_CHAR(hc.FECHA_ACEPTACION, 'YYYY-MM-DD') AS FECHA_ACEPTACION,
    TO_CHAR(hc.FECHA_REMESA, 'YYYY-MM-DD') AS FECHA_REMESA,
    hc.DOCUMENTO_VIVO,

    -- ✅ STATUS_COBRO final con lógica de cierre si no está vivo
    CASE
        WHEN hc.DOCUMENTO_VIVO = 'N' THEN 'COBRADO'
        WHEN ABS(NVL(hc.IMPORTE_COBRADO,0) - hc.IMPORTE) < 1 THEN 'COBRADO'
        WHEN NVL(hc.IMPORTE_COBRADO,0) > 0 THEN 'PARCIAL'
        WHEN NVL(hc.IMPORTE_COBRADO,0) = 0 THEN 'PENDIENTE'
        ELSE 'INDEFINIDO'
    END AS STATUS_COBRO,

    -- ✅ FECHA_ASIENTO_COBRO final con lógica de cierre si no está vivo
     (SELECT TO_CHAR(MAX(ha.FECHA_ASIENTO), 'YYYY-MM-DD')
            FROM HISTORICO_DETALLADO_APUNTES ha
            WHERE ha.DOCUMENTO = hc.DOCUMENTO
              AND ha.EMPRESA = hc.EMPRESA
              AND ha.CODIGO_ENTIDAD = hc.CODIGO_CLIENTE
              AND ha.CODIGO_CONCEPTO = 'COB'
    ) AS FECHA_ASIENTO_COBRO,

    -- ✅ DIAS_REAL_PAGO final con lógica de cierre si no está vivo
    (SELECT MAX(ha.FECHA_ASIENTO) - hc.FECHA_FACTURA
            FROM HISTORICO_DETALLADO_APUNTES ha
            WHERE ha.DOCUMENTO = hc.DOCUMENTO
              AND ha.EMPRESA = hc.EMPRESA
              AND ha.CODIGO_ENTIDAD = hc.CODIGO_CLIENTE
              AND ha.CODIGO_CONCEPTO = 'COB'
        ) AS DIAS_REAL_PAGO,

    (SELECT GREATEST(0, MAX(ha.FECHA_ASIENTO) - hc.FECHA_VENCIMIENTO) AS DIAS_EXCESO_PAGO
            FROM HISTORICO_DETALLADO_APUNTES ha
            WHERE ha.DOCUMENTO = hc.DOCUMENTO
              AND ha.EMPRESA = hc.EMPRESA
              AND ha.CODIGO_ENTIDAD = hc.CODIGO_CLIENTE
              AND ha.CODIGO_CONCEPTO = 'COB'
        ) AS DIAS_EXCESO_PAGO

FROM 
    HISTORICO_COBROS hc
WHERE 
    'suzdalenko'='suzdalenko'
    AND hc.IMPORTE > 0
    AND hc.FECHA_FACTURA >= TO_DATE('2025-02-01', 'YYYY-MM-DD')
    AND EXISTS (
        SELECT 1
        FROM facturas_ventas fv
        WHERE fv.numero_fra_conta = hc.documento
    )
    -- AND hc.DOCUMENTO NOT LIKE '%DAG%'
    -- AND hc.DOCUMENTO NOT LIKE '%DAR%'
    -- AND hc.DOCUMENTO = 'FX1/000025'
    -- AND hc.CODIGO_CLIENTE = '003666'
ORDER BY 
    hc.FECHA_FACTURA, FECHA_ASIENTO_COBRO;



select * 
from historico_detallado_apuntes
where codigo_entidad = '004242'
 and codigo_concepto = 'COB'
;

DAG1224

select * 
from historico_detallado_apuntes
where documento = 'DAG1224'
        and codigo_concepto = 'COB'
        and codigo_entidad  = '004242' 
       -- fecha de asiento es FECHA DE LA OPERACION !!! numero_asiento_borrador 35587
;

select * 
from historico_detallado_apuntes
where codigo_entidad  = '004242' 
       -- fecha de asiento es FECHA DE LA OPERACION !!! numero_asiento_borrador 35587
;

select * 
from historico_detallado_apuntes
where numero_asiento_borrador = '35583'
ORDER BY FECHA_ASIENTO asc
;


select * from asientos;

select * 
from HISTORICO_COBROS
where documento like '%DAG1224%' or concepto like '%DAG1224%'
;

SELECT DIARIO,CODIGO_CUENTA,CODIGO_CONCEPTO,SIGNO,IMPORTE,FECHA_ASIENTO,NUMERO_ASIENTO_BORRADOR,NUMERO_ASIENTO_OFICIAL,DOCUMENTO,CARACTER_ASIENTO,NUMERO_LINEA_BORRADOR,NUMERO_LINEA_OFICIAL,SERIE_JUSTIFICANTE,JUSTIFICANTE,CONCEPTO,FECHA_VALOR,DEBE,HABER,SALDO 
FROM 
    (SELECT estado, 
            empresa, 
            fecha_asiento, 
            diario, 
            numero_asiento_borrador, 
            numero_linea_borrador, 
            codigo_cuenta, 
            codigo_concepto, 
            concepto,  
            DECODE(signo,'D',importe) debe, 
            DECODE(signo,'H',importe) haber,  
            SUM(DECODE(signo, 'D', importe, -importe)
    ) OVER
    (PARTITION BY codigo_entidad, codigo_cuenta, empresa, estado  ORDER BY fecha_asiento, numero_asiento_borrador, numero_linea_borrador ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) + NVL(pkpantallas.get_variable_env_number('EXTRCLIE.SALDO_INICIAL'), 0) saldo, SUM(DECODE(signo, 'D', importe_divisa, -importe_divisa)) OVER (PARTITION BY codigo_entidad, codigo_cuenta, empresa, estado  ORDER BY fecha_asiento, numero_asiento_borrador, numero_linea_borrador ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) + NVL(pkpantallas.get_variable_env_number('EXTRCLIE.SALDO_INICIAL_DIVISA'), 0) saldo_divisa,0 saldo_euro,  asiento_con_impuesto, situacion_apunte, importe, importe_divisa, resumir, signo,  caracter_asiento, fecha_valor, numero_linea_oficial, documento, DECODE(signo,'D',importe_divisa) debe_divisa, DECODE(signo,'H',importe_divisa) haber_divisa,  divisa_origen, fecha_valor_divisa, marca_punteo, serie_justificante, justificante,  fecha_impuesto, formula_reparto, numero_linea_resumen, comentarios, entidad, codigo_entidad,  numero_asiento_origen, numero_linea_origen, empresa_apunte, id_conciliacion, usuario, DECODE(situacion_apunte,'B','*',NULL) borrador, 0 debe_euro, 0 haber_euro,  NULL NUMERO_ASIENTO_OFICIAL  FROM HISTORICO_DETALLADO_APUNTES  WHERE FECHA_ASIENTO BETWEEN NVL(TO_DATE('','DD-MM-YYYY'),TO_DATE('01011900','DDMMYYYY')) AND NVL(TO_DATE('30-06-2025','DD-MM-YYYY'), TO_DATE('01012500','DDMMYYYY')) AND ENTIDAD = 'CL'  AND (caracter_asiento IS NULL OR caracter_asiento IN (SELECT b.codigo_centro FROM centros_grupo_ccont B WHERE b.empresa = historico_detallado_apuntes.empresa AND b.codigo_grupo = '01')) AND EXISTS(SELECT 1 FROM historico_asientos ha WHERE ha.numero_asiento_borrador = historico_detallado_apuntes.numero_asiento_borrador AND ha.fecha_asiento = historico_detallado_apuntes.fecha_asiento AND ha.diario = historico_detallado_apuntes.diario AND ha.empresa = historico_detallado_apuntes.empresa AND ha.anulado = 'N' )  AND DIARIO NOT IN (SELECT CODIGO FROM DIARIOS WHERE APERTURA_CIERRE in ('A','C'))  ORDER BY fecha_asiento, numero_asiento_borrador, numero_linea_borrador) WHERE (ESTADO='ESP') and (EMPRESA='001') and (CODIGO_CUENTA='4300030') and (CODIGO_ENTIDAD='004242') order by FECHA_ASIENTO ASC;



SELECT
    hc.CODIGO_CLIENTE,
    hc.DOCUMENTO,
    hc.TIPO_TRANSACCION,
    TO_NUMBER(hc.IMPORTE) AS IMPORTE,
    TO_NUMBER(hc.IMPORTE_COBRADO) AS IMPORTE_COBRADO,
    hc.FECHA_FACTURA,
    hc.FECHA_VENCIMIENTO,
    hc.FECHA_ACEPTACION,
    hc.FECHA_REMESA,
    hc.DOCUMENTO_VIVO,

    -- Datos de apuntes unidos
    hda.FECHA_ASIENTO,
    hda.DIARIO,
    hda.CODIGO_CUENTA,
    hda.CODIGO_CONCEPTO,
    hda.CONCEPTO,
    hda.IMPORTE AS IMPORTE_APUNTE,
    hda.SIGNO,
    hda.NUMERO_ASIENTO_BORRADOR,
    hda.NUMERO_LINEA_BORRADOR

FROM
    HISTORICO_COBROS hc

LEFT JOIN
    HISTORICO_DETALLADO_APUNTES hda
    ON hc.DOCUMENTO = hda.DOCUMENTO
   AND hc.EMPRESA = hda.EMPRESA
   AND hc.CODIGO_CLIENTE = hda.CODIGO_ENTIDAD

WHERE
    hda.ENTIDAD = 'CL'
    AND (hda.CARACTER_ASIENTO IS NULL 
         OR hda.CARACTER_ASIENTO IN (
            SELECT b.CODIGO_CENTRO
            FROM CENTROS_GRUPO_CCONT b
            WHERE b.EMPRESA = hda.EMPRESA
              AND b.CODIGO_GRUPO = '01'
         )
    )
    AND EXISTS (
        SELECT 1
        FROM HISTORICO_ASIENTOS ha
        WHERE ha.NUMERO_ASIENTO_BORRADOR = hda.NUMERO_ASIENTO_BORRADOR
          AND ha.FECHA_ASIENTO = hda.FECHA_ASIENTO
          AND ha.DIARIO = hda.DIARIO
          AND ha.EMPRESA = hda.EMPRESA
          AND ha.ANULADO = 'N'
    )
    AND hda.DIARIO NOT IN (
        SELECT CODIGO
        FROM DIARIOS
        WHERE APERTURA_CIERRE IN ('A','C')
    )
    AND hda.ESTADO = 'ESP'
    AND hda.EMPRESA = '001'
    AND hda.CODIGO_CUENTA = '4300030'
    AND hda.CODIGO_ENTIDAD = '004242'
    and     hda.NUMERO_ASIENTO_BORRADOR = '35583'

ORDER BY
    hda.FECHA_ASIENTO,
    hda.NUMERO_ASIENTO_BORRADOR,
    hda.NUMERO_LINEA_BORRADOR
    ;


-- FC1/000007 cliente 004242

select * 
from HISTORICO_COBROS
where documento = 'FC1/000007'
    and NUMERO_ASIENTO_BORRADOR = 11446
    and CODIGO_CUENTA = 4300030
    and JUSTIFICANTE = '000007'
    and IDENTICKET = 'OC 158/202'
;


select * 
from historico_asientos
where NUMERO_ASIENTO_BORRADOR = '35583'
;

select * 
from historico_asientos
where NUMERO_ASIENTO_BORRADOR = '11446'
;

select * 
from HISTORICO_DETALLADO_APUNTES
where DOCUMENTO = 'FC1/000007'
   -- and codigo_concepto = 'ZZZ' -- de aqui NUMERO_ASIENTO_BORRADOR
;

select * 
from HISTORICO_DETALLADO_APUNTES
where NUMERO_ASIENTO_BORRADOR = '35583'
;



select * 
from historico_mov_cartera
where codigo_cliente = '004242'
;

select * from historico_cobros_temporal;


SELECT 
  hm.documento,
  hm.fecha_factura,
  hm.fecha_vencimiento,
  hm.tipo_transaccion,
  hm.tipo_movimiento,
  hm.fecha_asiento,
  DECODE(hm.tipo_movimiento, 'CONRD', hm.fecha_vencimiento, hm.fecha_asiento) AS fecha_operacion,
  hm.importe_mov,
  h.codigo_cliente,
  p.razon_social
FROM 
  historico_mov_cartera hm
JOIN 
  historico_cobros h
  ON h.documento = hm.documento
 AND h.fecha_vencimiento = hm.fecha_vencimiento
 AND h.tipo_transaccion = hm.tipo_transaccion
 AND h.fecha_factura = hm.fecha_factura
 AND h.empresa = hm.empresa
JOIN 
  clientes p
  ON p.codigo_rapido = h.codigo_cliente
 AND p.codigo_empresa = h.empresa
WHERE
  hm.empresa = '001'
  AND h.codigo_cliente = '004242'
ORDER BY
  hm.fecha_asiento DESC;


SELECT *
FROM historico_mov_cartera hm
WHERE hm.codigo_cliente = '004242'
  AND hm.documento = 'FC1/000007';



SELECT TEXT
FROM ALL_VIEWS
WHERE VIEW_NAME = 'V_HISTORICO_DET_BANCOS';

SELECT /*$PNTPKLIB$ASIDE%CTRL(FTES:00004:*/ a.codigo_cuenta, a.estado, a.codigo_entidad, a.empresa, a.fecha_asiento, a.fecha_valor, a.numero_asiento_borrador, a.numero_linea_borrador, a.documento, 
       a.concepto, a.serie_justificante,
       a.justificante, a.importe, a.importe_divisa, a.divisa_origen, a.signo, a.marca_punteo, a.situacion_apunte, a.caracter_asiento, a.codigo_concepto, a.diario, a.fecha_envio_listado,
       a.fecha_envio_fichero, NVL(a.int_ext, c.int_ext) int_ext, a.importe_div2_empresa
  FROM historico_detallado_apuntes a, cuentas c
 WHERE c.empresa = a.empresa
   AND c.estado = a.estado
   AND c.codigo = a.codigo_cuenta
   AND a.entidad = 'BA';

select FECHA_ASIENTO
from historico_detallado_apuntes
where entidad = 'BA'
    and DOCUMENTO = 'DAG1224'
;



SELECT 
    TO_CHAR(fv.FECHA_FACTURA, 'YYYY-MM-DD') AS FECHA_FACTURA,
    TO_CHAR(fv.FECHA_FACTURA, 'YYYY') AS EJERCICIO,
    fv.EMPRESA, 
    fv.CLIENTE, 
    fv.NUMERO_FRA_CONTA,

    (SELECT cli.NOMBRE || ' ' || cli.CODIGO_RAPIDO 
        FROM VA_CLIENTES cli
        WHERE cli.CODIGO_RAPIDO = fv.CLIENTE 
          AND cli.CODIGO_EMPRESA = fv.EMPRESA 
          AND ROWNUM = 1
    ) AS NOMBRE_CLIENTE,

    (SELECT org.NOMBRE
        FROM VA_CLIENTES cli
        JOIN ORGANIZACION_COMERCIAL org
          ON cli.ORG_COMER = org.CODIGO_ORG_COMER
         AND cli.CODIGO_EMPRESA = org.CODIGO_EMPRESA
        WHERE cli.CODIGO_RAPIDO = fv.CLIENTE
          AND cli.CODIGO_EMPRESA = fv.EMPRESA
          AND org.NOMBRE NOT IN ('VENTA LOGISTICA FROXA', 'VENTA TIENDA CARTES FROXA')
          AND org.NOMBRE IS NOT NULL
          AND ROWNUM = 1
    ) AS DESCRIPCION_ORG_COMER,

    (SELECT ag.NOMBRE
    FROM agentes_clientes ac, agentes ag
    WHERE ac.CODIGO_CLIENTE = fv.CLIENTE
      AND ac.AGENTE = ag.CODIGO
      AND ROWNUM = 1
    ) AS NOMBRE_AGENTE

FROM 
    facturas_ventas fv
WHERE 
    fv.CLIENTE = '004242'
ORDER BY 
    fv.FECHA_FACTURA, 
    fv.NUMERO_FRA_CONTA;




select * from VA_CLIENTES;

SELECT *
FROM facturas_ventas fv
WHERE cliente = '004242'
;

select * from facturas_ventas;

select * 
from AGRUPACIONES_DESGLOSES
WHERE NUMERO_AGRUPACION = 2024
; 

select * 
from AGRUPACIONES_DESGLOSES
WHERE DOCUMENTO = 'FC1/000007'
; 

select * from V_HISTORICO_DET_BANCOS
where DOCUMENTO = 'DAG1224'
;

select FECHA_ASIENTO from HISTORICO_COBROS
where  DOCUMENTO = 'DAG1224'
;

select  TO_DATE(FECHA_VENCIMIENTO, 'YYYY-MM-DD') FECHA_VENCIMIENTO from HISTORICO_COBROS
where  DOCUMENTO = 'FC1/000005'
;


select * from HISTORICO_COBROS
where  DOCUMENTO = 'FC1/000007'
;



select * from historico_detallado_apuntes
where  DOCUMENTO = 'FC1/000005' and ENTIDAD = 'CL' and CODIGO_CONCEPTO = 'COB'
;

select * from historico_detallado_apuntes
where  DOCUMENTO = 'DAG1224' and ENTIDAD = 'BA' and CODIGO_CONCEPTO = 'COB'
;

select *  
from historico_detallado_apuntes 
where  DOCUMENTO = 'DAG1224';

select *  
from historico_detallado_apuntes 
where  DOCUMENTO = 'DAG1225';

select TO_CHAR(FECHA_ASIENTO, 'YYYY-MM-DD') AS FECHA_COBRO
                                                            from historico_detallado_apuntes 
                                                            where  DOCUMENTO = 'DAG1225' and CODIGO_CONCEPTO = 'COB' AND ROWNUM = 1
                                                            ORDER BY FECHA_ASIENTO DESC;


select *
from facturas_ventas;


factura -> desgloses > dag > dag que tenga la fecha de cobro historico_detallado_apuntes where entidad = 'BA'
 

                                        Fecha Oper
FC1/000007	11/03/2025	TRA	11/03/2025	27/06/2025	12.396,12

select TO_DATE(FECHA_ASIENTO, 'YYYY-MM-DD') AS FECHA_OPERACION 
                                                            from historico_detallado_apuntes
                                                            where DOCUMENTO = 'DAG1224' and ENTIDAD = 'BA' and CODIGO_CONCEPTO = 'COB';



SELECT
    CASE
        WHEN hc.FECHA_VENCIMIENTO < TRUNC(SYSDATE) THEN 'VENCIDO'
        ELSE 'NO VENCIDO'
    END AS ESTADO_VENCIMIENTO,
    hc.CODIGO_CLIENTE,
    (SELECT cli.NOMBRE || '  ' || hc.CODIGO_CLIENTE
     FROM VA_CLIENTES cli
     WHERE cli.CODIGO_RAPIDO = hc.CODIGO_CLIENTE AND cli.CODIGO_EMPRESA = hc.EMPRESA AND ROWNUM = 1
    ) AS NOMBRE_CLIENTE,
    (SELECT org.NOMBRE
    FROM VA_CLIENTES cli, ORGANIZACION_COMERCIAL org
    WHERE cli.CODIGO_RAPIDO = hc.CODIGO_CLIENTE
      AND cli.CODIGO_EMPRESA = hc.EMPRESA
      AND cli.ORG_COMER = org.CODIGO_ORG_COMER
      AND org.CODIGO_EMPRESA = hc.EMPRESA
      AND org.NOMBRE NOT IN ('VENTA LOGISTICA FROXA', 'VENTA TIENDA CARTES FROXA')
      AND org.NOMBRE IS NOT NULL
    ) AS DESCRIPCION_ORG_COMER,
    (SELECT ag.NOMBRE
     FROM agentes_clientes ac, agentes ag
     WHERE ac.CODIGO_CLIENTE = hc.CODIGO_CLIENTE
       AND ac.AGENTE = ag.CODIGO
       AND ROWNUM = 1
    ) AS NOMBRE_AGENTE,
    hc.DOCUMENTO, 
    hc.TIPO_TRANSACCION, 
    TO_NUMBER(hc.IMPORTE) AS IMPORTE, 

    -- ✅ IMPORTE_COBRADO real
    TO_NUMBER(hc.IMPORTE_COBRADO) AS IMPORTE_COBRADO_REAL,

    -- ✅ IMPORTE_COBRADO final con lógica de cierre si no está vivo
    CASE
        WHEN hc.DOCUMENTO_VIVO = 'N' THEN TO_NUMBER(hc.IMPORTE)
        ELSE TO_NUMBER(hc.IMPORTE_COBRADO)
    END AS IMPORTE_COBRADO,

    TO_CHAR(hc.FECHA_FACTURA, 'YYYY-MM-DD') AS FECHA_FACTURA,
    TO_CHAR(hc.FECHA_VENCIMIENTO, 'YYYY-MM-DD') AS FECHA_VENCIMIENTO,
    TO_CHAR(hc.FECHA_ACEPTACION, 'YYYY-MM-DD') AS FECHA_ACEPTACION,
    TO_CHAR(hc.FECHA_REMESA, 'YYYY-MM-DD') AS FECHA_REMESA,
    hc.DOCUMENTO_VIVO,

    -- ✅ STATUS_COBRO final con lógica de cierre si no está vivo
    CASE
        WHEN hc.DOCUMENTO_VIVO = 'N' THEN 'COBRADO'
        WHEN ABS(NVL(hc.IMPORTE_COBRADO,0) - hc.IMPORTE) < 1 THEN 'COBRADO'
        WHEN NVL(hc.IMPORTE_COBRADO,0) > 0 THEN 'PARCIAL'
        WHEN NVL(hc.IMPORTE_COBRADO,0) = 0 THEN 'PENDIENTE'
        ELSE 'INDEFINIDO'
    END AS STATUS_COBRO,

    -- ✅ FECHA_ASIENTO_COBRO final con lógica de cierre si no está vivo
     (SELECT TO_CHAR(MAX(ha.FECHA_ASIENTO), 'YYYY-MM-DD')
            FROM HISTORICO_DETALLADO_APUNTES ha
            WHERE ha.DOCUMENTO = hc.DOCUMENTO
              AND ha.EMPRESA = hc.EMPRESA
              AND ha.CODIGO_ENTIDAD = hc.CODIGO_CLIENTE
              AND ha.CODIGO_CONCEPTO = 'COB'
    ) AS FECHA_ASIENTO_COBRO,

    -- ✅ DIAS_REAL_PAGO final con lógica de cierre si no está vivo
    (SELECT MAX(ha.FECHA_ASIENTO) - hc.FECHA_FACTURA
            FROM HISTORICO_DETALLADO_APUNTES ha
            WHERE ha.DOCUMENTO = hc.DOCUMENTO
              AND ha.EMPRESA = hc.EMPRESA
              AND ha.CODIGO_ENTIDAD = hc.CODIGO_CLIENTE
              AND ha.CODIGO_CONCEPTO = 'COB'
        ) AS DIAS_REAL_PAGO,

    (SELECT GREATEST(0, MAX(ha.FECHA_ASIENTO) - hc.FECHA_VENCIMIENTO) AS DIAS_EXCESO_PAGO
            FROM HISTORICO_DETALLADO_APUNTES ha
            WHERE ha.DOCUMENTO = hc.DOCUMENTO
              AND ha.EMPRESA = hc.EMPRESA
              AND ha.CODIGO_ENTIDAD = hc.CODIGO_CLIENTE
              AND ha.CODIGO_CONCEPTO = 'COB'
        ) AS DIAS_EXCESO_PAGO

FROM 
    HISTORICO_COBROS hc
WHERE 
    'suzdalenko'='suzdalenko'
    AND hc.FECHA_FACTURA >= TO_DATE('2025-02-01', 'YYYY-MM-DD')
    AND EXISTS (
        SELECT 1
        FROM facturas_ventas fv
        WHERE fv.numero_fra_conta = hc.documento
    )
    -- AND hc.IMPORTE > 0
    -- AND hc.DOCUMENTO NOT LIKE '%DAG%'
    -- AND hc.DOCUMENTO NOT LIKE '%DAR%'
    -- AND hc.DOCUMENTO = 'FX1/000025'
    -- AND hc.CODIGO_CLIENTE = '003666'
ORDER BY 
    hc.FECHA_FACTURA, FECHA_ASIENTO_COBRO;


select *
from HISTORICO_COBROS hc
where hc.DOCUMENTO = 'FC1/000005'
; 


select hc.*
from historico_detallado_apuntes hc
where  DOCUMENTO = 'DAG1224'
;

select hc.IMPORTE, hc.IMPORTE_COBRADO, TO_CHAR(hda.FECHA_ASIENTO, 'YYYY-MM-DD') AS FECHA_COBRO
from historico_detallado_apuntes hda, HISTORICO_COBROS hc
where hda.DOCUMENTO = hc.DOCUMENTO 
    AND hda.DOCUMENTO = 'DAG802' 
    AND hda.CODIGO_CONCEPTO = 'COB' 
    AND hda.ENTIDAD = 'CL'
    AND hda.CODIGO_ENTIDAD = hc.CODIGO_CLIENTE
    
;

select * from AGRUPACIONES_DESGLOSES
WHERE DOCUMENTO = 'FR1/003211'
;

select * from AGRUPACIONES_DESGLOSES
where numero_agrupacion = 1169
;

select hc.*
from historico_detallado_apuntes hc
where  DOCUMENTO = 'DAG802'
;

select *
from HISTORICO_COBROS hc
where hc.DOCUMENTO = 'DAG990'
; 


cobradas:
    FR1/001515 > DAG511 > fecha cobro 2025-05-26
    FR1/003211 > DAG802 >             2025-06-24
?¿
    FR1/005277 > DAG990 >
