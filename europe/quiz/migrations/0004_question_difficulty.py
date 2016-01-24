# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0003_auto_20160124_1002'),
    ]

    operations = [
        migrations.AddField(
            model_name='question',
            name='difficulty',
            field=models.CharField(default=b'E', max_length=1, verbose_name='Difficulty', choices=[(b'E', 'Easy'), (b'H', 'Hard')]),
            preserve_default=True,
        ),
    ]
