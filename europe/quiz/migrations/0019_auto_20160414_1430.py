# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


def set_icons(apps, schema_editor):
    Category = apps.get_model("quiz", "Category")

    ICONS = {
        u'Popis': 'svg/popis.svg',
        u'Obrys státu': 'svg/obrys.svg',
        u'Hlavní města': 'svg/hlavni-mesta.svg',
        u'Vlajka': 'svg/vlajka.svg',
        u'Název': 'svg/nazev.svg',
        u'Obrázky': 'svg/obrazky.svg',
    }
    for title, icon in ICONS.items():
        c = Category.objects.get(title=title)
        c.icon = icon
        c.save()

class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0018_auto_20160413_1225'),
    ]

    operations = [
        migrations.RunPython(set_icons),
    ]
