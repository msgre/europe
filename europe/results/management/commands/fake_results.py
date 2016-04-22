# -*- coding: utf-8 -*-

"""
Fake initial data for highscores in each category.
"""

import random
import sys

from django.core.management.base import BaseCommand, CommandError

from quiz.models import Category, Question
from results.models import Result


NAMES = [
    u'Dopox', u'Kubik', u'Kosmik', u'Vorvi', u'Inža', u'Krabička', u'Žeryk', 
    u'Lída', u'Ďibla', u'Kety', u'Piraňa', u'Blériot'
]


class Command(BaseCommand):
    help = 'Generate fake top scores results for each category and difficulty'

    def handle(self, *args, **options):
        categories = Category.objects.all()
        difficulties = {
            Question.QUESTION_DIFFICULTY_EASY: {
                'initial': 6000,
                'delta': 600,
            },
            Question.QUESTION_DIFFICULTY_HARD: {
                'initial': 3000,
                'delta': 600,
            }
        }

        for category in categories:
            for difficulty in difficulties:
                for idx in range(10):
                    time = difficulties[difficulty]['initial'] + difficulties[difficulty]['delta'] * idx
                    Result.objects.create(
                        name       = random.choice(NAMES),
                        time       = time,
                        category   = category, 
                        difficulty = difficulty,
                        top        = True
                    )

        self.stdout.write('Done!')
