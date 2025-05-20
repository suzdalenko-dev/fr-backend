from django.contrib import admin
from django.http import JsonResponse
from django.urls import path

def api_test(request):
    return JsonResponse({"mensaje": "Django OK 2"})

urlpatterns = [
    path('test/', api_test),
    path('test2/', api_test),
]
