# -*- coding: utf-8 -*-

from django.db import models
from django.utils.translation import ugettext as _


class Country(models.Model):
    """
    European country.
    """
    title  = models.CharField(_('Name of the country'), max_length=256, unique=True)
    sensor = models.CharField(_('Sensor'), max_length=32)
    neighbours = models.ManyToManyField('self')

    class Meta:
        ordering = ('title', )
        verbose_name = _('Country')
        verbose_name_plural = _('Countries')

    def __unicode__(self):
        return self.title
