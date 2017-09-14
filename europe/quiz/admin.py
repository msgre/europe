# -*- coding: utf-8 -*-

from django.contrib import admin
from django.utils.translation import ugettext as _

from .models import Category, Question


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('title', 'order', 'enabled', )
    list_editable = ('order', 'enabled', )
    fieldsets = (
        (None, {
            'fields': ('title', 'order', 'enabled', 'icon', ),
        }),
        (_('Timing'), {
            'fields': (('time_easy', 'penalty_easy'),
                       ('time_hard', 'penalty_hard'), )
        }),
    )


@admin.register(Question)
class QuestionAdmin(admin.ModelAdmin):
    list_display = ('question_display', 'country', 'difficulty', 'enabled')
    list_editable = ('enabled', )
    list_filter = ('enabled', 'difficulty', 'category', 'country', )
    search_fields = ['question', 'country__title']
    fields = ('country', 'difficulty', 'category', 'question', 'image', 'enabled', 'image_css_game', 'image_css_recap', 'note', )
    actions = ['enable_questions', 'disable_questions']

    def question_display(self, obj):
        if obj.question:
            return obj.question
        else:
            return _('[photo]')
    question_display.short_description = _('Question')

    def has_delete_permission(self, request, obj=None):
        return False

    def enable_questions(self, request, queryset):
        self._update_questions(queryset, True)
    enable_questions.short_description = "Enable selected questions"

    def disable_questions(self, request, queryset):
        self._update_questions(queryset, False)
    disable_questions.short_description = "Disable selected questions"

    def _update_questions(self, queryset, enabled):
        queryset.update(enabled=enabled)
