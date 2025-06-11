import os
import datetime
import threading

import requests

class SuzdalLogger:
    LOG_URL = "https://ruta.froxa.net/log/libra.php"

    @staticmethod
    def log(message):
        def send_log():
            now = datetime.datetime.now()
            timestamp = now.strftime("%H:%M:%S %d/%m/%Y")
            log_entry = '' if message == '' else f"{timestamp} {message}"

            try:
                # Codificamos la información y la enviamos por GET
                params = {'info': log_entry}
                response = requests.get(SuzdalLogger.LOG_URL, params=params)

                if response.status_code != 200:
                    pass
            except Exception as e:
                pass

        thread = threading.Thread(target=send_log)
        thread.daemon = True
        thread.start()

