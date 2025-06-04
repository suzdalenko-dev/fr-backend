from django.db import models

class ArticleCostsHead(models.Model):
    article_code = models.IntegerField(unique=True)
    article_name = models.TextField(null=True)
    created_at   = models.CharField(max_length=22, null=True)
    updated_at   = models.CharField(max_length=22, null=True)
    cost_date    = models.TextField(null=True)


class ArticleCostsLines(models.Model):
    parent_article = models.IntegerField(null=True)
    article_code   = models.IntegerField(null=True)
    article_name   = models.TextField(null=True)
    percentage     = models.FloatField(null=True)
    alternative    = models.TextField(null=True)
   

class ExcelLinesEditable(models.Model):
    article_code = models.IntegerField(unique=True)
    article_name = models.TextField(null=True)

    rendimiento          = models.FloatField(null=True)
    precio_materia_prima = models.FloatField(null=True)
    
    precio_aceite        = models.FloatField(null=True)
    precio_servicios     = models.FloatField(null=True)
    aditivos             = models.FloatField(null=True)
    mod                  = models.FloatField(null=True)
    embalajes            = models.FloatField(null=True)
    amort_maq            = models.FloatField(null=True)
    moi                  = models.FloatField(null=True)

    inicio_coste_act     = models.FloatField(null=True)
    inicio_coste_mas1    = models.FloatField(null=True)
    inicio_coste_mas2    = models.FloatField(null=True)
    inicio_coste_mas3    = models.FloatField(null=True)

    final_coste_act      = models.FloatField(null=True)
    final_coste_mas1     = models.FloatField(null=True)
    final_coste_mas2     = models.FloatField(null=True)
    final_coste_mas3     = models.FloatField(null=True)


    precio_padre_act     = models.FloatField(null=True)
  