# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0015_auto_20160419_0948'),
    ]

    operations = [
        migrations.AlterField(
            model_name='country',
            name='led',
            field=models.IntegerField(help_text='Order number of LED representing particular country. Enter value in range 1-50.', unique=True, verbose_name='LED'),
            preserve_default=True,
        ),
    ]
