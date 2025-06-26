from froxa.utils.utilities.funcions_file import get_current_date
from froxa.utils.utilities.smailer_file import SMailer


def aviso_expediente_sin_precio(expedientes_sin_precio):
    if expedientes_sin_precio and len(expedientes_sin_precio) > 0:

        lista_expedientes = ", ".join(map(str, expedientes_sin_precio))
        
        time = get_current_date()
        body_message = f"""<h1>Aviso Libra - Expedientes sin precio final</h1>
                <p>Hola, estos expedientes no tienen gastos imputados:</p>
                <p><strong>{lista_expedientes}</strong></p>
        """
        
        SMailer.send_email(
            ['alexey.suzdalenko@froxa.com'],
            'Expedientes sin precio final ( sin gastos imputados ) hay que imputar gastos en todas las hojas de seguimiento',
            body_message,
            'none'
        )

        # ['kateryna.kosheleva@froxa.com', 'alejandra.ungidos@froxa.com', 'alexey.suzdalenko@froxa.com'],
        # ['alexey.suzdalenko@froxa.com'],

        """
           QUITAR CONTENEDORES CON PRECIO 0 !!!
        """