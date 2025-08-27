SELECT formas_cobro_pago.nombre,
        historico_cobros.codigo_cliente,
        historico_cobros.d_codigo_cliente,
        HISTORICO_COBROS.IMPORTE,
        (HISTORICO_COBROS.IMPORTE -  HISTORICO_COBROS.IMPORTE_SUSTITUIDO - HISTORICO_COBROS.IMPORTE_COBRADO) AS IMP_R,
        CASE 
        WHEN historico_cobros.forma_cobro IS NULL THEN (
            SELECT LISTAGG(DOCUMENTO, ';') WITHIN GROUP (ORDER BY DOCUMENTO)
            FROM AGRUPACIONES_DESGLOSES d
            WHERE d.NUMERO_AGRUPACION = historico_cobros.numero_agrupacion and d.ejercicio = historico_cobros.ejercicio_agrupacion and  d.empresa = '001')
          ELSE HISTORICO_COBROS.DOCUMENTO
        end FACTURA,
        historico_cobros.fecha_factura,
        historico_cobros.fecha_vencimiento,
        (TRUNC(F_CURRENT_DATE - HISTORICO_COBROS.FECHA_VENCIMIENTO))*-1 dias_vencidas,
        (TRUNC(F_CURRENT_DATE - HISTORICO_COBROS.FECHA_FACTURA))*-1 dias_desde_factura,
        historico_cobros.numero_agrupacion,
        TO_CHAR(EJERCICIO_AGRUPACION, 'YYYY') AS EJERCICIO
        FROM (
          SELECT HISTORICO_COBROS.*,
          (SELECT c.nombre FROM clientes c WHERE c.codigo_rapido = HISTORICO_COBROS.CODIGO_CLIENTE AND c.codigo_empresa = HISTORICO_COBROS.EMPRESA) D_CODIGO_CLIENTE FROM HISTORICO_COBROS
          ) HISTORICO_COBROS,
          AGENTES,
          CLIENTES,
          FORMAS_COBRO_PAGO,
          CLIENTES_PARAMETROS WHERE agentes.empresa(+) = historico_cobros.empresa
            AND agentes.codigo(+) = historico_cobros.agente
            AND historico_cobros.empresa = clientes.codigo_empresa
            AND historico_cobros.codigo_cliente = clientes.codigo_rapido
            AND historico_cobros.documento_vivo = 'S'
            AND formas_cobro_pago.codigo(+) = historico_cobros.forma_cobro 
            and CLIENTES.CODIGO_RAPIDO=CLIENTES_PARAMETROS.CODIGO_CLIENTE 
            and CLIENTES.CODIGO_EMPRESA=CLIENTES_PARAMETROS.EMPRESA 
            AND historico_cobros.codigo_cuenta = '4300010'
            AND TO_CHAR(historico_cobros.fecha_factura, 'YYYY-MM-DD') >= '2025-02-01'
            AND HISTORICO_COBROS.IMPORTE > 0
            and historico_cobros.codigo_cliente = '003272'
            ORDER BY FACTURA ASC
            ;




