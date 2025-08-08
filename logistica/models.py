from django.db import models


class ListOrdersInTheLoad(models.Model):
    load_id    = models.IntegerField(null=True, db_index=True)
    track_id   = models.IntegerField(null=True, db_index=True)
    order_id   = models.TextField(null=True)
    article_id = models.TextField(null=True)
    state      = models.TextField(null=True)
    

class TravelsClicked(models.Model):
    load_id              = models.IntegerField(null=True, db_index=True)
    track_id             = models.IntegerField(null=True, db_index=True)
    number_all_order     = models.IntegerField(null=True)
    number_clicked_order = models.IntegerField(null=True)