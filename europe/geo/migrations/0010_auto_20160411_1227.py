# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


def fill_codes(apps, schema_editor):
    Country = apps.get_model("geo", "Country")
    Country.objects.filter(code__in=['am', 'az', 'ge']).delete()
    Country.objects.create(
        title  = u'Kosovo',
        board  = 1,
        gate   = 1,
        led    = 1,
        code   = 'xk'
    )


class Migration(migrations.Migration):

    dependencies = [
        ('geo', '0009_auto_20160404_1415'),
    ]

    operations = [
        migrations.RunPython(fill_codes),
    ]
