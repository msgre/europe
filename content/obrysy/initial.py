# -*- coding: utf-8 -*-

"""
Blind maps of European countries.

Maps are stored as SVG files in `svg/` directory. They came from 
wikipedia image https://commons.wikimedia.org/wiki/File:Blank_political_map_Europe_in_2008_WF_(with_Kosovo).svg#/media/File:Blank_political_map_Europe_in_2008_WF_(with_Kosovo).svg
which was transformed into individual files.
(NOTE: wikipedia is full of useful sources, for example 
https://commons.wikimedia.org/wiki/Category:Blank_SVG_maps_of_Europe)

SVG image was imported to Sketch application (see map.sketch file), all 
countries was filled with green color and white outline, blue sea. Individual
countries was filled with white color and masked with rectangular with ratio
2.1:1 (whole country and their nearest neighbours must be visible). After
masking, final group was resized to 1638x780 and stored as SVG.

Some countries wasn't processed due to their size (San Marino for example).

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
    "sk", "si", "gb", "tr", "ua", "me", "cz", "gr", "es", 
    "se", "ch",
]

# list of "hard" countries
CODES_HARD = [
    "al", "be", "ba", "bg", "by", "hr", "dk", "ee", "fi", "fr", 
    "ie", "is", "it", "kz", "cy", "lt", "lv", "lu", "mk", 
    "hu", "md", "nl", "no", "de", "pl", "pt", "at", "ro", "ru", 
    "sk", "si", "gb", "tr", "ua", "me", "cz", "gr", "es", 
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
            category   = category,
            image_css_recap = 'background:#fff;padding:0 0 0 4px;'
        )
        question.image.save(filename, File(open(filepath, 'rb')), save=True)

def load(stdout=None, stderr=None):
    stdout = stdout or sys.stdout
    stderr = stderr or sys.stderr
    load_flags(CODES_EASY, Question.QUESTION_DIFFICULTY_EASY, stdout, stderr)
    load_flags(CODES_HARD, Question.QUESTION_DIFFICULTY_HARD, stdout, stderr)
