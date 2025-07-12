select SUM(IMPORTE_COBRADO), SUM(IMPORTE_SUSTITUIDO)
FROM HISTORICO_MOV_CARTERA 
WHERE documento = 'FR1/001533'
;

select * from HISTORICO_COBROS where DOCUMENTO = 'FR1/001533';

select *
FROM HISTORICO_MOV_CARTERA WHERE documento = 'FR1/009812';

SELECT * FROM HISTORICO_DETALLADO_APUNTES hda WHERE hda.DOCUMENTO = 'FR1/001533';

SELECT * FROM HISTORICO_DETALLADO_APUNTES hda WHERE hda.DOCUMENTO = 'FR1/001074';

SELECT *
FROM HISTORICO_DETALLADO_APUNTES hda
WHERE hda.DOCUMENTO = 'FR1/000135';

SELECT TO_NUMBER(hc.IMPORTE), TO_NUMBER(hc.IMPORTE_COBRADO) 
FROM HISTORICO_COBROS hc
WHERE hc.DOCUMENTO = 'FR1/000817';

SELECT TO_NUMBER(hc.IMPORTE), TO_NUMBER(hc.IMPORTE_COBRADO) 
                                FROM HISTORICO_COBROS hc
                                WHERE hc.DOCUMENTO = 'FR1/001533';

SELECT DISTINCT TO_CHAR(ha.FECHA_ASIENTO, 'YYYY-MM-DD')
FROM HISTORICO_DETALLADO_APUNTES ha
WHERE ha.DOCUMENTO = 'FX1/000035'  AND ha.CODIGO_CONCEPTO in ('COB', 'REM') AND DIARIO = 'BANC' AND ha.ENTIDAD = 'CL';

select * 
from HISTORICO_DETALLADO_APUNTES
where documento = 'FX1/000035'
;

select * 
from HISTORICO_COBROS
where documento IN ('FR1/000857', '')
;

select * 
from AGRUPACIONES_DESGLOSES 
WHERE DOCUMENTO = 'FR1/007183'
;

select * 
from AGRUPACIONES_DESGLOSES 
WHERE NUMERO_AGRUPACION = '2089' -- and documento = 'FN1/000857'
;

select FECHA_ASIENTO
from HISTORICO_DETALLADO_APUNTES
where documento = 'FR1/007165' AND DIARIO = 'VENT' AND CODIGO_CONCEPTO = 'COB' AND CODIGO_ENTIDAD = '000664'
;

SELECT *
FROM HISTORICO_COBROS hc
WHERE hc.DOCUMENTO = 'FR1/007165'
;

select FECHA_MOVIMIENTO
from HISTORICO_MOV_CARTERA
where DOCUMENTO = 'FR1/007165';

    -- ANT 003311 -> padre 003301
/*  'FR1/001300', 'FR1/001290', 'FR1/001292', 'FR1/001428', 'FR1/001296', 'FR1/001488', 'FR1/001312', 'FR1/001554', 'FR1/001548', 'FR1/001278', 'FR1/001282', 'FR1/001298', 'FR1/001306', 'FR1/001491'
     000768        000721        000722        001462        000764        001819        000807        004406        004344        000678        000697        000766        000785        001831
     20/03/2025    31/03/2025    31/03/2025    02/05/2025    11/03/2025    06/06/2025    06/06/2025    06/06/2025    06/06/2025    14/04/2025    06/06/2025    06/06/2025    22/05/2025    06/06/2025
     04/04/2025                                              18/03/2025
                                                                            REM           REM           REM             REM          DAG575
     2025-04-04    2025-03-31    2025-03-31    2025-05-02    2025-03-18    2025-06-06   2025-06-06    2025-06-06    dont_charged  2025-04-14    2025-06-06     2025-06-06   2025-05-22   dont_charged
                                                                            BANC          BANC          BANC           BANC           BANC        BANC          BANC         DAG959    
                                                                                                                                      COB         REM           REM          BANC
                                                                                                                                                                             REM
    -- primero lo que viene en sql madre
    -- luego buscar en HISTORICO_DETALLADO_APUNTES REM BANC CL
    -- buscar numero agrupacion
    -- buscar DAG agrupacion
    -- buscar en HISTORICO_DETALLADO_APUNTES DAG BANC COB CL




*/

