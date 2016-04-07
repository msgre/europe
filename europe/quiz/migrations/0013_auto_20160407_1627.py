# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations
import quiz.models


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0012_auto_20160402_1001'),
    ]

    operations = [
        migrations.AddField(
            model_name='question',
            name='note',
            field=models.TextField(null=True, verbose_name='Note', blank=True),
            preserve_default=True,
        ),
        migrations.AlterField(
            model_name='question',
            name='image',
            field=models.FileField(help_text='Could be bitmap (PNG/JPG/GIF) or vector (SVG). MUST be in correct size, maximum width=1638, height=791.', upload_to=quiz.models.upload_fn, max_length=256, verbose_name='Image'),
            preserve_default=True,
        ),
    ]
