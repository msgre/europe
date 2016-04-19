# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations

LEDS_TOTAL = 48
LEDS_START = 27 # order number of first LED for first country

COUNTRIES = [
    # Albánie
    'al',
    # Andorra
    'ad',
    # Belgie
    'be',
    # Bělorusko
    'by',
    # Bosna a Hercegovina
    'ba',
    # Bulharsko
    'bg',
    # Černá Hora
    'me',
    # Česko
    'cz',
    # Dánsko
    'dk',
    # Estonsko
    'ee',
    # Finsko
    'fi',
    # Francie
    'fr',
    # Chorvatsko
    'hr',
    # Irsko
    'ie',
    # Island
    'is',
    # Itálie
    'it',
    # Kazachstán
    'kz',
    # Kosovo
    'xk',
    # Kypr
    'cy',
    # Lichtenštejnsko
    'li',
    # Litva
    'lt',
    # Lotyšsko
    'lv',
    # Lucembursko
    'lu',
    # Maďarsko
    'hu',
    # Makedonie
    'mk',
    # Malta
    'mt',
    # Moldavsko
    'md',
    # Monako
    'mc',
    # Německo
    'de',
    # Nizozemsko
    'nl',
    # Norsko
    'no',
    # Polsko
    'pl',
    # Portugalsko
    'pt',
    # Rakousko
    'at',
    # Rumunsko
    'ro',
    # Rusko
    'ru',
    # Řecko
    'gr',
    # San Marino
    'sm',
    # Slovensko
    'sk',
    # Slovinsko
    'si',
    # Spojené království
    'gb',
    # Srbsko
    'rs',
    # Španělsko
    'es',
    # Švédsko
    'se',
    # Švýcarsko
    'ch',
    # Turecko
    'tr',
    # Ukrajina
    'ua',
    # Vatikán
    'va',
]


def set_leds(apps, schema_editor):
    Country = apps.get_model("geo", "Country")
    
    for idx, code in enumerate(COUNTRIES):
        country = Country.objects.get(code=code)
        country.led = (LEDS_START + idx) % LEDS_TOTAL
        country.save()


class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0014_auto_20160419_0835'),
    ]

    operations = [
        migrations.RunPython(set_leds),
    ]
