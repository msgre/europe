# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


def set_category_order(apps, schema_editor):
    Category = apps.get_model("quiz", "Category")

    CATEGORIES = [
        u'Název',
        u'Vlajka',
        u'Hlavní města',
        u'Obrázky',
        u'Popis',
        u'Obrys státu',
        u'Zajímavosti',
        u'Vše',
    ]
    for idx, category in enumerate(CATEGORIES):
        c = Category.objects.get(title=category)
        c.order = (idx + 1) * 10
        c.save()

class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0020_auto_20160420_1213'),
    ]

    operations = [
        migrations.RunPython(set_category_order),
    ]
