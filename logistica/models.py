from django.db import models



class OrderListBelinLoads(models.Model):
    load_id          = models.IntegerField(null=True, db_index=True)
    load_week        = models.TextField(null=True)
    load_date        = models.TextField(null=True)
    
    truck_id         = models.IntegerField(null=True, db_index=True)
    truck_name       = models.TextField(null=True)

    order_id         = models.TextField(null=True)

    articles         = models.TextField(null=True)
    clicked          = models.IntegerField(null=True)
    click_info       = models.TextField(null=True)
    palets           = models.FloatField(null=True)

    client_id        = models.TextField(null=True)
    client_name      = models.TextField(null=True)
    orden            = models.IntegerField(null=True)

    input_palets     = models.FloatField(null=True)
