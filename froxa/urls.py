from django.contrib import admin
from django.http import JsonResponse
from django.urls import path
from calidad.cal_controllers.calidad_controller import calidad_default_controller
from zzircon.zz_contollers.zz_controller import zz_production_function

def api_test(request):
    return JsonResponse({"mensaje": "Django pero que pasa aqui"})



urlpatterns = [
    path('zzircon/<str:entity>/<str:code>/<str:description>/', zz_production_function),
    path('calidad/<str:action>/<str:entity>/<str:code>/<str:description>/', calidad_default_controller),

    path('api_test/', api_test),
]
