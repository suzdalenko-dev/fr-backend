import traceback
from django.http import JsonResponse
from froxa.utils.utilities.suzdal_logger import SuzdalLogger
from logistica.logistica_repository.logistica_default_fun import get_all_of_route, get_belin_routes
from produccion.utils.sent_email_file import error_message_to_alexey



def log_default_controller(request, action, entity, code, description): 

    action      = str(action).strip().lower()   
    entity      = str(entity).strip().lower()           
    code        = str(code).strip().lower()
    description = str(description).strip().lower()
    

    # <str:action>/<str:entity>/<str:code>/<str:description>/
    switch_query = {
        'get_belin_routes': lambda: get_belin_routes(request),        # http://127.0.0.1:8000/logistica/get/0/0/get_belin_routes/
        'get_all_of_route': lambda: get_all_of_route(request, code),  # http://127.0.0.1:8000/logistica/get/0/0/get_all_of_route/
    }

    try:
        query_func = switch_query.get(description)
        result = query_func()
        return JsonResponse({"status": 200, 'message': 'ok', "data": result})
    except Exception as e:
        tb = traceback.TracebackException.from_exception(e)
        error_str = ''.join(traceback.format_exception(e))
        error_message_to_alexey(request, f"{e.__class__.__name__}: {e}\n{error_str}")
        SuzdalLogger.log(f"❌ Error en consulta: str{e} ❌")
        return JsonResponse({"status": 500,"message": "Ha ocurrido un error en el servidor.","error": str(e)}, status=500)