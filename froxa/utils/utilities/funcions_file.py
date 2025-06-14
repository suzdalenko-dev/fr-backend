from datetime import datetime, date, timedelta
import json
import os
from django.forms import model_to_dict
import calendar

def get_current_date():
    now = datetime.now()
    formatted = now.strftime("%Y-%m-%d %H:%M:%S")
    return formatted


def get_short_date():
    now = datetime.now()
    formatted = now.strftime("%Y-%m-%d")
    return formatted


def json_encode_one(oneObject):
    data = model_to_dict(oneObject)
    return data


def json_encode_all(listObject):
    data = [model_to_dict(article) for article in listObject]
    return data


def tCSV(x):
    return str(x).replace('.', ',')


def end_of_month_dates():
    todayD = date.today()
    dates  = [todayD.strftime("%Y-%m-%d")]
    year  = todayD.year
    month = todayD.month
    for i in range(22):
        month_i = month + i
        year_i = year + (month_i - 1) // 12
        month_i = ((month_i - 1) % 12) + 1
        LAST_DAY = calendar.monthrange(year_i, month_i)[1]
        fecha = date(year_i, month_i, LAST_DAY)
        dates.append(fecha.strftime("%Y-%m-%d"))
    return dates


def get_keys(file_key):
    try:
        base_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../../froxa-keys/"+file_key))
        with open(base_path, "r", encoding="utf-8") as f:
            config_data = json.load(f)
            return config_data[0]
    except Exception as e:
        print(f"❌ No se pudo cargar la configuración Oracle: {e}")
        return None