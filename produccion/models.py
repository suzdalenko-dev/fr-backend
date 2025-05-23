from django.db import models

class ArticleCostsHead(models.Model):
    id           = models.BigAutoField(primary_key=True)
    article_code = models.CharField(max_length=22, unique=True)
    article_name = models.TextField(null=True)
    old_art_code = models.CharField(max_length=22, null=True)




class ArticleCostsLines(models.Model):
    id           = models.BigAutoField(primary_key=True)
    costs_id     = models.BigIntegerField(null=True)
    article_code = models.CharField(max_length=22)
    article_name = models.TextField(null=True)
    percentage   = models.IntegerField(null=True)
    alternative  = models.TextField(null=True)
    state        = models.TextField(null=True)
   
