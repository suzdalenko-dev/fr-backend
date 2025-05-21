import os
import datetime
import threading

class SuzdalLogger:
    # 📂 Ruta estándar del sistema para logs personalizados
    LOG_DIR = "/var/log/froxa"
    os.makedirs(LOG_DIR, exist_ok=True)
    LOG_FILE = os.path.join(LOG_DIR, "app.log")

    @staticmethod
    def log(message):
        # Define la función que se ejecutará en el hilo
        def write_log():
            now = datetime.datetime.now()
            timestamp = now.strftime("%H:%M:%S %d/%m/%Y")
            if message == '':
                log_entry = '\n'
            else:
                log_entry = f"{timestamp} {message}\n"
            try:
                with open(SuzdalLogger.LOG_FILE, "a", encoding="utf-8") as f:
                    f.write(log_entry)
            except Exception as e:
                print(f"❌ Error escribiendo en el log: {e}")

        # Inicia el hilo (no bloqueante)
        thread = threading.Thread(target=write_log)
        thread.daemon = True  # El hilo se termina si el proceso principal termina
        thread.start()
