# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


def fill_options(apps, schema_editor):
    Option = apps.get_model("options", "Option")
    Option.objects.create(key='POCET_OTAZEK', description=u'Počet otázek pro jednu hru', value='10')
    Option.objects.create(key='CAS_NA_JEDNU_OTAZKU', description=u'Čas (ve vteřinách), které má hráč na zodpovězení jedné otázky', value='180')
    Option.objects.create(key='POCET_VYSLEDKU', description=u'Počet výsledků, které se objeví v tabulkách nejlepších.', value='10')


class Migration(migrations.Migration):

    dependencies = [
        ('options', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(fill_options),
    ]
