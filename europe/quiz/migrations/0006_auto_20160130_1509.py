# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations

def copy_times(apps, schema_editor):
    Category = apps.get_model("quiz", "Category")
    for category in Category.objects.all():
        category.time_easy = category.time * 3
        category.penalty_easy = category.penalty
        category.time_hard = category.time
        category.penalty_hard = category.penalty
        category.save()

class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0005_auto_20160130_1508'),
    ]

    operations = [
        migrations.RunPython(copy_times),
    ]
