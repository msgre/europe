# -*- coding: utf-8 -*-

"""
Main cities of european countries.
"""

import sys

from geo.models import Country
from quiz.models import Question, Category

CITIES = {
    # Albánie
    'al': u'Tirana',
    # Andorra
    'ad': u'Andorra la Vella',
    # Belgie
    'be': u'Brusel',
    # Bělorusko
    'by': u'Minsk',
    # Bosna a Hercegovina
    'ba': u'Sarajevo',
    # Bulharsko
    'bg': u'Sofie',
    # Černá Hora
    'me': u'Podgorica',
    # Česko
    'cz': u'Praha',
    # Dánsko
    'dk': u'Kodaň',
    # Estonsko
    'ee': u'Talin',
    # Finsko
    'fi': u'Helsinky',
    # Francie
    'fr': u'Paříž',
    # Chorvatsko
    'hr': u'Záhřeb',
    # Irsko
    'ie': u'Dublin',
    # Island
    'is': u'Reykjavík',
    # Itálie
    'it': u'Řím',
    # Kazachstán
    'kz': u'Astana',
    # Kosovo
    'xk': u'Priština',
    # Kypr
    'cy': u'Nikósie',
    # Lichtenštejnsko
    'li': u'Vaduz',
    # Litva
    'lt': u'Vilnius',
    # Lotyšsko
    'lv': u'Riga',
    # Lucembursko
    'lu': u'Lucemburk',
    # Maďarsko
    'hu': u'Budapešť',
    # Makedonie
    'mk': u'Skopje',
    # Malta
    'mt': u'Valletta',
    # Moldavsko
    'md': u'Kišiněv',
    # Monako
    'mc': u'Monaco-Ville',
    # Německo
    'de': u'Berlín',
    # Nizozemsko
    'nl': u'Amsterdam',
    # Norsko
    'no': u'Oslo',
    # Polsko
    'pl': u'Varšava',
    # Portugalsko
    'pt': u'Lisabon',
    # Rakousko
    'at': u'Vídeň',
    # Rumunsko
    'ro': u'Bukurešť',
    # Rusko
    'ru': u'Moskva',
    # Řecko
    'gr': u'Atény',
    # San Marino
    'sm': u'San Marino',
    # Slovensko
    'sk': u'Bratislava',
    # Slovinsko
    'si': u'Lublaň',
    # Spojené království
    'gb': u'Londýn',
    # Srbsko
    'rs': u'Bělehrad',
    # Španělsko
    'es': u'Madrid',
    # Švédsko
    'se': u'Stockholm',
    # Švýcarsko
    'ch': u'Bern',
    # Turecko
    'tr': u'Ankara',
    # Ukrajina
    'ua': u'Kyjev',
    # Vatikán
    'va': u'Citta Del Vaticano',
}

# list of "easy" countries
CODES_EASY = [
    'be', 'bg', 'cz', 'dk', 'fi', 'fr', 'hr', 'ie', 'is', 'it', 'hu',
    'de', 'nl', 'no', 'pl', 'pt', 'at', 'ro', 'ru', 'gr', 'sk', 'gb',
    'es', 'se', 'ua',
]

# list of "hard" countries
CODES_HARD = [
    'al', 'ad', 'be', 'by', 'ba', 'bg', 'me', 'cz', 'dk', 'ee', 'fi',
    'fr', 'hr', 'ie', 'is', 'it', 'kz', 'xk', 'cy', 'li', 'lt', 'lv',
    'lu', 'hu', 'mk', 'mt', 'md', 'mc', 'de', 'nl', 'no', 'pl', 'pt',
    'at', 'ro', 'ru', 'gr', 'sm', 'sk', 'si', 'gb', 'rs', 'es', 'se',
    'ch', 'tr', 'ua', 'va',
]

def load_cities(codes, difficulty, stdout, stderr):
    category = Category.objects.get(title=u'Hlavní města')
    category.enabled = True
    category.save()
    for code in codes:
        country = Country.objects.get(code=code)
        question = Question.objects.filter(difficulty=difficulty, category=category, country=country)

        if question.exists():
            stderr.write(u'Question for "{}" country and category "{}" already exist'.format(country, category))
            continue

        Question.objects.create(
            question = u'Ve které zemi se nachází město {}?'.format(CITIES[code]),
            country = country,
            difficulty = difficulty,
            category = category
        )

def load(stdout=None, stderr=None):
    stdout = stdout or sys.stdout
    stderr = stderr or sys.stderr
    load_cities(CODES_EASY, Question.QUESTION_DIFFICULTY_EASY, stdout, stderr)
    load_cities(CODES_HARD, Question.QUESTION_DIFFICULTY_HARD, stdout, stderr)
