from django.db import models

class Articulo(models.Model):
    codigo_articulo = models.CharField(max_length=50, unique=True)
    descripcion = models.TextField()
    consiste = models.TextField(blank=True, null=True)
    precio = models.DecimalField(max_digits=10, decimal_places=2)
    more = models.TextField(blank=True, null=True)  # puedes cambiar el tipo según el contenido

    def __str__(self):
        return f"{self.codigo_articulo} - {self.descripcion}"
