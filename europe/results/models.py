# -*- coding: utf-8 -*-

import math

from django.db import models
from django.utils.translation import ugettext as _


class Result(models.Model):
    """
    Result of game.
    """
    name      = models.CharField(_('Players Name'), max_length=32, blank=True, null=True)
    time      = models.IntegerField(_('Time'))
    category  = models.ForeignKey('quiz.Category')
    questions = models.ManyToManyField('quiz.Question', through='AnsweredQuestion')
    created   = models.DateTimeField(_('Created'), auto_now_add=True)

    class Meta:
        ordering = ('time', )
        verbose_name = _('Result')
        verbose_name_plural = _('Results')

    def __unicode__(self):
        return '%s (%s)' % (self.format_time(), self.name)

    def format_time(self):
        tenth = self.time % 10
        sec_num = round(self.time / 10.0)
        hours   = math.floor(sec_num / 3600.0)
        minutes = math.floor((sec_num - (hours * 3600.0)) / 60.0)
        seconds = sec_num - (hours * 3600) - (minutes * 60)
        return "%02i:%02i.%i" % (minutes, sec_num, tenth)


class AnsweredQuestion(models.Model):
    """
    Intermediate model which keeps information about game (which questions was selected
    and how player answer to them).
    """
    result   = models.ForeignKey('Result')
    question = models.ForeignKey('quiz.Question')
    order    = models.IntegerField(_('Order'))
    correct  = models.BooleanField(_('Correct answer'), default=None)
