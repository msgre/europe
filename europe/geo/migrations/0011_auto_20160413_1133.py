# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations

def correct_andora(apps, schema_editor):
    Country = apps.get_model("geo", "Country")
    Country.objects.filter(code='ad').update(title='Andorra')

class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0010_auto_20160411_1227'),
    ]

    operations = [
        migrations.RunPython(correct_andora),
    ]

