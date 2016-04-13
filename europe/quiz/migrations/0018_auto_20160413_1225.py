# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


def modify_default_categories(apps, schema_editor):
    Category = apps.get_model("quiz", "Category")

    Category.objects.filter(title=u'Mix 2').delete()

    category = Category.objects.get(title=u'Mix 1')
    category.title = u'Vše'
    category.icon = 'svg/vse.svg'
    category.order = 150
    category.save()

    category = Category.objects.create(
        title        = u'Zajímavosti',
        icon         = 'svg/zajimavosti.svg',
        order        = 140,
        enabled      = False,
        time_easy    = 10,
        penalty_easy = 3,
        time_hard    = 10,
        penalty_hard = 3
    )


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0017_auto_20160411_0920'),
    ]

    operations = [
        migrations.RunPython(modify_default_categories),
    ]
