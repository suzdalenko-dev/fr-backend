import os
import json
import oracledb
from froxa.utils.utilities.suzdal_logger import SuzdalLogger

# Cargar credenciales desde JSON externo
def load_oracle_config():
    try:
        base_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../../froxa-keys/libra.db.json"))
        with open(base_path, "r", encoding="utf-8") as f:
            config_data = json.load(f)
            return config_data[0]  # Tomamos la primera conexión
    except Exception as e:
        SuzdalLogger.log(f"❌ No se pudo cargar la configuración Oracle: {e}")
        return None

class OracleConnector:
    def __init__(self):
        self.connection = None
        self.cursor = None
        self.config = load_oracle_config()

    def connect(self):
        if not self.config:
            SuzdalLogger.log("❌ Configuración Oracle no disponible.")
            return

        try:
            dsn = oracledb.makedsn(
                self.config["host"].split(":")[0],
                self.config["port"],
                service_name=self.config["service"]
            )
            self.connection = oracledb.connect(
                user=self.config["user"],
                password=self.config["password"],
                dsn=dsn
            )
            self.cursor = self.connection.cursor()
            SuzdalLogger.log("✅ Conexión a Oracle establecida.")
        except oracledb.Error as e:
            SuzdalLogger.log(f"❌ Error al establecer la conexión: {e}")
            self.connection = None

    def consult(self, query, params=None):
        result = []
        SuzdalLogger.log(str(query))
        SuzdalLogger.log(str(params))

        if not self.connection or not self.cursor:
            self.connect()

        if not self.connection:
            SuzdalLogger.log("❌ Conexión cerrada inesperadamente.")
            return None

        try:
            self.cursor.execute(query, params or {})
            columns = [col[0] for col in self.cursor.description]
            for row in self.cursor.fetchall():
                result.append({columns[i]: str(value) for i, value in enumerate(row)})
            SuzdalLogger.log(f"✅ Consulta correcta. Filas: {len(result)}")
            return result
        except oracledb.Error as e:
            SuzdalLogger.log(f"❌ Error en consulta: {e}")
            return None

    def close(self):
        try:
            if self.cursor:
                self.cursor.close()
        except Exception as e:
            SuzdalLogger.log(f"❌ Error cerrando cursor: {e}")

        try:
            if self.connection:
                self.connection.close()
                SuzdalLogger.log("✅ Conexión a Oracle cerrada.")
        except Exception as e:
            SuzdalLogger.log(f"❌ Error cerrando conexión: {e}")

        self.cursor = None
        self.connection = None
        SuzdalLogger.log("🔚 Sesión Oracle finalizada.\n")
