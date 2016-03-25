# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


def modify_default_categories(apps, schema_editor):
    Category = apps.get_model("quiz", "Category")

    to_delete = [u'', u'Název', u'Místopis', u'Mapa']
    Category.objects.filter(title=u'Vše').delete()

class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0010_auto_20160325_0814'),
    ]

    operations = [
        migrations.RunPython(modify_default_categories),
    ]
