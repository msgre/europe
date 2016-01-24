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
        return Result.objects.values('category__title').annotate(best_time=Min('time')).order_by('category')


class CategoryResultList(generics.ListAPIView):
    """
    Top results in selected category.
    """
    serializer_class = ResultsSerializer
    lookup_url_kwarg = 'id'

    def get_queryset(self):
        try:
            category = Category.objects.get(pk=self.kwargs[self.lookup_url_kwarg])
        except:
            raise Http404
        if 'difficulty' not in self.request.query_params:
            raise ValidationError("Query parameter 'difficulty' is missing.")
        valid_params = [Result.RESULT_DIFFICULTY_EASY, Result.RESULT_DIFFICULTY_HARD]
        if self.request.query_params['difficulty'] not in valid_params:
            raise ValidationError("Query parameter 'difficulty' set to unknown value. Valid values are: %s" % (valid_params ,))
        results = Result.objects.filter(category=category, difficulty=self.request.query_params['difficulty'])
        count = Option.objects.get(key='POCET_OTAZEK')
        return results[:int(count.value)]


class ResultRank(generics.RetrieveAPIView):
    """
    Return basic information about new result -- position and total number
    of results in category.
    """
    serializer_class = RankSerializer

    def get_object(self):
        try:
            category = Category.objects.get(pk=self.kwargs['id'])
        except:
            raise Http404
        time = int(self.kwargs['time'])
        count = Option.objects.get(key='POCET_OTAZEK')
        count = int(count.value)

        position = Result.objects.filter(time__lte=time).count()
        total = Result.objects.all().count()

        category_position = Result.objects.filter(category=category, time__lte=time).count()
        category_total = Result.objects.filter(category=category).count()

        return {
            'position': position,
            'total': total,
            'top': position <= count,
            'category_position': category_position,
            'category_total': category_total,
            'category_top': category_position <= count,
        }


class CreateScoreRecord(generics.CreateAPIView):
    """
    TODO:
    """
    serializer_class = ScoreSerializer
    queryset = Result.objects.all()
