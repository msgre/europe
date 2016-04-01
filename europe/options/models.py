# -*- coding: utf-8 -*-

from django.db import models
from django.utils.translation import ugettext as _


class Option(models.Model):
    """
    Game option.
    """
    key         = models.CharField(_('Key'), max_length=64, unique=True, help_text=_('System name of option, name it with upper case A-Z letters with no whitechars (use _ instead).'))
    description = models.TextField(_('Description'), blank=True, null=True, help_text=_('Human readable description of option. It is showed exclusively in administration only.'))
    value       = models.CharField(_('Value'), max_length=32)

    class Meta:
        ordering = ('key', )
        verbose_name = _('Option')
        verbose_name_plural = _('Options')

    def __unicode__(self):
        return self.key
