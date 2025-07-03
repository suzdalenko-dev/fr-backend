def save_line_invoice_line(invoiceLine, chargeDate, currentDate, sqlRes, importe, importeCobrado):
    invoiceLine.updated           = currentDate
    invoiceLine.codigo_cliente    = sqlRes['CLIENTE']
    invoiceLine.cliente           = sqlRes['NOMBRE_CLIENTE']
    invoiceLine.org_comercial     = sqlRes['DESCRIPCION_ORG_COMER']
    invoiceLine.agente            = sqlRes['NOMBRE_AGENTE']
    
    invoiceLine.fecha_factura     = sqlRes['FECHA_FACTURA']
    invoiceLine.fecha_vencimiento = sqlRes['FECHA_VENCIMIENTO']
    invoiceLine.fecha_cobro       = chargeDate

    invoiceLine.importe           = importe 
    invoiceLine.importe_cobrado   = importeCobrado



    invoiceLine.save()