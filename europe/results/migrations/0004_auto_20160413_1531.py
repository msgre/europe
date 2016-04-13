# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('results', '0003_result_difficulty'),
    ]

    operations = [
        migrations.AddField(
            model_name='result',
            name='top',
            field=models.BooleanField(default=False, verbose_name='Top score'),
            preserve_default=True,
        ),
        migrations.AlterField(
            model_name='result',
            name='time',
            field=models.IntegerField(help_text='Time in seconds \u2a0910', verbose_name='Time'),
            preserve_default=True,
        ),
    ]
