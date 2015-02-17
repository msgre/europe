# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


COUNTRIES = [
    u'Albánie',
    u'Andora',
    u'Arménie',
    u'Ázerbajdžán',
    u'Belgie',
    u'Bělorusko',
    u'Bosna a Hercegovina',
    u'Bulharsko',
    u'Černá Hora',
    u'Česko',
    u'Dánsko',
    u'Estonsko',
    u'Finsko',
    u'Francie',
    u'Gruzie',
    u'Chorvatsko',
    u'Irsko',
    u'Island',
    u'Itálie',
    u'Kazachstán',
    u'Kypr',
    u'Lichtenštejnsko',
    u'Litva',
    u'Lotyšsko',
    u'Lucembursko',
    u'Maďarsko',
    u'Makedonie',
    u'Malta',
    u'Moldavsko',
    u'Monako',
    u'Německo',
    u'Nizozemsko',
    u'Norsko',
    u'Polsko',
    u'Portugalsko',
    u'Rakousko',
    u'Rumunsko',
    u'Rusko',
    u'Řecko',
    u'San Marino',
    u'Slovensko',
    u'Slovinsko',
    u'Spojené království',
    u'Srbsko',
    u'Španělsko',
    u'Švédsko',
    u'Švýcarsko',
    u'Turecko',
    u'Ukrajina',
    u'Vatikán',
]

def fill_countries(apps, schema_editor):
    Country = apps.get_model("geo", "Country")
    for idx, c in enumerate(COUNTRIES):
        Country.objects.create(title=c, sensor=str(idx+1))


class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(fill_countries),
    ]
