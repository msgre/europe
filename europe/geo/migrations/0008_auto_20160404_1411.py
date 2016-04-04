# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations

CODES = {
    u"Albánie": "al",
    u"Andora": "ad",
    u"Arménie": "am",
    u"Belgie": "be",
    u"Bosna a Hercegovina": "ba",
    u"Bulharsko": "bg",
    u"Bělorusko": "by",
    u"Chorvatsko": "hr",
    u"Dánsko": "dk",
    u"Estonsko": "ee",
    u"Finsko": "fi",
    u"Francie": "fr",
    u"Gruzie": "ge",
    u"Irsko": "ie",
    u"Island": "is",
    u"Itálie": "it",
    u"Kazachstán": "kz",
    u"Kypr": "cy",
    u"Lichtenštejnsko": "li",
    u"Litva": "lt",
    u"Lotyšsko": "lv",
    u"Lucembursko": "lu",
    u"Makedonie": "mk",
    u"Malta": "mt",
    u"Maďarsko": "hu",
    u"Moldavsko": "md",
    u"Monako": "mc",
    u"Nizozemsko": "nl",
    u"Norsko": "no",
    u"Německo": "de",
    u"Polsko": "pl",
    u"Portugalsko": "pt",
    u"Rakousko": "at",
    u"Rumunsko": "ro",
    u"Rusko": "ru",
    u"San Marino": "sm",
    u"Slovensko": "sk",
    u"Slovinsko": "si",
    u"Spojené království": "gb",
    u"Srbsko": "rs",
    u"Turecko": "tr",
    u"Ukrajina": "ua",
    u"Vatikán": "va",
    u"Ázerbajdžán": "az",
    u"Černá Hora": "me",
    u"Česko": "cz",
    u"Řecko": "gr",
    u"Španělsko": "es",
    u"Švédsko": "se",
    u"Švýcarsko": "ch",
}

def fill_codes(apps, schema_editor):
    Country = apps.get_model("geo", "Country")
    for country in CODES:
        c = Country.objects.filter(title=country)
        if not c.exists():
            print 'Missing country', country
            continue
        c = c[0]
        c.code = CODES[country]
        c.save()

class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0007_country_code'),
    ]

    operations = [
        migrations.RunPython(fill_codes),
    ]
