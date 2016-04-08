# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations
import quiz.models


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0014_question_enabled'),
    ]

    operations = [
        migrations.AlterField(
            model_name='question',
            name='image',
            field=models.FileField(upload_to=quiz.models.upload_fn, max_length=256, blank=True, help_text='Could be bitmap (PNG/JPG/GIF) or vector (SVG). MUST be in correct size, maximum width=1638, height=791.', null=True, verbose_name='Image'),
            preserve_default=True,
        ),
    ]
