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
            ['kateryna.kosheleva@froxa.com', 'alejandra.ungidos@froxa.com', 'alexey.suzdalenko@froxa.com'],
            'Expedientes sin precio final ( sin gastos imputados ) hay que imputar gastos en todas las hojas de seguimiento',
            body_message,
            'none'
        )

        # ['kateryna.kosheleva@froxa.com', 'alejandra.ungidos@froxa.com', 'alexey.suzdalenko@froxa.com'],
        # ['alexey.suzdalenko@froxa.com'],

        """
            1. coger el cambio del ultimo mes y calcular el precio con gastos desde el cambio de ultimo mes
            2. ver la diferencia que su pone por el kg entre el precio netto y con gastos y sumar esta deferencia al precio con el que tengo en €
                aplicando el cambio del mes

            Familia carne subfamilia pollo, creado 198 PS SABROSO
            003 CARNES 026 POLLO
                198 PS SABROSO
        """