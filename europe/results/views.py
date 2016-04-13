# -*- coding: utf-8 -*-

from django.http import Http404
from django.db.models import Min

from rest_framework import generics
from rest_framework.exceptions import ValidationError

from options.models import Option

from quiz.models import Category
from .models import Result
from .serializers import ResultsTopSerializer, ResultsSerializer, RankSerializer, ScoreSerializer


class MainResultList(generics.ListAPIView):
    """
    Top results from all categories.
    """
    serializer_class = ResultsTopSerializer

    def get_queryset(self):
        return Result.objects.filter(top=True).values('category__title').annotate(best_time=Min('time')).order_by('category')


class CategoryResultList(generics.ListAPIView):
    """
    Top results in selected category.
    """
    serializer_class = ResultsSerializer
    lookup_url_kwarg = 'id'

    def get_queryset(self):
        (difficulty, pk) = self.kwargs[self.lookup_url_kwarg].split('-')
        try:
            category = Category.objects.get(pk=int(pk))
        except:
            raise Http404
        results = Result.objects.filter(category=category, difficulty=difficulty, top=True)
        count = Option.objects.get(key='RESULT_COUNT')
        return results[:int(count.value)]


class ResultRank(generics.RetrieveAPIView):
    """
    Return basic information about new result -- position and total number
    of results in category.
    """
    serializer_class = RankSerializer

    def get_object(self):
        (difficulty, pk) = self.kwargs['id'].split('-')
        try:
            category = Category.objects.get(pk=int(pk))
        except:
            raise Http404
        time = int(self.kwargs['time'])
        correct = int(self.kwargs['correct'])
        count = Option.objects.get(key='RESULT_COUNT')
        count = int(count.value)

        position = Result.objects.filter(category=category, difficulty=difficulty, time__lte=time, top=True).count()
        total = Result.objects.filter(category=category, difficulty=difficulty, top=True).count()

        return {
            'position': position,
            'total': total,
            'top': correct >= count/2 and position <= count,
        }


class CreateScoreRecord(generics.CreateAPIView):
    """
    Save game results.
    """
    serializer_class = ScoreSerializer
    queryset = Result.objects.all()
