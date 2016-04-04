# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0011_auto_20160325_0821'),
    ]

    operations = [
        migrations.AlterField(
            model_name='question',
            name='image',
            field=models.FileField(help_text='Could be bitmap (PNG/JPG/GIF) or vector (SVG). MUST be in correct size, maximum width=1638, height=791.', upload_to=None, max_length=256, verbose_name='Image'),
            preserve_default=True,
        ),
    ]
