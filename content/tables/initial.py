# -*- coding: utf-8 -*-

"""
Manual import from CSV files.

Columns in CSV files must have this column order:

* Country title
* Question
* Easy difficulty flag
* Hard difficulty flag

Difficulty flags could be any character -- in that case it will be identified
as question for this difficulty level. If you don't want to put question in 
given difficulty level, leave cell empty.
"""

import cgi
import csv
import sys
import os
import tipi

from geo.models import Country
from quiz.models import Question, Category

# TODO:
# Stát,Otázka,Jednoduchá hra,Obtížna hra


def load_csv(filename, title, stdout, stderr):
    category = Category.objects.get(title=title)
    category.enabled = True
    category.save()

    def _create(kwargs):
        question = Question.objects.filter(**kwargs)
        if question.exists():
            stderr.write(u'Question for "{}" country, category "{}" and "{}" difficulty already exist'.format(kwargs['country'], kwargs['category'], kwargs['difficulty']))
        else:
            Question.objects.create(**kwargs)

    with open(os.path.join(os.path.dirname(__file__), filename), 'rb') as csvfile:
        spamreader = csv.reader(csvfile, delimiter=',', quotechar='"')
        for idx, row in enumerate(spamreader):
            if idx == 0:
                # ignore first line
                continue
            country = Country.objects.get(title=row[0])

            question = tipi.tipi(cgi.escape(row[1].decode('utf-8')), lang='cs')
            kwargs = {
                'category': category,
                'country': country,
                'question': question,
                'difficulty': Question.QUESTION_DIFFICULTY_EASY
            }
            if row[2]:
                _create(kwargs)

            if row[3]:
                kwargs['difficulty'] = Question.QUESTION_DIFFICULTY_HARD
                _create(kwargs)


def load(stdout=None, stderr=None):
    stdout = stdout or sys.stdout
    stderr = stderr or sys.stderr
    load_csv('popis.csv', u'Popis', stdout, stderr)
    load_csv('zajimavosti.csv', u'Zajímavosti', stdout, stderr)
