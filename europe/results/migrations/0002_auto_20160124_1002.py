# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('results', '0001_initial'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='answeredquestion',
            options={'ordering': ('order',)},
        ),
        migrations.AlterModelOptions(
            name='result',
            options={'ordering': ('time', '-created'), 'verbose_name': 'Result', 'verbose_name_plural': 'Results'},
        ),
    ]
