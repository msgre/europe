# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Option',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('key', models.CharField(unique=True, max_length=64, verbose_name='Key')),
                ('description', models.TextField(null=True, verbose_name='Description', blank=True)),
                ('value', models.CharField(max_length=32, verbose_name='Value')),
            ],
            options={
                'ordering': ('key',),
                'verbose_name': 'Option',
                'verbose_name_plural': 'Options',
            },
            bases=(models.Model,),
        ),
    ]