SELECT DIARIO,
    CODIGO_CUENTA,
    CODIGO_CONCEPTO,
    CODIGO_ENTIDAD,
    SIGNO,
    FECHA_IMPUESTO,
    IMPORTE,
    FECHA_ASIENTO,
    NUMERO_ASIENTO_BORRADOR,
    SERIE_JUSTIFICANTE,
    JUSTIFICANTE,
    CONCEPTO,
    DEBE,
    HABER,
    SALDO
FROM  (SELECT estado, empresa, fecha_asiento, diario, numero_asiento_borrador, numero_linea_borrador, codigo_cuenta, codigo_concepto, concepto,  DECODE(signo,'D',importe) debe, DECODE(signo,'H',importe) haber,  SUM(DECODE(signo, 'D', importe, -importe)) OVER (PARTITION BY codigo_entidad, codigo_cuenta, empresa, estado  ORDER BY fecha_asiento, numero_asiento_borrador, numero_linea_borrador ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) + NVL(pkpantallas.get_variable_env_number('EXTRCLIE.SALDO_INICIAL'), 0) saldo, SUM(DECODE(signo, 'D', importe_divisa, -importe_divisa)) OVER (PARTITION BY codigo_entidad, codigo_cuenta, empresa, estado  ORDER BY fecha_asiento, numero_asiento_borrador, numero_linea_borrador ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) + NVL(pkpantallas.get_variable_env_number('EXTRCLIE.SALDO_INICIAL_DIVISA'), 0) saldo_divisa,0 saldo_euro,  asiento_con_impuesto, situacion_apunte, importe, importe_divisa, resumir, signo,  caracter_asiento, fecha_valor, numero_linea_oficial, documento, DECODE(signo,'D',importe_divisa) debe_divisa, DECODE(signo,'H',importe_divisa) haber_divisa,  divisa_origen, fecha_valor_divisa, marca_punteo, serie_justificante, justificante,  fecha_impuesto, formula_reparto, numero_linea_resumen, comentarios, entidad, codigo_entidad,  numero_asiento_origen, numero_linea_origen, empresa_apunte, id_conciliacion, usuario, DECODE(situacion_apunte,'B','*',NULL) borrador, 0 debe_euro, 0 haber_euro,  NULL NUMERO_ASIENTO_OFICIAL  
FROM HISTORICO_DETALLADO_APUNTES  
WHERE ENTIDAD = 'CL'  AND (caracter_asiento IS NULL OR caracter_asiento IN (SELECT b.codigo_centro FROM centros_grupo_ccont B WHERE b.empresa = historico_detallado_apuntes.empresa AND b.codigo_grupo = '01')) AND EXISTS(SELECT 1 FROM historico_asientos ha WHERE ha.numero_asiento_borrador = historico_detallado_apuntes.numero_asiento_borrador AND ha.fecha_asiento = historico_detallado_apuntes.fecha_asiento AND ha.diario = historico_detallado_apuntes.diario AND ha.empresa = historico_detallado_apuntes.empresa AND ha.anulado = 'N' )  AND DIARIO NOT IN (SELECT CODIGO FROM DIARIOS WHERE APERTURA_CIERRE in ('A','C'))  ORDER BY fecha_asiento, numero_asiento_borrador, numero_linea_borrador) 
WHERE CODIGO_CUENTA='4300020' and CODIGO_ENTIDAD='004266' and DOCUMENTO = 'FR1/001533';


select NVL(SUM(IMPORTE),0) AS IMPORTE_COBRADO_CUENTA 
from HISTORICO_DETALLADO_APUNTES where documento = 'FR1/001533' 
    and CODIGO_CUENTA IN (4300010,4300011,4300020,4300030,4300040,4300090,4309010,4310010,4310020,4310030,4310040,4311010,4312000,4315010,4315020,4360010,4360020,4360030,4360040,4380000,4380020) 
    and signo='H'
;

select distinct codigo_cuenta from HISTORICO_DETALLADO_APUNTES
where CODIGO_CUENTA >= '4300000' AND CODIGO_CUENTA <= '5000000' order by CODIGO_CUENTA
;

select * 
from AGRUPACIONES_DESGLOSES 
WHERE DOCUMENTO = 'FN1/000040'
;

select * 
from AGRUPACIONES_DESGLOSES 
WHERE NUMERO_AGRUPACION = '983' -- and documento = 'FN1/000857'
;