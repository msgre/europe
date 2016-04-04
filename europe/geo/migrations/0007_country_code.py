# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0006_auto_20160401_1455'),
    ]

    operations = [
        migrations.AddField(
            model_name='country',
            name='code',
            field=models.CharField(default='xx', max_length=2, verbose_name='Country code'),
            preserve_default=False,
        ),
    ]
