from django.contrib import admin
from django.http import JsonResponse
from django.urls import path

def api_test(request):
    return JsonResponse({"mensaje": "Django OK 2"})

def zzircon_fun(request, actionx, code, description):
    return JsonResponse({
        "action": actionx,
        "code": code,
        "description": description
    })

urlpatterns = [
    path('zzircon/<str:actionx>/<str:code>/<str:description>/', zzircon_fun),
    path('test2/', api_test),
]
