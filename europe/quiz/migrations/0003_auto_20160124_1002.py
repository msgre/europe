# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0002_auto_20150224_1904'),
    ]

    operations = [
        migrations.AddField(
            model_name='category',
            name='penalty',
            field=models.IntegerField(default=3, help_text='Penalty time which players get due to wrong answer, in seconds.', verbose_name='Penalty'),
            preserve_default=True,
        ),
        migrations.AddField(
            model_name='category',
            name='time',
            field=models.IntegerField(default=10, help_text='Time for answering one question, in seconds.', verbose_name='Time'),
            preserve_default=True,
        ),
    ]
