# -*- coding: utf-8 -*-

from django.db import models
from django.utils.translation import ugettext as _


class Country(models.Model):
    """
    European country.
    """
    title  = models.CharField(_('Name of the country'), max_length=256, unique=True)
    board  = models.IntegerField(_('Board'), help_text=_('Number of board as a decimal number in range 1-16.'))
    gate   = models.IntegerField(_('Gate'), help_text=_('Number of gate as a decimal number. Each gate is represent as bit, enter value from set [1, 2, 4, 8, 16].'))
    led    = models.IntegerField(_('LED'), unique=True, help_text=_('Order number of LED representing particular country. Enter value in range 1-50.'))
    code   = models.CharField(_('Country code'), max_length=2, unique=True)
    neighbours = models.ManyToManyField('self', help_text=_('Neighbours of country. Selected countries does not to have common border. It is used in algorithm for selecting random set of question -- if country from dense region is choosen, than no other country from this list will occur in final set of questions.'))

    class Meta:
        ordering = ('title', )
        verbose_name = _('Country')
        verbose_name_plural = _('Countries')
        unique_together = (("board", "gate"),)

    def __unicode__(self):
        return self.title
