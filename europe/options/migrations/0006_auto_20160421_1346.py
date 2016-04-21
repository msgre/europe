# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


def dumbness_initial(apps, schema_editor):
    Option = apps.get_model("options", "Option")
    Option.objects.create(key='DUMBNESS_TIME', value='600', description=u'Čas v [ms] po průjezdu branou, po kterou se ignorují jakékoliv další chybné průjezdy.')

class Migration(migrations.Migration):

    dependencies = [
        ('options', '0005_auto_20160306_1950'),
    ]

    operations = [
        migrations.RunPython(dumbness_initial),
    ]
