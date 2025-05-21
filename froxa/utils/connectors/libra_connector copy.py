import oracledb

from froxa.utils.utilities.suzdal_logger import SuzdalLogger


# Configuración Oracle
ORACLE_HOST = "192.168.1.10"
ORACLE_PORT = "1521"
ORACLE_SERVICE_NAME = "LBRSTP"
ORACLE_USER = "BI[LIBRA]"
ORACLE_PASSWORD = "drrWq9SNsFJH"

class OracleConnector:
    def __init__(self):
        self.connection = None
        self.cursor = None

    def connect(self):
        try:
            dsn = oracledb.makedsn(ORACLE_HOST, ORACLE_PORT, service_name=ORACLE_SERVICE_NAME)
            self.connection = oracledb.connect(user=ORACLE_USER,password=ORACLE_PASSWORD,dsn=dsn,)
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
            SuzdalLogger.log("Conecion cerrada inesperadamente ❌")
            return None

        try:
            self.cursor.execute(query, params or {})
            columns = [col[0] for col in self.cursor.description]  # Nombres de columnas

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
            SuzdalLogger.log("❌ Error cerrando cursor: {e}")

        try:
            if self.connection:
                self.connection.close()
                SuzdalLogger.log("✅ Conexión a Oracle cerrada.")
        except Exception as e:
            SuzdalLogger.log("❌ Error cerrando conexión: {e}")

        self.cursor = None
        self.connection = None
        SuzdalLogger.log("")
