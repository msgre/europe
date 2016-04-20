# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations
import quiz.models


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0019_auto_20160414_1430'),
    ]

    operations = [
        migrations.AddField(
            model_name='question',
            name='image_css_game',
            field=models.CharField(help_text='CSS styles applied on image question during regular game', max_length=256, null=True, verbose_name='CSS styles for images on game screen', blank=True),
            preserve_default=True,
        ),
        migrations.AddField(
            model_name='question',
            name='image_css_recap',
            field=models.CharField(help_text='CSS styles applied to images on recap page', max_length=256, null=True, verbose_name='CSS styles for images recap screen', blank=True),
            preserve_default=True,
        ),
        migrations.AlterField(
            model_name='question',
            name='image',
            field=models.FileField(upload_to=quiz.models.upload_fn, max_length=256, blank=True, help_text='Could be bitmap (PNG/JPG/GIF) or vector (SVG). MUST be in correct size, maximum width=1638, height=780.', null=True, verbose_name='Image'),
            preserve_default=True,
        ),
    ]
