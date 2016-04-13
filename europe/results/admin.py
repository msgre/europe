# -*- coding: utf-8 -*-


from django.contrib import admin
from django.utils.translation import ugettext as _

from .models import Result, AnsweredQuestion


class AnsweredQuestionInline(admin.TabularInline):
    model = AnsweredQuestion
    fields = ('question', 'correct', )
    readonly_fields = ('question', )
    extra = 0
    can_delete = False


@admin.register(Result)
class ResultAdmin(admin.ModelAdmin):
    list_display = ('name_display', 'top', 'format_time', 'created', 'difficulty', 'category', )
    date_hierarchy = 'created'
    list_filter = ('top', 'difficulty', 'category')
    fieldsets = (
        (None, {
            'fields': ('name', 'time', 'format_time', 'category', 'difficulty'),
            'description': _("<p>This is game result. It is recorder on the end of game and it is not intended for direct edits with one exception &mdash; if somebody enter rude team name, you could change it. If you have <strong>good reason</strong>, you could also change other fields, but we don't reccomend it.</p>"),
        }),
    )
    readonly_fields = ('format_time',)
    inlines = [
        AnsweredQuestionInline
    ]
    
    def name_display(self, obj):
        if not obj.name:
            return u'-- {} --'.format(_("players name wasn't entered"))
        return obj.name
    name_display.short_description = _('Name')
