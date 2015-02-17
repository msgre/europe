# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Score',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('name', models.CharField(max_length=128, null=True, verbose_name='Name of players', blank=True)),
                ('result', models.TimeField(verbose_name='Result')),
                ('created', models.DateTimeField(auto_now_add=True, verbose_name='Created')),
                ('category', models.ForeignKey(to='quiz.Category')),
            ],
            options={
                'ordering': ('-created',),
                'verbose_name': 'Score',
                'verbose_name_plural': 'Scores',
            },
            bases=(models.Model,),
        ),
    ]
