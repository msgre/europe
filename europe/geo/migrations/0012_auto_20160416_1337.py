# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


GATES = {
    1: {
        0: 'ru',
        1: 'lv',
        3: 'se',
        4: 'ee',
        5: 'fi',
    },
    5: {
        0: 'is',
        2: 'gb',
        3: 'no',
    },
    2: {
        0: 'be',
        1: 'cz',
        2: 'nl',
        3: 'lu',
        4: 'dk',
        5: 'de',
    },
    7: {
        0: 'pt',
        1: 'ie',
        2: 'es',
        3: 'ad',
        4: 'fr',
    },
    3: {
        0: 'it',
        1: 'sm',
        2: 'ch',
        3: 'li',
        4: 'mc',
        5: 'va',
    },
    6: {
        0: 'mt',
        1: 'me',
        2: 'gr',
        3: 'al',
        4: 'mk',
        5: 'xk',
    },
    10: {
        0: 'hu',
        1: 'si',
        2: 'hr',
        3: 'ba',
        4: 'at',
        5: 'rs',
    },
    8: {
        0: 'tr',
        2: 'cy',
        3: 'kz',
        4: 'md',
        5: 'bg',
    },
    4: {
        0: 'ua',
        1: 'ro',
        2: 'sk',
        3: 'pl',
        4: 'by',
        5: 'lt',
    }
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
