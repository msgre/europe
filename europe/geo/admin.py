# -*- coding: utf-8 -*-

from django.contrib import admin
from django.utils.translation import ugettext as _

from .models import Country


@admin.register(Country)
class CountryAdmin(admin.ModelAdmin):
    list_display = ('title', 'board', 'gate', )
    list_editable = ('board', 'gate', )
    list_filter = ('board', 'gate')
    search_fields = ['title', 'neighbours__title']
    fieldsets = (
        (None, {
            'fields': ('title', 'neighbours', )
        }),
        (_('Hardware'), {
            'fields': (('board', 'gate'), )
        }),
    )
