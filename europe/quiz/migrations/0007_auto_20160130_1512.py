# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0006_auto_20160130_1509'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='category',
            name='penalty',
        ),
        migrations.RemoveField(
            model_name='category',
            name='time',
        ),
    ]
