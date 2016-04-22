# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


def update_timing(apps, schema_editor):
    Category = apps.get_model("quiz", "Category")

    Category.objects.all().update(penalty_easy=10, penalty_hard=10)


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0022_auto_20160422_0724'),
    ]

    operations = [
        migrations.RunPython(update_timing),
    ]
