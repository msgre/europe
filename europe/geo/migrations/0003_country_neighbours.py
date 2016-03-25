# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0002_auto_20150217_1944'),
    ]

    operations = [
        migrations.AddField(
            model_name='country',
            name='neighbours',
            field=models.ManyToManyField(related_name='neighbours_rel_+', to='geo.Country'),
            preserve_default=True,
        ),
    ]
