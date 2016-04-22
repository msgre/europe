# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


def tune_options(apps, schema_editor):
    Option = apps.get_model("options", "Option")

    OPTIONS = {
        'QUESTION_COUNT': '6',
        'RESULT_COUNT': '8',
        'INTRO_TIME_PER_SCREEN': '5000',
        'IDLE_CROSSROAD': '8000',
        'IDLE_GAMEMODE': '8000',
        'IDLE_RECAP': '20000',
        'IDLE_RESULT': '15000',
        'IDLE_SCORE': '15000',
        'IDLE_SCORES': '15000',
    }

    for k, v in OPTIONS.items():
        o = Option.objects.get(key=k)
        o.value = v
        o.save()



class Migration(migrations.Migration):

    dependencies = [
        ('options', '0006_auto_20160421_1346'),
    ]

    operations = [
        migrations.RunPython(tune_options),
    ]
