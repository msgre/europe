# -*- coding: utf-8 -*-

from django.db import models
from django.utils.translation import ugettext as _


class Option(models.Model):
    """
    Game option.
    """
    key         = models.CharField(_('Key'), max_length=64, unique=True)
    description = models.TextField(_('Description'), blank=True, null=True)
    value       = models.CharField(_('Value'), max_length=32)

    class Meta:
        ordering = ('key', )
        verbose_name = _('Option')
        verbose_name_plural = _('Options')

    def __unicode__(self):
        return self.key
