python manage.py startapp calidad

#
CAL001 Tomadatos de partes de inspección

El punto operacional de la Razón Social del comprador(NAD+BCO) es
incorrecto: "8414892000888".Debería ser 8414892100014.          003440 PUNTO OPERACIONAL cambio "PUNTO OPERACIONAL COMPRA" 8414892000888 => 8414892100014
incorrecto: "8414892000796".Debería ser 8414892100014.          003436 PUNTO OPERACIONAL cambio "PUNTO OPERACIONAL COMPRA" 8414892000888 => 8414892100014
incorrecto: "8414892002882".Debería ser 8414892100014.


para clientes MAKRO:

003436 MAKRO 79-MADRID
003440 MAKRO88-MADRID
003444 MAKRO288-BARCELONA

con siguiente datos de EDI

Quien recibe:               8414892000796  
A quien se factura:         8414892100014  
Quien paga:                 8414892100014  
Quien pide:                 8414892000796  
Punto Operacional Compra:   8414892100014

Quien recibe:               8414892000888  
A quien se factura:         8414892100014  
Quien paga:                 8414892100014  
Quien pide:                 8414892000888  
Punto Operacional Compra:   8414892100014

Quien recibe:               8414892002882  
A quien se factura:         8414892100014  
Quien paga:                 8414892100014  
Quien pide:                 8414892002882  
Punto Operacional Compra:   8414892100014

EL ERROR QUE DA EDI ES:
    El punto operacional de la Razón Social del comprador(NAD+BCO) es
    incorrecto: "8414892000796".Debería ser 8414892100014.
    === Errors for Invoice: FN1/002205
    El punto operacional de la Razón Social del comprador(NAD+BCO) es
    incorrecto: "8414892000888".Debería ser 8414892100014.
    === Errors for Invoice: FN1/002206
    El punto operacional de la Razón Social del comprador(NAD+BCO) es
    incorrecto: "8414892002882".Debería ser 8414892100014.

Ya he cambiado el código "Punto Operacional Compra" a 8414892100014 pero siguen dando error, 
alguna idea, Leandro, que es lo que deberia cambiar para que las facturas en EDI no tengar error y sigan pasando los pedidos ?¿


que es lo que paso finalmente con esto ?¿


INFORME DE SARA PROYECCIÓN DE PRECIOS:

0. VISTA 360 stock y precio actual artículo:
stock: DISPG sumar lo que hay en almacenes
precio: 00 CARTES P.M.P EUR

1. ver en libra el consumo: VENTAS y FABRICACIÓN por artículo

2. donde ver los PEDIDOS a futuro

3. LLEGADAS EXPEDIENTES con contenedores son € o $ ?¿
que hacer con las FECHA_LLEGADA cuando esta pasada VS fecha actual