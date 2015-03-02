# -*- coding: utf-8 -*-

from rest_framework import serializers
from quiz.serializers import CategorySerializer
from .models import Result


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
