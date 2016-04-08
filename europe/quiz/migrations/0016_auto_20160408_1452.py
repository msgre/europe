# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0015_auto_20160408_1423'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='category',
            name='disabled',
        ),
        migrations.AddField(
            model_name='category',
            name='enabled',
            field=models.BooleanField(default=True, verbose_name='Enabled'),
            preserve_default=True,
        ),
        migrations.AlterField(
            model_name='question',
            name='enabled',
            field=models.BooleanField(default=True, help_text='Only enabled questions will be used during game', verbose_name='Enabled'),
            preserve_default=True,
        ),
    ]
