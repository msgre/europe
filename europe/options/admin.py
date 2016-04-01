# -*- coding: utf-8 -*-

from django.contrib import admin
from django.utils.translation import ugettext as _

from .models import Option


@admin.register(Option)
class OptionAdmin(admin.ModelAdmin):
    list_display = ('key', 'value', 'description', )
    list_editable = ('value', )
    fields = ('key', 'value', 'description')
