from django.contrib import admin
from django.http import JsonResponse
from django.urls import path
from calidad.cal_controllers.calidad_controller import calidad_default_controller
from finanzas.fin_controllers.fin_default_controller_file import fin_default_controller
from produccion.controller.produccion_defalt_controller import production_default_controller
from produccion.utils.utilities import add_article_costs_head
from zzircon.zz_contollers.zz_controller import zz_production_function

def api_test(request):
    return JsonResponse({"mensaje": "Django pero que pasa aqui"})



urlpatterns = [
    path('zzircon/<str:entity>/<str:code>/<str:description>/', zz_production_function),
    path('calidad/<str:action>/<str:entity>/<str:code>/<str:description>/', calidad_default_controller),
    path('produccion/<str:action>/<str:entity>/<str:code>/<str:description>/', production_default_controller),
    path('finanzas/<str:action>/<str:entity>/<str:code>/<str:description>/', fin_default_controller),


    path('produccion_add_articules/', add_article_costs_head), # http://127.0.0.1:8000/produccion_add_articules/
]

# hola hola