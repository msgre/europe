# -*- coding: utf-8 -*-

from geo.models import Country
from quiz.models import Category, Question

category, _ = Category.objects.get_or_create(title=u'Hlavní města')

RECORDS = [
    (u'Albánie',             u'Tirana'),
    (u'Andora',              u'Andorra la Vella'),
    (u'Arménie',             u'Jerevan'),
    (u'Ázerbajdžán',         u'Baku'),
    (u'Belgie',              u'Brusel'),
    (u'Bělorusko',           u'Minsk'),
    (u'Bosna a Hercegovina', u'Sarajevo'),
    (u'Bulharsko',           u'Sofie'),
    (u'Černá Hora',          u'Podgorica'),
    (u'Česko',               u'Praha'),
    (u'Dánsko',              u'Kodaň'),
    (u'Estonsko',            u'Talin'),
    (u'Finsko',              u'Helsinky'),
    (u'Francie',             u'Paříž'),
    (u'Gruzie',              u'Tbilisi'),
    (u'Chorvatsko',          u'Záhřeb'),
    (u'Irsko',               u'Dublin'),
    (u'Island',              u'Reykjavík'),
    (u'Itálie',              u'Řím'),
    (u'Kazachstán',          u'Astana'),
    (u'Kypr',                u'Nikósie'),
    (u'Lichtenštejnsko',     u'Vaduz'),
    (u'Litva',               u'Vilnius'),
    (u'Lotyšsko',            u'Riga'),
    (u'Lucembursko',         u'Lucemburk'),
    (u'Maďarsko',            u'Budapešť'),
    (u'Makedonie',           u'Skopje'),
    (u'Malta',               u'Valletta'),
    (u'Moldavsko',           u'Kišiněv'),
    (u'Monako',              u'Monaco-Ville'),
    (u'Německo',             u'Berlín'),
    (u'Nizozemsko',          u'Amsterdam'),
    (u'Norsko',              u'Oslo'),
    (u'Polsko',              u'Varšava'),
    (u'Portugalsko',         u'Lisabon'),
    (u'Rakousko',            u'Vídeň'),
    (u'Rumunsko',            u'Bukurešť'),
    (u'Rusko',               u'Moskva'),
    (u'Řecko',               u'Atény'),
    (u'San Marino',          u'San Marino'),
    (u'Slovensko',           u'Bratislava'),
    (u'Slovinsko',           u'Lublaň'),
    (u'Spojené království',  u'Londýn'),
    (u'Srbsko',              u'Bělehrad'),
    (u'Španělsko',           u'Madrid'),
    (u'Švédsko',             u'Stockholm'),
    (u'Švýcarsko',           u'Bern'),
    (u'Turecko',             u'Ankara'),
    (u'Ukrajina',            u'Kyjev'),
]

for r in RECORDS:
    Question.objects.create(
        question = r[1],
        country = Country.objects.get(title=r[0]),
        category = category
    )
