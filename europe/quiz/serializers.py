# -*- coding: utf-8 -*-

from rest_framework import serializers
from geo.serializers import CountrySerializer
from .models import Category, Question


class CategorySerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Category
        fields = ('id', 'title', 'icon', 'time_easy', 'penalty_easy', 'time_hard', 'penalty_hard', 'icon', 'enabled', )


class QuestionsSerializer(serializers.HyperlinkedModelSerializer):
    country = CountrySerializer(read_only=True)
    category = CategorySerializer(read_only=True)

    class Meta:
        model = Question
        fields = ('id', 'question', 'difficulty', 'image', 'country', 'category', 'image_css_game', 'image_css_recap')
