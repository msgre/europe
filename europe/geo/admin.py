# -*- coding: utf-8 -*-

from django.contrib import admin
from django.utils.translation import ugettext as _

from .models import Country


@admin.register(Country)
class CountryAdmin(admin.ModelAdmin):
    list_display = ('title', 'code', 'board', 'gate', 'led', )
    list_editable = ('board', 'gate', 'led', )
    list_filter = ('board', 'gate')
    search_fields = ['title', 'code', 'neighbours__title']
    fieldsets = (
        (None, {
            'fields': ('title', 'code', 'neighbours', )
        }),
        (_('Hardware'), {
            'fields': (('board', 'gate', 'led', ), )
        }),
    )
