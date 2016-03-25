# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0004_auto_20160325_1055'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='country',
            name='sensor',
        ),
        migrations.AddField(
            model_name='country',
            name='board',
            field=models.IntegerField(default=1, verbose_name='Board'),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='country',
            name='gate',
            field=models.IntegerField(default=1, verbose_name='Gate'),
            preserve_default=False,
        ),
    ]
