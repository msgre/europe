# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations

# NOTE:
# temporary list of country neighbour
# beware! they are no appropriate from geological point of view
# they represent closest coutries, and are used 

COUNTRIES = {
    u'Albánie': [u'Řecko', u'Makedonie', u'Srbsko', u'Černá Hora'],
    u'Andora': [u'Španělsko', u'Francie'],
    u'Arménie': [u'Ázerbajdžán', u'Turecko', u'Gruzie'],
    u'Ázerbajdžán': [u'Gruzie', u'Arménie', u'Rusko',],
    u'Belgie': [u'Nizozemsko', u'Francie', u'Německo', u'Lucembursko',],
    u'Bělorusko': [u'Litva', u'Lotyšsko', u'Polsko', u'Ukrajina', u'Rusko',],
    u'Bosna a Hercegovina': [u'Chorvatsko', u'Srbsko', u'Černá Hora',],
    u'Bulharsko': [u'Rumunsko', u'Srbsko', u'Makedonie', u'Řecko', u'Turecko',],
    u'Černá Hora': [u'Bosna a Hercegovina', u'Srbsko', u'Albánie',],
    u'Česko': [u'Polsko', u'Německo', u'Rakousko', u'Slovensko',],
    u'Dánsko': [u'Německo', u'Švédsko',],
    u'Estonsko': [u'Rusko', u'Litva', u'Finsko',],
    u'Finsko': [u'Litva', u'Rusko', u'Švédsko',],
    u'Francie': [u'Belgie', u'Lucembursko', u'Německo', u'Švýcarsko', u'Itálie', u'Španělsko',],
    u'Gruzie': [u'Rusko', u'Ázerbajdžán', u'Arménie', u'Turecko',],
    u'Chorvatsko': [u'Slovinsko', u'Maďarsko', u'Bosna a Hercegovina', u'Černá Hora',],
    u'Irsko': [u'Spojené království',],
    u'Island': [],
    u'Itálie': [],
    u'Kazachstán': [],
    u'Kypr': [],
    u'Lichtenštejnsko': [],
    u'Litva': [],
    u'Lotyšsko': [],
    u'Lucembursko': [],
    u'Maďarsko': [],
    u'Makedonie': [],
    u'Malta': [],
    u'Moldavsko': [],
    u'Monako': [],
    u'Německo': [],
    u'Nizozemsko': [],
    u'Norsko': [],
    u'Polsko': [],
    u'Portugalsko': [],
    u'Rakousko': [],
    u'Rumunsko': [],
    u'Rusko': [],
    u'Řecko': [],
    u'San Marino': [],
    u'Slovensko': [],
    u'Slovinsko': [],
    u'Spojené království': [],
    u'Srbsko': [],
    u'Španělsko': [],
    u'Švédsko': [],
    u'Švýcarsko': [],
    u'Turecko': [],
    u'Ukrajina': [],
    u'Vatikán': [],
}


def fill_neighbours(apps, schema_editor):
    Country = apps.get_model("geo", "Country")
    for country in COUNTRIES:
        if not COUNTRIES[country]:
            continue
        c = Country.objects.get(title=country)
        for neighbour in COUNTRIES[country]:
            c.neighbours.add(Country.objects.get(title=neighbour))

class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0003_country_neighbours'),
    ]

    operations = [
        migrations.RunPython(fill_neighbours),
    ]
