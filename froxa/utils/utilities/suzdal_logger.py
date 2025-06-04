import os
import datetime
import threading

class SuzdalLogger:
    LOG_DIR = "/var/log/froxa"
    os.makedirs(LOG_DIR, exist_ok=True)

    LOG_FILE = os.path.join(LOG_DIR, "app.log")
    MES_FILE = os.path.join(LOG_DIR, "mes_actual.log")  # Archivo auxiliar para guardar el mes

    @staticmethod
    def log(message):
        def write_log():
            now = datetime.datetime.now()
            timestamp = now.strftime("%H:%M:%S %d/%m/%Y")
            log_entry = '\n' if message == '' else f"{timestamp} {message}\n"

            # Comprobar si el mes ha cambiado
            mes_actual = now.strftime("%Y-%m")
            mes_guardado = None

            if os.path.exists(SuzdalLogger.MES_FILE):
                with open(SuzdalLogger.MES_FILE, "r") as f:
                    mes_guardado = f.read().strip()

            if mes_guardado != mes_actual:
                # Se ha cambiado de mes: borrar log y guardar nuevo mes
                try:
                    if os.path.exists(SuzdalLogger.LOG_FILE):
                        os.remove(SuzdalLogger.LOG_FILE)
                except Exception as e:
                    print(f"❌ Error al borrar el archivo de log: {e}")

                with open(SuzdalLogger.MES_FILE, "w") as f:
                    f.write(mes_actual)

            try:
                with open(SuzdalLogger.LOG_FILE, "a", encoding="utf-8") as f:
                    f.write(log_entry)
            except Exception as e:
                print(f"❌ Error escribiendo en el log: {e}")

        thread = threading.Thread(target=write_log)
        thread.daemon = True
        thread.start()

