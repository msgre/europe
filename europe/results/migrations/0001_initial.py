# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0002_auto_20150224_1904'),
    ]

    operations = [
        migrations.CreateModel(
            name='AnsweredQuestion',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('order', models.IntegerField(verbose_name='Order')),
                ('correct', models.BooleanField(default=None, verbose_name='Correct answer')),
                ('question', models.ForeignKey(to='quiz.Question')),
            ],
            options={
            },
            bases=(models.Model,),
        ),
        migrations.CreateModel(
            name='Result',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('name', models.CharField(max_length=32, null=True, verbose_name='Players Name', blank=True)),
                ('time', models.IntegerField(verbose_name='Time')),
                ('created', models.DateTimeField(auto_now_add=True, verbose_name='Created')),
                ('category', models.ForeignKey(to='quiz.Category')),
                ('questions', models.ManyToManyField(to='quiz.Question', through='results.AnsweredQuestion')),
            ],
            options={
                'ordering': ('time',),
                'verbose_name': 'Result',
                'verbose_name_plural': 'Results',
            },
            bases=(models.Model,),
        ),
        migrations.AddField(
            model_name='answeredquestion',
            name='result',
            field=models.ForeignKey(to='results.Result'),
            preserve_default=True,
        ),
    ]
