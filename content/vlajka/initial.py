# -*- coding: utf-8 -*-

"""
Flags of european countries.

Flags are stored as SVG files in `svg/` directory. They came from several 
sources and all of them was manualy processed in Sketch application
(corrected width/height ratio according to
https://en.wikipedia.org/wiki/List_of_aspect_ratios_of_national_flags,
fixed several visual problems).

Flags are normalised to maximum size 870x580.

There is no known visual problem in Chrome browser (49.0.2623.110), other
browser was not inspected.

Sources:

* https://github.com/lipis/flag-icon-css 
* Wikipedia (try queries like `moldavia flag`, there are SVG versions of flag)
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
    "sm", "sk", "si", "gb", "rs", "tr", "ua", "va", "me", "cz", "gr", "es", 
    "se", "ch",
]

# list of "hard" countries
CODES_HARD = [
    "al", "ad", "be", "ba", "bg", "by", "hr", "dk", "ee", "fi", "fr", 
    "ie", "is", "it", "kz", "cy", "li", "lt", "lv", "lu", "mk", "mt", 
    "hu", "md", "mc", "nl", "no", "de", "pl", "pt", "at", "ro", "ru", "sm", 
    "sk", "si", "gb", "rs", "tr", "ua", "va", "me", "cz", "gr", "es", 
    "se", "ch", "xk",
]


def load_flags(codes, difficulty, stdout, stderr):
    path = os.path.join(os.path.dirname(__file__), 'svg')
    category = Category.objects.get(title='Vlajka')
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
            category   = category,
            image_css_game = 'background:#fff;padding:3px',
            image_css_recap = 'height:70%;background:#fff;padding:3px;margin:24px;'
        )
        question.image.save(filename, File(open(filepath, 'rb')), save=True)

def load(stdout=None, stderr=None):
    stdout = stdout or sys.stdout
    stderr = stderr or sys.stderr
    load_flags(CODES_EASY, Question.QUESTION_DIFFICULTY_EASY, stdout, stderr)
    load_flags(CODES_HARD, Question.QUESTION_DIFFICULTY_HARD, stdout, stderr)
