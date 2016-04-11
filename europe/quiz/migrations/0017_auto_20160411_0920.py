# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


def categories_set(apps, schema_editor):
    Category = apps.get_model("quiz", "Category")

    to_delete = [u'Jazyk', u'Kultura', u'Příroda', u'Zajímavosti']
    Category.objects.filter(title__in=to_delete).delete()

    Category.objects.create(
        title        = u'Název',
        icon         = 'svg/star.svg',
        order        = 120,
        enabled      = True,
        time_easy    = 10,
        penalty_easy = 3,
        time_hard    = 10,
        penalty_hard = 3

    )
    Category.objects.create(
        title        = u'Obrázky',
        icon         = 'svg/star.svg',
        order        = 130,
        enabled      = False,
        time_easy    = 10,
        penalty_easy = 3,
        time_hard    = 10,
        penalty_hard = 3
    )
    Category.objects.create(
        title        = u'Mix 1',
        icon         = 'svg/star.svg',
        order        = 140,
        enabled      = False,
        time_easy    = 10,
        penalty_easy = 3,
        time_hard    = 10,
        penalty_hard = 3
    )
    Category.objects.create(
        title        = u'Mix 2',
        icon         = 'svg/star.svg',
        order        = 150,
        enabled      = False,
        time_easy    = 10,
        penalty_easy = 3,
        time_hard    = 10,
        penalty_hard = 3
    )

class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0016_auto_20160408_1452'),
    ]

    operations = [
        migrations.RunPython(categories_set),
    ]
