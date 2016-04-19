# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


def set_last_led(apps, schema_editor):
    Country = apps.get_model("geo", "Country")
    
    country = Country.objects.get(led=0)
    country.led = 48
    country.save()

class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0016_auto_20160419_1000'),
    ]

    operations = [
        migrations.RunPython(set_last_led),
    ]
