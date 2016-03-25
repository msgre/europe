# -*- coding: utf-8 -*-

import random # TODO: docasny hack

from rest_framework import serializers
from geo.serializers import CountrySerializer
from .models import Category, Question


class CategorySerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Category
        fields = ('id', 'title', 'time_easy', 'penalty_easy', 'time_hard', 'penalty_hard', 'icon', 'disabled')


class QuestionsSerializer(serializers.HyperlinkedModelSerializer):
    country = CountrySerializer(read_only=True)
    category = CategorySerializer(read_only=True)
    image = serializers.SerializerMethodField() # TODO: docasny hack
    question = serializers.SerializerMethodField() # TODO: docasny hack

    class Meta:
        model = Question
        fields = ('id', 'question', 'difficulty', 'image', 'country', 'category')

    # TODO: docasny hack
    def get_image(self, obj):
        if self._get_variant(obj) == 'combined':
            choices = ['/foto-1_1.jpg', '/foto-2_3.jpg', '/foto-3_4.jpg', '/foto-4_3.jpg', '/foto-9_16.jpg']
            return random.choice(choices)
        elif self._get_variant(obj) == 'img':
            choices = ['/foto-16_9.jpg', '/vlajky.png']
            return random.choice(choices)
        else:
            return None

    # TODO: docasny hack
    def get_question(self, obj):
        if self._get_variant(obj) in ['text', 'combined']:
            return obj.question
        else:
            return None

    # TODO: docasny hack
    def _get_variant(self, obj):
        return ['img', 'text', 'combined'][obj.id % 3]
