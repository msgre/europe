# -*- coding: utf-8 -*-

from django.http import Http404

from rest_framework import generics

from options.models import Option

from quiz.models import Category
from .models import Result
from .serializers import ResultsSerializer, RankSerializer


class MainResultList(generics.ListAPIView):
    """
    Top results from all categories.
    """
    serializer_class = ResultsSerializer

    def get_queryset(self):
        results = Result.objects.all()
        count = Option.objects.get(key='POCET_VYSLEDKU')
        return results[:int(count.value)]


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
        results = Result.objects.filter(category=category)
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
        time = int(self.kwargs['id'])
        count = Option.objects.get(key='POCET_OTAZEK')
        count = int(count.value)

        position = Result.objects.filter(time__lte=time).count()
        total = Result.objects.all().count()

        category_position = Result.objects.filter(category=category, time__lte=time).count()
        category_total = Result.objects.filter(category=category).count()

        return {
            'position': position,
            'total': total,
            'top': total > count and position <= count,
            'category_position': category_position,
            'category_total': category_total,
            'category_top': category_total > count and category_position <= count,
        }
