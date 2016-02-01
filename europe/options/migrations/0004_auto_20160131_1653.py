# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


def fill_options(apps, schema_editor):
    Option = apps.get_model("options", "Option")
    Option.objects.create(key='IDLE_CROSSROAD', description=u'Volba hra/výsledky. Doba nečinnosti, po které se hra vrátí zpět na úvodní stránku. Čas v milisekundách.', value='4000')
    Option.objects.create(key='IDLE_GAMEMODE', description=u'Volba obtížnosti a kategorie. Doba nečinnosti, po které se hra vrátí zpět na úvodní stránku. Čas v milisekundách.', value='4000')
    Option.objects.create(key='IDLE_RECAP', description=u'Rekapitulace výsledků po hře. Doba nečinnosti, po které se hra vrátí zpět na úvodní stránku. Čas v milisekundách.', value='10000')
    Option.objects.create(key='IDLE_RESULT', description=u'Výsledky po hře. Doba nečinnosti, po které se hra vrátí zpět na úvodní stránku. Čas v milisekundách.', value='10000')
    Option.objects.create(key='IDLE_SCORE', description=u'Tabulka nejlepších po hře. Doba nečinnosti, po které se hra vrátí zpět na úvodní stránku. Čas v milisekundách.', value='10000')
    Option.objects.create(key='IDLE_SCORES', description=u'Listování v tabulkách nejlepších. Doba nečinnosti, po které se hra vrátí zpět na úvodní stránku. Čas v milisekundách.', value='10000')

    Option.objects.create(key='INTRO_TIME_PER_SCREEN', description=u'Doba zobrazení jednoho obrázku v karuselu na úvodní stránce.', value='3000')
    Option.objects.create(key='COUNTDOWN_TICK_TIMEOUT', description=u'Odpočítadlo před hrou, doba mezi jednotlivými čísly.', value='1100')


class Migration(migrations.Migration):

    dependencies = [
        ('options', '0003_auto_20160131_1554'),
    ]

    operations = [
        migrations.RunPython(fill_options),
    ]
