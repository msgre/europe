# -*- coding: utf-8 -*-

"""
Simple names of european countries.
"""

import sys

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
    "al", "ad", "am", "be", "ba", "bg", "by", "hr", "dk", "ee", "fi", "fr", 
    "ge", "ie", "is", "it", "kz", "cy", "li", "lt", "lv", "lu", "mk", "mt", 
    "hu", "md", "mc", "nl", "no", "de", "pl", "pt", "at", "ro", "ru", "sm", 
    "sk", "si", "gb", "rs", "tr", "ua", "va", "az", "me", "cz", "gr", "es", 
    "se", "ch",
]

def load_countries(codes, difficulty, stdout, stderr):
    category = Category.objects.get(title=u'Název')
    category.enabled = True
    category.save()
    for code in codes:
        country = Country.objects.get(code=code)
        question = Question.objects.filter(difficulty=difficulty, category=category, country=country)

        if question.exists():
            stderr.write(u'Question for "{}" country and category "{}" already exist'.format(country, category))
            continue

        Question.objects.create(
            question = country.title,
            country = country,
            difficulty = difficulty,
            category = category
        )

def load(stdout=None, stderr=None):
    stdout = stdout or sys.stdout
    stderr = stderr or sys.stderr
    load_countries(CODES_EASY, Question.QUESTION_DIFFICULTY_EASY, stdout, stderr)
    load_countries(CODES_HARD, Question.QUESTION_DIFFICULTY_HARD, stdout, stderr)
