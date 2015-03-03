# -*- coding: utf-8 -*-

import collections
import re

from quiz.serializers import CategorySerializer
from quiz.models import Category, Question
from rest_framework import serializers

from .models import Result, AnsweredQuestion


QUESTIONS_RE = re.compile('^(\d+):(0|1)$')


class ResultsSerializer(serializers.HyperlinkedModelSerializer):
    category = CategorySerializer(read_only=True)

    class Meta:
        model = Result
        fields = ('id', 'name', 'time', 'category', 'created')


class RankSerializer(serializers.Serializer):
    position = serializers.IntegerField()
    total = serializers.IntegerField()
    top = serializers.BooleanField()
    category_position = serializers.IntegerField()
    category_total = serializers.IntegerField()
    category_top = serializers.BooleanField()


class AnsweredQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = AnsweredQuestion
        fields = ('question', 'correct')


class ScoreSerializer(serializers.ModelSerializer):
    questions = AnsweredQuestionSerializer(many=True)

    class Meta:
        model = Result
        fields = ('name', 'time', 'category', 'questions')

    def create(self, validated_data):
        result = Result.objects.create(
            name     = validated_data['name'],
            time     = validated_data['time'],
            category = validated_data['category']
        )

        for idx, answer in enumerate(validated_data['questions']):
            AnsweredQuestion.objects.create(
                result   = result,
                question = answer['question'],
                order    = (idx + 1) * 10,
                correct  = answer['correct']
            )

        return result
