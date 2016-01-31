# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


def clean_options(apps, schema_editor):
    Option = apps.get_model("options", "Option")
    Option.objects.filter(key='POCET_OTAZEK').update(key='QUESTION_COUNT')
    Option.objects.filter(key='POCET_VYSLEDKU').update(key='RESULT_COUNT')
    Option.objects.filter(key='CAS_NA_JEDNU_OTAZKU').delete()


class Migration(migrations.Migration):

    dependencies = [
        ('options', '0002_auto_20150218_1847'),
    ]

    operations = [
        migrations.RunPython(clean_options),
    ]
