# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Country',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('title', models.CharField(unique=True, max_length=256, verbose_name='Name of the country')),
                ('sensor', models.CharField(max_length=32, verbose_name='Sensor')),
            ],
            options={
                'ordering': ('title',),
                'verbose_name': 'Country',
                'verbose_name_plural': 'Countries',
            },
            bases=(models.Model,),
        ),
    ]
