# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


GATES = {
    1: {
        1: 'ru',
        2: 'lv',
        8: 'se',
        16: 'ee',
        32: 'fi',
    },
    2: {
        1: 'be',
        2: 'cz',
        4: 'nl',
        8: 'lu',
        16: 'dk',
        32: 'de',
    },
    3: {
        1: 'it',
        2: 'sm',
        4: 'ch',
        8: 'li',
        16: 'mc',
        32: 'va',
    },
    4: {
        1: 'ua',
        2: 'ro',
        4: 'sk',
        8: 'pl',
        16: 'by',
        32: 'lt',
    },
    5: {
        1: 'is',
        4: 'gb',
        8: 'no',
    },
    6: {
        1: 'mt',
        2: 'me',
        4: 'gr',
        8: 'mk',
        16: 'xk',
        32: 'al',
    },
    7: {
        1: 'pt',
        2: 'ie',
        4: 'es',
        8: 'ad',
        16: 'fr',
    },
    8: {
        1: 'tr',
        4: 'cy',
        8: 'kz',
        16: 'md',
        32: 'bg',
    },
    10: {
        1: 'hu',
        2: 'si',
        4: 'hr',
        8: 'ba',
        16: 'at',
        32: 'rs',
    },
}

def set_boards(apps, schema_editor):
    Country = apps.get_model("geo", "Country")
    
    for board, gates in GATES.items():
        for gate, cc in gates.items():
            country = Country.objects.get(code=cc)
            country.board = board
            country.gate = gate
            country.save()


class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0011_auto_20160413_1133'),
    ]

    operations = [
        migrations.RunPython(set_boards),
    ]
