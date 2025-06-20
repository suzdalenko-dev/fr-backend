from django.db import models

class Userfroxa(models.Model):
    name        = models.TextField(null=True)
    password    = models.TextField(null=True)
    role        = models.TextField(null=True)
    permissions = models.TextField(null=True)

    first_visit = models.TextField(null=True)
    last_visit  = models.TextField(null=True)
    num_visit   = models.BigIntegerField(null=True)
    ip          = models.TextField(null=True)