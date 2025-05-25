from django.db import models

class ArticleCostsHead(models.Model):
    article_code = models.IntegerField(unique=True)
    article_name = models.TextField(null=True)
    created_at   = models.CharField(max_length=22, null=True)
    updated_at   = models.CharField(max_length=22, null=True)


class ArticleCostsLines(models.Model):
    parent_article = models.IntegerField(null=True)
    article_code   = models.IntegerField(null=True)
    article_name   = models.TextField(null=True)
    percentage     = models.DecimalField(max_digits=11, decimal_places=1, null=True)
    alternative    = models.TextField(null=True)
   

