# -*- coding: utf-8 -*-

"""
TODO:
"""

import os
import re
import sys

from django.core.files.base import File
from django.utils.text import slugify

from geo.models import Country
from quiz.models import Question, Category


PATH_BASE = os.path.join(os.path.dirname(__file__), 'photos')
PATH_EASY = os.path.join(PATH_BASE, 'E')
PATH_HARD = os.path.join(PATH_BASE, 'H')

FILENAME_RE = re.compile(r'^(\w+)_\d+\.(jpg)$', re.IGNORECASE)

def load_photos(path, difficulty, stdout, stderr):
    category = Category.objects.get(title=u'Obrázky')
    category.enabled = True
    category.save()

    category_slug = slugify(category.title)

    for filename in os.listdir(path):
        m = FILENAME_RE.match(filename)
        if not m:
            stderr.write(u'File "{}" doesnt match to filepattern'.format(filename))
            continue

        filepath = os.path.join(path, filename)
        code = m.group(1)
        country = Country.objects.get(code=code)

        question = Question.objects.filter(difficulty=difficulty, category=category, country=country, image='{}/{}'.format(category_slug, filename))
        if question.exists():
            stderr.write(u'Question with image "{}" for "{}" country and difficulty "{}" already exist'.format(filename, country, difficulty))
            continue

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
    load_photos(PATH_EASY, Question.QUESTION_DIFFICULTY_EASY, stdout, stderr)
    load_photos(PATH_HARD, Question.QUESTION_DIFFICULTY_HARD, stdout, stderr)
