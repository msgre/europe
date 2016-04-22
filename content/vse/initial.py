# -*- coding: utf-8 -*-

"""
Merge all questions into "all" category.
"""

import sys

from geo.models import Country
from quiz.models import Question, Category

def load_all(difficulty, stdout, stderr):
    category = Category.objects.get(title=u'Vše')
    category.enabled = True
    category.save()

    attrs = ['difficulty', 'question', 'image', 'country', 'note', 'image_css_game', 'image_css_recap', 'enabled']
    questions = list(Question.objects.filter(difficulty=difficulty).values(*attrs))
    for kwargs in questions:
        kwargs['country'] = Country.objects.get(id=kwargs['country'])
        kwargs['category'] = category
        question = Question.objects.filter(**kwargs)
        if question.exists():
            stderr.write(u'Question for category "{}" already exist'.format(category))
            continue

        q = Question(**kwargs)
        q.save(ignore_tipi=True)


def load(stdout=None, stderr=None):
    stdout = stdout or sys.stdout
    stderr = stderr or sys.stderr
    load_all(Question.QUESTION_DIFFICULTY_EASY, stdout, stderr)
    load_all(Question.QUESTION_DIFFICULTY_HARD, stdout, stderr)
