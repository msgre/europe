# -*- coding: utf-8 -*-

import cgi
import logging
import random
import itertools
import tipi

from django.db import models
from django.utils.translation import ugettext as _
from django.utils.text import slugify


logger = logging.getLogger(__name__)


class Category(models.Model):
    """
    Category of question.
    """
    title        = models.CharField(_('Category'), max_length=128, unique=True)
    icon         = models.CharField(_('Icon'), max_length=80, blank=True, null=True)
    order        = models.IntegerField(_('Order'), default=10)
    enabled      = models.BooleanField(_('Enabled'), default=True)
    time_easy    = models.IntegerField(_('Time (easy)'), default=10, help_text=_('Time for answering one question, in seconds. Easy difficulty.'))
    penalty_easy = models.IntegerField(_('Penalty (easy)'), default=3, help_text=_('Penalty time which players get due to wrong answer, in seconds. Easy difficulty.'))
    time_hard    = models.IntegerField(_('Time (hard)'), default=10, help_text=_('Time for answering one question, in seconds. Hard difficulty.'))
    penalty_hard = models.IntegerField(_('Penalty (hard)'), default=3, help_text=_('Penalty time which players get due to wrong answer, in seconds. Hard difficulty.'))

    class Meta:
        ordering = ('order', )
        verbose_name = _('Category')
        verbose_name_plural = _('Categories')

    def __unicode__(self):
        return self.title

    def get_random_questions(self, difficulty, count):
        """
        Return list of randomly choosen Questions. There will be "count" records
        at max (but should be less). It is guaranteed that there will be no more
        than one question from same Country.
        """
        # all countries
        from geo.models import Country
        countries = Country.objects.all().order_by('id').values('id', 'neighbours')
        countries_lut = {k: [y['neighbours'] for y in g if y['neighbours'] != None] \
                         for k, g in itertools.groupby(countries, lambda a: a['id'])}

        # countries for which we have questions in current category
        country_ids = Question.objects.filter(enabled=True, category=self, difficulty=difficulty).values_list('country', flat=True)
        # get first random "count" countries
        random_ids = list(set(country_ids))
        random.shuffle(random_ids)

        # find countries which are **not** close together
        i_count = 0
        temp = [random_ids[0]]
        random_ids = list(set(country_ids).difference(temp))
        while i_count <= count - 2:
            logger.debug('Selected country %i' % (temp[-1], ))
            if countries_lut[temp[-1]]:
                logger.debug('Disqualifing countries %s' % (countries_lut[temp[-1]], ))
                random_ids = list(set(random_ids).difference(countries_lut[temp[-1]] + [temp[-1]]))
                if not random_ids:
                    random_ids = list(set(country_ids).difference(temp))
                    logger.debug('Wow. List of ideal countries is empty, lets start new iteration: %s' % (random_ids, ))
                random.shuffle(random_ids)
            else:
                random_ids = list(set(random_ids).difference([temp[-1]]))
            logger.debug('Current set of possible countries: %s' % (random_ids, ))
            i_count += 1
            temp.append(random_ids[0])
            logger.debug('Current set of selected countries: %s' % (temp, ))
        random_ids = temp

        # get questions for random countries
        # beware! there could be more than one question for given country
        data = Question.objects.select_related().filter(enabled=True, category=self, difficulty=difficulty, country__id__in=random_ids[:count]).order_by('country')

        out = []
        for k, g in itertools.groupby(data, lambda a: a.country.id):
            item = random.choice(list(g)) # random selection of question in case, that there is more questions for particular country
            out.append(item)

        random.shuffle(out)
        return out


def upload_fn(instance, filename):
    return '%s/%s' % (slugify(instance.category.title), filename.lower())

class Question(models.Model):
    """
    Quiz question.
    """
    QUESTION_DIFFICULTY_EASY = 'E'
    QUESTION_DIFFICULTY_HARD = 'H'
    QUESTION_DIFFICULTY = (
        (QUESTION_DIFFICULTY_EASY, _('Easy')),
        (QUESTION_DIFFICULTY_HARD, _('Hard')),
    )

    difficulty = models.CharField(_('Difficulty'), max_length=1, choices=QUESTION_DIFFICULTY, default=QUESTION_DIFFICULTY_EASY)
    question   = models.TextField(_('Question'), blank=True, null=True)
    image      = models.FileField(_('Image'), blank=True, null=True, upload_to=upload_fn, max_length=256, help_text=_('Could be bitmap (PNG/JPG/GIF) or vector (SVG). MUST be in correct size, maximum width=1638, height=780.'))
    country    = models.ForeignKey('geo.Country')
    category   = models.ForeignKey('Category')
    note       = models.TextField(_('Note'), blank=True, null=True)
    enabled    = models.BooleanField(_('Enabled'), help_text=_('Only enabled questions will be used during game'), default=True)
    created    = models.DateTimeField(_('Created'), auto_now_add=True)
    updated    = models.DateTimeField(_('Updated'), auto_now=True)

    class Meta:
        ordering = ('category', 'question', 'image')
        verbose_name = _('Question')
        verbose_name_plural = _('Questions')

    def __unicode__(self):
        return self.question or self.image.path

    def save(self, *args, **kwargs):
        if self.question:
            self.question = tipi.tipi(cgi.escape(self.question), lang='cs')
        super(Question, self).save(*args, **kwargs)
