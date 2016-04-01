# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0005_auto_20160325_1729'),
    ]

    operations = [
        migrations.AddField(
            model_name='country',
            name='led',
            field=models.IntegerField(default=1, help_text='Order number of LED representing particular country. Enter value in range 1-50.', verbose_name='LED'),
            preserve_default=False,
        ),
        migrations.AlterField(
            model_name='country',
            name='board',
            field=models.IntegerField(help_text='Number of board as a decimal number in range 1-16.', verbose_name='Board'),
            preserve_default=True,
        ),
        migrations.AlterField(
            model_name='country',
            name='gate',
            field=models.IntegerField(help_text='Number of gate as a decimal number. Each gate is represent as bit, enter value from set [1, 2, 4, 8, 16].', verbose_name='Gate'),
            preserve_default=True,
        ),
        migrations.AlterField(
            model_name='country',
            name='neighbours',
            field=models.ManyToManyField(help_text='Neighbours of country. Selected countries does not to have common border. It is used in algorithm for selecting random set of question -- if country from dense region is choosen, than no other country from this list will occur in final set of questions.', related_name='neighbours_rel_+', to='geo.Country'),
            preserve_default=True,
        ),
    ]
