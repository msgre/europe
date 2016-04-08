# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0013_auto_20160407_1627'),
    ]

    operations = [
        migrations.AddField(
            model_name='question',
            name='enabled',
            field=models.BooleanField(default=True, verbose_name='Enabled'),
            preserve_default=True,
        ),
    ]
