# -*- coding: utf-8 -*-

"""
Outlines of european countries.

Outlines are stored as SVG files in `svg/` directory. They came from 
wikipedia image https://commons.wikimedia.org/wiki/Category:Blank_SVG_maps_of_Europe#/media/File:Blank_map_europe_coloured.svg,
which was transformed into individual files.
(NOTE: wikipedia is full of useful sources, for example 
https://commons.wikimedia.org/wiki/Category:Blank_SVG_maps_of_Europe)

Countries was separated into 5 groups according their size and scaled (in 
comparison with their original size in wikipedia SVG):

* -44%
  ru
* -14%
  kz 
* +13.5%
  fr, gb, tr, ua, no, se, de, fi, it, es
* +49%
  gr, ro, pl, by
* +5%
  rs, dk, hr, ba, nl, ee, al, bg, md, lv, lt, hu, sk, cz, at, ch, ie, pt, is, me, mk, si, lu, cy, be

Reason of the scaling is to get optimal utilization of game area and 
simultaneously keep information about relative country size (for example we 
don't want Belgium in same size as France). See `grouped.sketch` file.
After scaling, all images was resized to fit 1050*700px area and exported
into individual files as shapes with no border and white fill. See 
`normalised.sketch` file.

This countries are missing due to their size (they are too small for game):
ad, li, mt, mc, sm, va

There is no known visual problem in Chrome browser (49.0.2623.110), other
browser was not inspected.
"""

import os
import sys

from django.core.files.base import File

from geo.models import Country
from quiz.models import Question, Category


# list of "easy" countries
CODES_EASY = [
    "be", "ba", "bg", "by", "hr", "dk", "ee", "fi", "fr", "ie", "is", "it", 
    "lt", "lv", "lu", "hu", "nl", "no", "de", "pl", "pt", "at", "ro", "ru", 
    "sk", "si", "gb", "rs", "tr", "ua", "me", "cz", "gr", "es", 
    "se", "ch",
]

# list of "hard" countries
CODES_HARD = [
    "al", "am", "be", "ba", "bg", "by", "hr", "dk", "ee", "fi", "fr", 
    "ge", "ie", "is", "it", "kz", "cy", "lt", "lv", "lu", "mk", 
    "hu", "md", "nl", "no", "de", "pl", "pt", "at", "ro", "ru", 
    "sk", "si", "gb", "rs", "tr", "ua", "az", "me", "cz", "gr", "es", 
    "se", "ch",
]


def load_flags(codes, difficulty, stdout, stderr):
    path = os.path.join(os.path.dirname(__file__), 'svg')
    category = Category.objects.get(title=u'Obrys státu')
    category.enabled = True
    category.save()

    for code in codes:
        country = Country.objects.get(code=code)
        question = Question.objects.filter(difficulty=difficulty, category=category, country=country)

        if question.exists():
            stderr.write(u'Question for "{}" country and category "{}" already exist'.format(country, category))
            continue

        filename = "{}.svg".format(code)
        filepath = os.path.join(path, filename)

        question = Question.objects.create(
            difficulty = difficulty,
            question   = None,
            country    = country,
            category   = category
        )
        question.image.save(filename, File(open(filepath, 'rb')), save=True)

def load(stdout=None, stderr=None):
    stdout = stdout or sys.stdout
    stderr = stderr or sys.stderr
    load_flags(CODES_EASY, Question.QUESTION_DIFFICULTY_EASY, stdout, stderr)
    load_flags(CODES_HARD, Question.QUESTION_DIFFICULTY_HARD, stdout, stderr)
