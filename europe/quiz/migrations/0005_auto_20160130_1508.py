# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0004_question_difficulty'),
    ]

    operations = [
        migrations.AddField(
            model_name='category',
            name='penalty_easy',
            field=models.IntegerField(default=3, help_text='Penalty time which players get due to wrong answer, in seconds. Easy difficulty.', verbose_name='Penalty (easy)'),
            preserve_default=True,
        ),
        migrations.AddField(
            model_name='category',
            name='penalty_hard',
            field=models.IntegerField(default=3, help_text='Penalty time which players get due to wrong answer, in seconds. Hard difficulty.', verbose_name='Penalty (hard)'),
            preserve_default=True,
        ),
        migrations.AddField(
            model_name='category',
            name='time_easy',
            field=models.IntegerField(default=10, help_text='Time for answering one question, in seconds. Easy difficulty.', verbose_name='Time (easy)'),
            preserve_default=True,
        ),
        migrations.AddField(
            model_name='category',
            name='time_hard',
            field=models.IntegerField(default=10, help_text='Time for answering one question, in seconds. Hard difficulty.', verbose_name='Time (hard)'),
            preserve_default=True,
        ),
    ]
