# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


NESTS = [
    ['gb', 'ie', 'nl', 'be', 'lu'],
    ['is', 'no', 'se', 'fi', 'dk'],
    ['ee', 'ru', 'lv', 'lt', 'by', 'ua', 'kz'],
    ['ro', 'md', 'bg', 'tr', 'gr', 'cy'],
    ['pl', 'de', 'cz', 'sk', 'hu', 'at'],
    ['si', 'hr', 'ba', 'rs', 'xk', 'me', 'mk', 'al'],
    ['ch', 'li', 'it', 'sm', 'va', 'mt'],
    ['fr', 'mc', 'ad', 'pt', 'es'],
]

def set_neighbours(apps, schema_editor):
    Country = apps.get_model("geo", "Country")
    
    for nest in NESTS:
        for code in nest:
            country = Country.objects.get(code=code)
            country.neighbours.clear()
            subset = list(set(nest).difference([code]))
            country.neighbours.add(*Country.objects.filter(code__in=subset))

class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0013_auto_20160418_0818'),
    ]

    operations = [
        migrations.RunPython(set_neighbours),
    ]
