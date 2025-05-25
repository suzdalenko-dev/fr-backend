
from datetime import datetime

from django.forms import model_to_dict


def get_current_date():
    now = datetime.now()
    formatted = now.strftime("%Y-%m-%d %H:%M:%S")
    return formatted


def json_encode_one(oneObject):
    data = model_to_dict(oneObject)
    return data


def json_encode_all(listObject):
    data = [model_to_dict(article) for article in listObject]
    return data