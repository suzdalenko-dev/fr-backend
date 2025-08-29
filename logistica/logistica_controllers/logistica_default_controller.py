import traceback
from django.http import JsonResponse
from froxa.utils.utilities.suzdal_logger import SuzdalLogger
from logistica.logistica_repository.aviso_diario_rep import aviso_diario_comp_98
from logistica.logistica_repository.comparacion_almacen_file import comparacion_almacen_98
from logistica.logistica_repository.logistica_default_fun import change_palets, get_and_refresh_gema_routes, load_truck_details, order_clicked, refresh_gema_table
from produccion.utils.sent_email_file import error_message_to_alexey



def log_default_controller(request, action, entity, code, description): 

    action      = str(action).strip().lower()   
    load_id     = str(entity).strip().lower()           
    truck_id    = str(code).strip().lower()
    description = str(description).strip().lower()
    

    # <str:action>/<str:entity>/<str:code>/<str:description>/
    switch_query = {

        'get_and_refresh_gema_routes':  lambda: get_and_refresh_gema_routes(request),  # http://127.0.0.1:8000/logistica/get/0/0/get_and_refresh_gema_routes/
        'refresh_gema':  lambda: refresh_gema_table(),                                 # http://127.0.0.1:8000/logistica/get/0/0/refresh_gema/ 
        'load_truck_details': lambda: load_truck_details(request, load_id, truck_id),  # http://127.0.0.1:8000/logistica/get/259/5/load_truck_details/
        'order_clicked': lambda: order_clicked(request, load_id),                      # http://127.0.0.1:8000/logistica/put/259/5/order_clicked/
        'change_palets': lambda: change_palets(request, load_id, truck_id),            # http://127.0.0.1:8000/logistica/put/259/5/change_palets/

        'comparacion_almacen_98': lambda: comparacion_almacen_98(request),  # http://127.0.0.1:8000/logistica/recalculate/0/0/comparacion_almacen_98/
        'aviso_diario_comp_98': lambda: aviso_diario_comp_98(request),      # http://127.0.0.1:8000/logistica/aviso/0/0/aviso_diario_comp_98/
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