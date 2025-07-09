def save_line_invoice_line(invoiceLine, chargeDate, currentDate, sqlRes, importe, importeCobrado):
    invoiceLine.updated           = currentDate
    invoiceLine.codigo_cliente    = sqlRes['CLIENTE']
    invoiceLine.cliente           = sqlRes['NOMBRE_CLIENTE']
    invoiceLine.org_comercial     = sqlRes['DESCRIPCION_ORG_COMER']
    invoiceLine.agente            = sqlRes['NOMBRE_AGENTE']
    invoiceLine.forma_cobro       = sqlRes['FORMA_COBRO']
    
    invoiceLine.fecha_factura     = sqlRes['FECHA_FACTURA']
    invoiceLine.fecha_vencimiento = sqlRes['FECHA_VENCIMIENTO']
    invoiceLine.fecha_cobro       = str(chargeDate)[:10]

    invoiceLine.importe           = float(importe or 0)
    invoiceLine.importe_cobrado   = float(importeCobrado or 0)

    if invoiceLine.importe - 1 <= invoiceLine.importe_cobrado and invoiceLine.importe > 0 and invoiceLine.importe_cobrado > 0:
        invoiceLine.status_cobro = 'COBRADO'
    elif invoiceLine.importe > 0 and invoiceLine.importe_cobrado > 0:
        invoiceLine.status_cobro = 'PARCIAL'
    else:
        invoiceLine.status_cobro = 'PENDIENTE'


    invoiceLine.save()