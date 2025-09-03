from froxa.utils.connectors.libra_connector import OracleConnector
from froxa.utils.utilities.funcions_file import crear_excel_sin_pandas, notify_logger
from froxa.utils.utilities.smailer_file import SMailer
from logistica.logistica_functions.fun_aviso_pal_prod import get_list_palets_prod


def aviso_diario_paleta_produccion(request):
    # aviso diario sobre palets que pueden quedar en produccion

    oracle = OracleConnector()
    oracle.connect()
    palets = get_list_palets_prod(request, oracle)

    oracle.close()

    file_url = crear_excel_sin_pandas(palets, '0', 'aviso-palets-prod')

    message_info = SMailer.send_email(
        ['alexey.suzdalenko@froxa.com'], # 'almacen@froxa.com' probar en produccion haber si llega el mensaje y haber si encuentro PALETAS EN PRODUCCION !!!
        'Aviso Libra - Existen paletas en PRODUCCION sin hubicar',
        'Aviso Libra - Paletas en producción.',
        file_url[0]
    )

    notify_logger(message_info)

    return {'x': [], 'file_url': file_url, 'message_info': message_info}