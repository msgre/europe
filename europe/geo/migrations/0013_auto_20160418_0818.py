# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0012_auto_20160416_1337'),
    ]

    operations = [
        migrations.AlterUniqueTogether(
            name='country',
            unique_together=set([('board', 'gate')]),
        ),
    ]
