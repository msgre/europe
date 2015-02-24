# -*- coding: utf-8 -*-

import random
import itertools

from django.db import models
from django.utils.translation import ugettext as _


class Category(models.Model):
    """
    Category of question.
    """
    title = models.CharField(_('Category'), max_length=128, unique=True)
    order = models.IntegerField(_('Order'), default=10)

    class Meta:
        ordering = ('order', )
        verbose_name = _('Category')
        verbose_name_plural = _('Categories')

    def __unicode__(self):
        return self.title

    def get_random_questions(self, count):
        """
        Return list of randomly choosen Questions. There will be "count" records
        at max (but should be less). It is guaranteed that there will be no more
        than one question from same Country.
        """
        # all countries for which we have questions in current category
        country_ids = Question.objects.filter(category=self).values_list('country', flat=True)
        # get first random "count" countries
        random_ids = list(set(country_ids))
        random.shuffle(random_ids)

        # get questions for random countries
        # beware! there could be more than one question for given country
        data = Question.objects.select_related().filter(category=self, country__id__in=random_ids[:count]).order_by('country')

        out = []
        for k, g in itertools.groupby(data, lambda a: a.country.id):
            item = random.choice(list(g)) # random selection of question in case, that there is more questions for particular country
            out.append(item)

        random.shuffle(out)
        return out


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
