# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0007_auto_20160130_1512'),
    ]

    operations = [
        migrations.AddField(
            model_name='category',
            name='disabled',
            field=models.BooleanField(default=False, verbose_name='Disabled'),
            preserve_default=True,
        ),
        migrations.AddField(
            model_name='category',
            name='icon',
            field=models.CharField(max_length=80, null=True, verbose_name='Icon', blank=True),
            preserve_default=True,
        ),
    ]
