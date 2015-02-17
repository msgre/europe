# -*- coding: utf-8 -*-

from django.db import models
from django.utils.translation import ugettext as _


class Score(models.Model):
    """
    Score of finished game.
    """
    name     = models.CharField(_('Name of players'), max_length=128, blank=True, null=True)
    result   = models.TimeField(_('Result'))
    category = models.ForeignKey('quiz.Category')
    created  = models.DateTimeField(_('Created'), auto_now_add=True)

    class Meta:
        ordering = ('-created', )
        verbose_name = _('Score')
        verbose_name_plural = _('Scores')

    def __unicode__(self):
        if self.name:
            return u'%s (%s)' % (self.result, self.name)
        else:
            return self.result
