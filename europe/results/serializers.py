# -*- coding: utf-8 -*-

import collections
import re

from quiz.serializers import CategorySerializer
from quiz.models import Category, Question
from rest_framework import serializers

from .models import Result, AnsweredQuestion


QUESTIONS_RE = re.compile('^(\d+):(0|1)$')


class ResultsTopSerializer(serializers.ModelSerializer):
    """
    Top results, aggregated minimum times for each category.
    """
    title = serializers.SerializerMethodField('get_category_title')
    time = serializers.SerializerMethodField('get_best_time')

    class Meta:
        model = Result
        fields = ('title', 'time', )

    def get_category_title(self, obj):
        return obj['category__title']

    def get_best_time(self, obj):
        return obj['best_time']


class ResultsSerializer(serializers.HyperlinkedModelSerializer):
    """
    Standard serializer for categorized results.
    """
    category = CategorySerializer(read_only=True)

    class Meta:
        model = Result
        fields = ('id', 'name', 'time', 'category', 'difficulty', 'created')


class RankSerializer(serializers.Serializer):
    position = serializers.IntegerField()
    total = serializers.IntegerField()
    top = serializers.BooleanField()


class AnsweredQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = AnsweredQuestion
        fields = ('question', 'correct')


class ScoreSerializer(serializers.ModelSerializer):
    questions = AnsweredQuestionSerializer(many=True)

    class Meta:
        model = Result
        fields = ('name', 'time', 'category', 'difficulty', 'questions')

    def create(self, validated_data):
        result = Result.objects.create(
            name       = validated_data['name'],
            time       = validated_data['time'],
            category   = validated_data['category'],
            difficulty = validated_data['difficulty']
        )

        for idx, answer in enumerate(validated_data['questions']):
            AnsweredQuestion.objects.create(
                result   = result,
                question = answer['question'],
                order    = (idx + 1) * 10,
                correct  = answer['correct']
            )

        return result
