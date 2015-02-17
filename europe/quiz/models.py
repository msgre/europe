# -*- coding: utf-8 -*-

from django.db import models
from django.utils.translation import ugettext as _


class Category(models.Model):
    """
    Category of question.
    """
    title = models.CharField(_('Category'), max_length=128, unique=True)

    class Meta:
        ordering = ('title', )
        verbose_name = _('Category')
        verbose_name_plural = _('Categories')

    def __unicode__(self):
        return self.title


class Question(models.Model):
    """
    Quiz question.
    """
    question = models.TextField(_('Question'), blank=True, null=True)
    image    = models.ImageField(_('Image'), upload_to=None, max_length=256)
    country  = models.ForeignKey('geo.Country')
    category = models.ForeignKey('Category')
    created  = models.DateTimeField(_('Created'), auto_now_add=True)
    updated  = models.DateTimeField(_('Updated'), auto_now=True)

    class Meta:
        ordering = ('category', 'question', 'image')
        verbose_name = _('Question')
        verbose_name_plural = _('Questions')

    def __unicode__(self):
        return self.question or self.image
