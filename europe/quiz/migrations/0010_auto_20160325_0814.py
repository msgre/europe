# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


def modify_default_categories(apps, schema_editor):
    Category = apps.get_model("quiz", "Category")

    to_delete = [u'Obrázky', u'Název', u'Místopis', u'Mapa']
    Category.objects.filter(title__in=to_delete).delete()

    c = Category.objects.create(
        title = u'Zajímavosti',
        icon = 'svg/star.svg',
        order = 115,
        disabled = True
    )

class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0009_auto_20160306_1449'),
    ]

    operations = [
        migrations.RunPython(modify_default_categories),
    ]
