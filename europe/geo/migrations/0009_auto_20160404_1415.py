# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0008_auto_20160404_1411'),
    ]

    operations = [
        migrations.AlterField(
            model_name='country',
            name='code',
            field=models.CharField(unique=True, max_length=2, verbose_name='Country code'),
            preserve_default=True,
        ),
    ]
