# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


def set_timing(apps, schema_editor):
    Category = apps.get_model("quiz", "Category")

    CATEGORIES_SIMPLE = [
        u'Název',
        u'Vlajka',
        u'Obrázky',
        u'Obrys státu',
    ]
    CATEGORIES_HARD = [
        u'Hlavní města',
        u'Popis',
        u'Zajímavosti',
        u'Vše',
    ]
    Category.objects.filter(title__in=CATEGORIES_SIMPLE).update(time_easy=90, penalty_easy=10, time_hard=60, penalty_hard=15)
    Category.objects.filter(title__in=CATEGORIES_HARD).update(time_easy=120, penalty_easy=10, time_hard=90, penalty_hard=15)


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0021_auto_20160422_0651'),
    ]

    operations = [
        migrations.RunPython(set_timing),
    ]
