# -*- coding: utf-8 -*-

"""
Simple names of european countries.
"""

import sys

from geo.models import Country
from quiz.models import Question, Category


# list of "easy" countries
CODES_EASY = [
    'bg', 'cz', 'dk', 'fi', 'fr', 'hr', 'ie', 'is', 'it', 'cy', 'hu',
    'de', 'nl', 'no', 'pl', 'pt', 'at', 'ro', 'ru', 'gr', 'sk', 'gb',
    'es', 'se', 'tr', 'ua', 
]

# list of "hard" countries
CODES_HARD = [
    'al', 'ad', 'be', 'by', 'ba', 'bg', 'me', 'cz', 'dk', 'ee', 'fi',
    'fr', 'hr', 'ie', 'is', 'it', 'kz', 'xk', 'cy', 'li', 'lt', 'lv',
    'lu', 'hu', 'mk', 'mt', 'md', 'mc', 'de', 'nl', 'no', 'pl', 'pt',
    'at', 'ro', 'ru', 'gr', 'sm', 'sk', 'si', 'gb', 'rs', 'es', 'se',
    'ch', 'tr', 'ua', 'va',
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
