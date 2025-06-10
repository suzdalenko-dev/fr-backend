from froxa.utils.utilities.smailer_file import SMailer


def aviso_expediente_sin_precio(expedientes_sin_precio):
    if expedientes_sin_precio and len(expedientes_sin_precio) > 0:

        lista_expedientes = ", ".join(map(str, expedientes_sin_precio))
        
        cuerpo = f"""<h1>Aviso Libra - Expedientes sin precio final</h1>
                <p>Hola, estos expedientes no tienen gastos imputados:</p>
                <p><strong>{lista_expedientes}</strong></p>
        """
        
        SMailer.send_email(
            ['kateryna.kosheleva@froxa.com', 'alejandra.ungidos@froxa.com', 'juan.pineiro@froxa.com', 'alexey.suzdalenko@froxa.com'],
            'Expedientes sin precio final (sin gastos imputados)',
            cuerpo,
            'none'
        )



        