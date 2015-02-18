# -*- coding: utf-8 -*-

from rest_framework import serializers
from geo.serializers import CountrySerializer
from .models import Category, Question


class CategorySerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Category
        fields = ('id', 'title', )


class QuestionsSerializer(serializers.HyperlinkedModelSerializer):
    country = CountrySerializer(read_only=True)

    class Meta:
        model = Question
        fields = ('id', 'question', 'image', 'country', )
