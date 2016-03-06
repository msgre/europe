# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations

def fill_default_categories(apps, schema_editor):
    Category = apps.get_model("quiz", "Category")
    categories = [
        (u'Popis', True),
        (u'Jazyk', True),
        (u'Obrázky', True),
        (u'Kultura', True),
        (u'Název', True),
        (u'Obrys státu', True),
        (u'Místopis', True),
        (u'Mapa', True),
        (u'Hlavní města', False),
        (u'Vlajka', True),
        (u'Příroda', True),
        (u'Vše',True),
    ]
    for order, (category, disabled) in enumerate(categories):
        c = Category.objects.filter(title=category)
        if c.exists():
            c = c[0]
            c.icon = 'svg/star.svg'
            c.order = order=(order+1)*10
            c.disabled = disabled
            c.save()
        else:
            Category.objects.create(title=category, icon='svg/star.svg', order=(order+1)*10, disabled=disabled)


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0008_auto_20160306_1448'),
    ]

    operations = [
        migrations.RunPython(fill_default_categories),
    ]
