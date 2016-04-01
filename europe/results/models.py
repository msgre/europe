# -*- coding: utf-8 -*-

import math
import datetime

from django.db import models
from django.utils.translation import ugettext as _
from django.utils.dateformat import time_format


class Result(models.Model):
    """
    Result of game.
    """
    RESULT_DIFFICULTY_EASY = 'E'
    RESULT_DIFFICULTY_HARD = 'H'
    RESULT_DIFFICULTY = (
        (RESULT_DIFFICULTY_EASY, _('Easy')),
        (RESULT_DIFFICULTY_HARD, _('Hard')),
    )

    name       = models.CharField(_('Players Name'), max_length=32, blank=True, null=True)
    time       = models.IntegerField(_('Time'), help_text=_(u'Time in seconds ⨉10'))
    category   = models.ForeignKey('quiz.Category')
    difficulty = models.CharField(_('Difficulty'), max_length=1, choices=RESULT_DIFFICULTY, default=RESULT_DIFFICULTY_EASY)
    questions  = models.ManyToManyField('quiz.Question', through='AnsweredQuestion')
    created    = models.DateTimeField(_('Created'), auto_now_add=True)

    class Meta:
        ordering = ('time', '-created')
        verbose_name = _('Result')
        verbose_name_plural = _('Results')

    def __unicode__(self):
        return '%s (%s)' % (self.format_time(), self.name)

    def format_time(self):
        dt = datetime.datetime(2016,1,1) + datetime.timedelta(seconds=self.time / 10.0)
        out = time_format(dt, 'i:s.u')
        return out[:out.rfind('.')+2]
    format_time.short_description = _('Formated time')
    format_time.admin_order_field = 'time'


class AnsweredQuestion(models.Model):
    """
    Intermediate model which keeps information about game (which questions was selected
    and how player answer to them).
    """
    result   = models.ForeignKey('Result')
    question = models.ForeignKey('quiz.Question')
    order    = models.IntegerField(_('Order'))
    correct  = models.BooleanField(_('Correct answer'), default=None)

    class Meta:
        ordering = ('order', )
