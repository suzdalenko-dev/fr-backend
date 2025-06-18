from django.db import models

class Userfroxa(models.Model):
    name        = models.TextField(null=True)
    password    = models.TextField(null=True)
    numvisit    = models.TextField(null=True)
    lastvisit   = models.TextField(null=True)
    role        = models.TextField(null=True)
    permissions = models.TextField(null=True)