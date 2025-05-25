from django.http import JsonResponse
from froxa.utils.utilities.suzdal_logger import SuzdalLogger
from produccion.repository.recalculate_price_file import recalculate_price_projections


def production_default_controller(request, action, entity, code, description): 

    action      = str(action).strip().lower()   
    entity      = str(entity).strip().lower()           
    code        = str(code).strip().lower()
    description = str(description).strip().lower()
    
    # <str:action>/<str:entity>/<str:code>/<str:description>/
    switch_query = {
        'recalculate_price_projections': lambda: recalculate_price_projections(request),  # http://127.0.0.1:8000/produccion/get/0/0/recalculate_price_projections/
        
    }

    try:
        query_func = switch_query.get(description)
        result = query_func()
        return JsonResponse({"status": 200, 'message': 'ok', "data": result})
    except Exception as e:
        SuzdalLogger.log(f"❌ Error en consulta: str{e} ❌")
        return JsonResponse({"status": 500,"message": "Ha ocurrido un error en el servidor.","error": str(e)}, status=500)