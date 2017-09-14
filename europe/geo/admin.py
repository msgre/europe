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
    actions = ['enable_questions', 'disable_questions']

    def enable_questions(self, request, queryset):
        self._update_questions(queryset, True)
    enable_questions.short_description = "Enable questions for selected countries"
    
    def disable_questions(self, request, queryset):
        self._update_questions(queryset, False)
    disable_questions.short_description = "Disable questions for selected countries"

    def _update_questions(self, queryset, enabled):
        from quiz.models import Question
        Question.objects.filter(country__in=queryset).update(enabled=enabled)
