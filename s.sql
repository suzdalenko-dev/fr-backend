select SUM(IMPORTE_COBRADO), SUM(IMPORTE_SUSTITUIDO)
FROM HISTORICO_MOV_CARTERA 
WHERE documento = 'FR1/001533'
;

select * from HISTORICO_COBROS where DOCUMENTO = 'DAR401';

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

-- FN1/001369 cobrado todo     AQUI ME FALTA EL COBRO COMPLETO 
-- FN1/001918 cobrada la mitad ESTO ESTA BIEN
-- 

select * -- NVL(SUM(IMPORTE),0) AS IMPORTE_COBRADO_CUENTA 
from HISTORICO_DETALLADO_APUNTES where documento = 'DAR401' 
    -- and CODIGO_CUENTA IN (4300010,4300011,4300020,4300030,4300040,4300090,4309010,4310010,4310020,4310030,4310040,4311010,4312000,4315010,4315020,4360010,4360020,4360030,4360040,4380000,4380020)
    and signo='H'
;

select distinct codigo_cuenta from HISTORICO_DETALLADO_APUNTES
where CODIGO_CUENTA >= '4300000' AND CODIGO_CUENTA <= '5000000' order by CODIGO_CUENTA
;

select * 
from AGRUPACIONES_DESGLOSES 
WHERE DOCUMENTO = 'FN1/001369'
;

select * 
from AGRUPACIONES_DESGLOSES 
WHERE NUMERO_AGRUPACION = '1923' -- and documento = 'FN1/000857'
;

SELECT
    FECHA_FACTURA,
    FECHA_VENCIMIENTO,
    TIPO_TRANSACCION,
    DOCUMENTO,
    V_TIPO_REGISTRO,V_NUMERO_AGRUPACION,V_EJERCICIO,V_IMPORTE,V_IMPORTE_DIVISA FROM (SELECT AGRUPACIONES_DESGLOSES.* ,EJERCICIO V_EJERCICIO,IMPORTE V_IMPORTE,IMPORTE_DIVISA V_IMPORTE_DIVISA,NUMERO_AGRUPACION V_NUMERO_AGRUPACION,
    TIPO_REGISTRO V_TIPO_REGISTRO FROM AGRUPACIONES_DESGLOSES) AGRUPACIONES_DESGLOSES WHERE (DOCUMENTO='FN1/001369');


select * 
from AGRUPACIONES_DESGLOSES 
WHERE DOCUMENTO = 'FN1/001369'
;

select * 
from AGRUPACIONES_DESGLOSES 
WHERE DOCUMENTO = 'FN1/001918'
;

select * 
from HISTORICO_COBROS 
where DOCUMENTO = 'FN1/001369'
;

select * 
from HISTORICO_COBROS 
where DOCUMENTO = 'FN1/001918'
;

select *
from FACTURAS_VENTAS_VCTOS
where numero_serie = 'FN1'
    and numero_factura = '001369'
;

select *
from FACTURAS_VENTAS_VCTOS
where numero_serie = 'FN1'
    and numero_factura in ( '001369', '001918')
;
select * 
from HISTORICO_COBROS 
where DOCUMENTO in ( 'FN1/001369')
;

 SELECT TO_CHAR(MAX(ha.FECHA_ASIENTO), 'YYYY-MM-DD')
                                FROM HISTORICO_DETALLADO_APUNTES ha
                                WHERE ha.DOCUMENTO = 'FN1/001918' AND ha.CODIGO_CONCEPTO in ('COB', 'REM') AND DIARIO = 'BANC' AND ha.ENTIDAD = 'CL';

/*
en "/etc/apache2/apache2.conf:" he puesto: Timeout 888300

*/