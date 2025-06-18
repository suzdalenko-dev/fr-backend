from django.http import JsonResponse
from froxa.models import Userfroxa
from froxa.utils.utilities.suzdal_logger import SuzdalLogger


def login_function(request): 
    action   = request.GET.get('action')
    username = request.GET.get('username')
    password = request.GET.get('password')

    try:
        if action == 'login':
            user = Userfroxa.objects.filter(name=username).first()
            if not user:
                return JsonResponse({"status": 404, "message": "Usuario no encontrado."})
            if user.password != password:
                return JsonResponse({"status": 401, "message": "Contraseña incorrecta."})

            return JsonResponse({"data": {"username": user.name, "role": user.role, "permissions": user.permissions, "id": user.id}})
    
        return JsonResponse({"data": {}})

    except Exception as e:
        return JsonResponse({ "status": 500, "message": "Error interno del servidor", "error": str(e)}, status=500)


