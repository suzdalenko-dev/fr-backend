import json
from froxa.utils.utilities.funcions_file import json_encode_one
from produccion.models import EquivalentsHead


def create_update_equivalents(request, action, entity, code):
    if action == 'get':
        equi = EquivalentsHead.objects.all().values('id', 'article_name', 'alternative')
        equi = list(equi)
        return equi
    
    if action == 'create':
        name = str(request.POST.get('group_name')).strip()
        equiv, created = EquivalentsHead.objects.get_or_create(article_name=name)
        equiv.alternative = json.dumps([])
        equiv.save()

    if action == 'get_one':  # http://127.0.0.1:8000/produccion/get_one/0/2/create_update_equivalents/                        
        eqOne = EquivalentsHead.objects.get(id=code)
        eqOne = json_encode_one(eqOne)
        return eqOne
    
    if action == 'save_one':
        eqOne = EquivalentsHead.objects.get(id=code)
        eqOne.article_name = str(request.POST.get('group_name')).strip()
        eqOne.save()