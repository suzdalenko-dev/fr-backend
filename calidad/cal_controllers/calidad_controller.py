from django.http import JsonResponse
from calidad.cal_repository.of_trazabilidad_file import of_trazabilidad_function
from calidad.cal_repository.ofs_list_calendar import get_list_ofs_calendar_func
from froxa.utils.utilities.suzdal_logger import SuzdalLogger


def calidad_default_controller(request, action, entity, code, description): 

    action      = str(action).strip().lower()   
    entity      = str(entity).strip().lower()           
    code        = str(code).strip().lower()
    description = str(description).strip().lower()
    

    switch_query = {
        'ofs_list_calendar': lambda: get_list_ofs_calendar_func(request),  # http://127.0.0.1:8000/calidad/get/of/calendar/ofs_list_calendar/?from=2025-01-01&to=2025-03-01
        'of_trazabilidad': lambda: of_trazabilidad_function(request, code) # http://127.0.0.1:8000/calidad/get/of/381/of_trazabilidad/
    }

    try:
        query_func = switch_query.get(description)
        result = query_func()
        return JsonResponse({"status": 200, 'message': 'ok', "data": result})
    except Exception as e:
        SuzdalLogger.log(f"❌ Error en consulta: str{e} ❌")
        return JsonResponse({"status": 500,"message": "Ha ocurrido un error en el servidor.","error": str(e)}, status=500)