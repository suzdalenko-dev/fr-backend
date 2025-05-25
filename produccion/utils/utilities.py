import json
from django.forms import model_to_dict
from django.http import JsonResponse

from froxa.utils.utilities.funcions_file import get_current_date
from produccion.models import ArticleCostsHead, ArticleCostsLines


def add_article_costs_head(request):
  
    art_head = ArticleCostsLines.objects.last()

    return JsonResponse({"data": model_to_dict(art_head)})