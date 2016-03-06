# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations

def lower_question_count(apps, schema_editor):
    Option = apps.get_model("options", "Option")
    o = Option.objects.get(key='QUESTION_COUNT')
    o.value = '8'
    o.save()

class Migration(migrations.Migration):

    dependencies = [
        ('options', '0004_auto_20160131_1653'),
    ]

    operations = [
        migrations.RunPython(lower_question_count),
    ]
