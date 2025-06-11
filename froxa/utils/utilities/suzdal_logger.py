import os
import datetime
import threading

import requests

import datetime
import threading
import queue
import requests

class SuzdalLogger:
    LOG_URL = "https://ruta.froxa.net/log/libra.php"
    log_queue = queue.Queue()
    _worker_started = False
    _lock = threading.Lock()

    @staticmethod
    def _worker():
        while True:
            message = SuzdalLogger.log_queue.get()
            if message is None:
                break  # Salida controlada
            try:
                now = datetime.datetime.now()
                timestamp = now.strftime("%H:%M:%S %d/%m/%Y")
                log_entry = f"{timestamp} {message}"
                requests.get(SuzdalLogger.LOG_URL, params={'info': log_entry}, timeout=2)
            except Exception:
                pass
            SuzdalLogger.log_queue.task_done()

    @staticmethod
    def log(message):
        with SuzdalLogger._lock:
            if not SuzdalLogger._worker_started:
                threading.Thread(target=SuzdalLogger._worker, daemon=True).start()
                SuzdalLogger._worker_started = True

        SuzdalLogger.log_queue.put(message)
