# -*- coding: utf-8 -*-

import random # TODO: docasny hack

from rest_framework import serializers
from geo.serializers import CountrySerializer
from .models import Category, Question


class CategorySerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Category
        fields = ('id', 'title', 'time', 'penalty',)


class QuestionsSerializer(serializers.HyperlinkedModelSerializer):
    country = CountrySerializer(read_only=True)
    category = CategorySerializer(read_only=True)
    image = serializers.SerializerMethodField() # TODO: docasny hack

    class Meta:
        model = Question
        fields = ('id', 'question', 'difficulty', 'image', 'country', 'category')

    # TODO: docasny hack
    def get_image(self, obj):
        if random.random() < .5:
            return '/riga.jpg'
        else:
            return None
