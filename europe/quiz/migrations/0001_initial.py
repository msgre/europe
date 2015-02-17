# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Category',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('title', models.CharField(unique=True, max_length=128, verbose_name='Category')),
            ],
            options={
                'ordering': ('title',),
                'verbose_name': 'Category',
                'verbose_name_plural': 'Categories',
            },
            bases=(models.Model,),
        ),
        migrations.CreateModel(
            name='Question',
            fields=[
                ('id', models.AutoField(verbose_name='ID', serialize=False, auto_created=True, primary_key=True)),
                ('question', models.TextField(null=True, verbose_name='Question', blank=True)),
                ('image', models.ImageField(upload_to=None, max_length=256, verbose_name='Image')),
                ('created', models.DateTimeField(auto_now_add=True, verbose_name='Created')),
                ('updated', models.DateTimeField(auto_now=True, verbose_name='Updated')),
                ('category', models.ForeignKey(to='quiz.Category')),
                ('country', models.ForeignKey(to='geo.Country')),
            ],
            options={
                'ordering': ('category', 'question', 'image'),
                'verbose_name': 'Question',
                'verbose_name_plural': 'Questions',
            },
            bases=(models.Model,),
        ),
    ]
